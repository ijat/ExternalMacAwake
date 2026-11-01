import Foundation

/// Persistent user settings.
@MainActor
public protocol SettingsStore: AnyObject {
    var isEnabled: Bool { get set }
    var triggerID: String { get set }
    var hasRegisteredLoginItem: Bool { get set }
}

@MainActor
public final class UserDefaultsSettingsStore: SettingsStore {
    public static let keyPrefix = "my.ijat.ExternalMacAwake."

    private let defaults: UserDefaults
    private let defaultTriggerID: String

    public init(
        defaults: UserDefaults = .standard,
        defaultTriggerID: String = TriggerCatalog.standard.default.id
    ) {
        self.defaults = defaults
        self.defaultTriggerID = defaultTriggerID
    }

    private func key(_ name: String) -> String { Self.keyPrefix + name }

    public var isEnabled: Bool {
        get { defaults.object(forKey: key("isEnabled")) as? Bool ?? true }
        set { defaults.set(newValue, forKey: key("isEnabled")) }
    }

    public var triggerID: String {
        get { defaults.string(forKey: key("triggerID")) ?? defaultTriggerID }
        set { defaults.set(newValue, forKey: key("triggerID")) }
    }

    public var hasRegisteredLoginItem: Bool {
        get { defaults.bool(forKey: key("hasRegisteredLoginItem")) }
        set { defaults.set(newValue, forKey: key("hasRegisteredLoginItem")) }
    }
}
