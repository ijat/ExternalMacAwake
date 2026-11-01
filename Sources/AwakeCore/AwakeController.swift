import Foundation
import Observation

public enum AwakeState: Equatable, Sendable {
    case disabled
    case waiting(reason: String)
    case active
    case error(String)
}

/// Owns the keep-awake decision. After every `refresh()`:
/// `assertion.isHeld == (isEnabled && selectedRule.shouldKeepAwake(snapshot))`,
/// unless acquiring failed, in which case the state is `.error` and nothing is held.
@MainActor
@Observable
public final class AwakeController {
    public private(set) var state: AwakeState = .disabled
    public private(set) var snapshot: SystemSnapshot = SystemSnapshot()
    public private(set) var selectedRule: any TriggerRule
    public private(set) var isEnabled: Bool

    @ObservationIgnored private let displayProvider: any DisplayProvider
    @ObservationIgnored private let lidProvider: any LidStateProvider
    @ObservationIgnored private let assertion: any PowerAssertion
    @ObservationIgnored private let settings: any SettingsStore
    @ObservationIgnored private let catalog: TriggerCatalog
    @ObservationIgnored private let pollInterval: Duration?
    @ObservationIgnored private var pollTask: Task<Void, Never>?
    @ObservationIgnored private var isRunning = false

    /// - Parameter pollInterval: a safety-net refresh for changes without a notification
    ///   (lid state). `nil` disables it.
    public init(
        displayProvider: any DisplayProvider,
        lidProvider: any LidStateProvider,
        assertion: any PowerAssertion,
        settings: any SettingsStore,
        catalog: TriggerCatalog = .standard,
        pollInterval: Duration? = .seconds(5)
    ) {
        self.displayProvider = displayProvider
        self.lidProvider = lidProvider
        self.assertion = assertion
        self.settings = settings
        self.catalog = catalog
        self.pollInterval = pollInterval
        self.selectedRule = catalog.rule(for: settings.triggerID)
        self.isEnabled = settings.isEnabled
    }

    /// Begins observing the system and applies the current state.
    public func start() {
        guard !isRunning else { return }
        isRunning = true
        displayProvider.startObserving { [weak self] in self?.refresh() }
        if let pollInterval {
            pollTask = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(for: pollInterval)
                    if Task.isCancelled { break }
                    self?.refresh()
                }
            }
        }
        refresh()
    }

    /// Re-reads the system and brings the assertion in line with the rule.
    public func refresh() {
        guard isRunning else { return }
        let latest = SystemSnapshot(
            displays: displayProvider.snapshotDisplays(),
            lidClosed: lidProvider.isLidClosed())
        if latest != snapshot { snapshot = latest }

        let newState: AwakeState
        if isEnabled && selectedRule.shouldKeepAwake(latest) {
            do {
                if !assertion.isHeld {
                    try assertion.acquire(reason: "Keeping the display awake: \(selectedRule.title)")
                }
                newState = .active
            } catch {
                newState = .error(error.localizedDescription)
            }
        } else {
            assertion.release()
            newState = isEnabled ? .waiting(reason: selectedRule.waitingReason) : .disabled
        }
        if newState != state { state = newState }
    }

    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        settings.isEnabled = enabled
        refresh()
    }

    public func selectRule(id: String) {
        selectedRule = catalog.rule(for: id)
        settings.triggerID = selectedRule.id
        refresh()
    }

    public var availableRules: [any TriggerRule] { catalog.all }

    /// Releases the assertion and stops observing. Idempotent; safe on the quit path.
    public func shutdown() {
        pollTask?.cancel()
        pollTask = nil
        if isRunning { displayProvider.stopObserving() }
        isRunning = false
        assertion.release()
        state = .disabled
    }
}
