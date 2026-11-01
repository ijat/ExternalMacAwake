import CoreGraphics

@testable import AwakeCore

enum Fixtures {
    static func external(id: CGDirectDisplayID = 2, active: Bool = true, asleep: Bool = false)
        -> DisplayInfo
    {
        DisplayInfo(
            id: id, name: "Studio Display", isBuiltin: false, isActive: active, isAsleep: asleep,
            isMain: false, pixelWidth: 5120, pixelHeight: 2880)
    }

    static func builtin(active: Bool = true, asleep: Bool = false) -> DisplayInfo {
        DisplayInfo(
            id: 1, name: "Built-in Display", isBuiltin: true, isActive: active, isAsleep: asleep,
            isMain: true, pixelWidth: 3456, pixelHeight: 2234)
    }
}

@MainActor
final class FakeDisplayProvider: DisplayProvider {
    var displays: [DisplayInfo] = []
    private(set) var handler: (@MainActor () -> Void)?
    private(set) var stopCount = 0

    func snapshotDisplays() -> [DisplayInfo] { displays }
    func startObserving(_ handler: @escaping @MainActor () -> Void) { self.handler = handler }
    func stopObserving() {
        handler = nil
        stopCount += 1
    }
}

@MainActor
final class FakeLidProvider: LidStateProvider {
    var lidClosed: Bool?
    func isLidClosed() -> Bool? { lidClosed }
}

@MainActor
final class FakeAssertion: PowerAssertion {
    private(set) var isHeld = false
    private(set) var acquireCount = 0
    private(set) var releaseCount = 0
    var failure: Error?

    func acquire(reason: String) throws {
        acquireCount += 1
        if let failure { throw failure }
        isHeld = true
    }

    func release() {
        releaseCount += 1
        isHeld = false
    }
}

@MainActor
final class FakeSettings: SettingsStore {
    var isEnabled = true
    var triggerID = TriggerCatalog.standard.default.id
    var hasRegisteredLoginItem = false
}
