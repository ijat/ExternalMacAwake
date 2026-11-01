import AwakeCore
import Foundation
import Observation
import ServiceManagement

enum LoginItemStatus: Equatable {
    case enabled
    case requiresApproval
    case disabled
    /// Not running from an app bundle (for example `swift run`).
    case unavailable
}

@MainActor
protocol LoginItemService: AnyObject {
    var status: LoginItemStatus { get }
    func setEnabled(_ enabled: Bool) throws
    func openSystemSettings()
}

@MainActor
final class SMAppServiceLoginItem: LoginItemService {
    private var service: SMAppService { .mainApp }

    var status: LoginItemStatus {
        guard Bundle.main.bundleIdentifier != nil, Bundle.main.bundlePath.hasSuffix(".app") else {
            return .unavailable
        }
        switch service.status {
        case .enabled: return .enabled
        case .requiresApproval: return .requiresApproval
        case .notRegistered, .notFound: return .disabled
        @unknown default: return .disabled
        }
    }

    func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try service.register()
        } else {
            try service.unregister()
        }
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}

/// Observable wrapper the views bind to. Failures are shown inline and never fatal.
@MainActor
@Observable
final class LoginItemModel {
    private(set) var status: LoginItemStatus
    private(set) var errorMessage: String?

    @ObservationIgnored private let service: any LoginItemService

    init(service: any LoginItemService) {
        self.service = service
        self.status = service.status
    }

    var isOn: Bool { status == .enabled || status == .requiresApproval }
    var isAvailable: Bool { status != .unavailable }

    /// Re-reads the status from the system. Leaves `errorMessage` alone so a failure stays visible.
    func refresh() { status = service.status }

    func setEnabled(_ enabled: Bool) {
        do {
            try service.setEnabled(enabled)
            errorMessage = nil
        } catch {
            errorMessage =
                "Could not \(enabled ? "enable" : "disable") launch at login: \(error.localizedDescription)"
        }
        status = service.status
    }

    /// Registers once, on the first launch of a bundled app, then remembers that it did.
    func registerOnFirstLaunch(settings: any SettingsStore) {
        status = service.status
        guard !settings.hasRegisteredLoginItem, status != .unavailable else { return }
        if status != .enabled { setEnabled(true) }
        if errorMessage == nil { settings.hasRegisteredLoginItem = true }
    }

    func openSystemSettings() { service.openSystemSettings() }
}
