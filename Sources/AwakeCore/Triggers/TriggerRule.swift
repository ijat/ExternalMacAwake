/// A condition under which the Mac should be kept awake.
///
/// Add a rule by conforming to this protocol and listing it in `TriggerCatalog`.
public protocol TriggerRule: Sendable {
    /// Stable identifier, persisted in settings.
    var id: String { get }
    /// Short name shown in the picker.
    var title: String { get }
    /// One-line description shown under the title.
    var summary: String { get }
    /// What the app is waiting for while the rule does not hold.
    var waitingReason: String { get }

    func shouldKeepAwake(_ snapshot: SystemSnapshot) -> Bool
}
