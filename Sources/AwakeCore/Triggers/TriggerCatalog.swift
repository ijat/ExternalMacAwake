/// The ordered set of selectable trigger rules.
public struct TriggerCatalog: Sendable {
    public let all: [any TriggerRule]
    public let `default`: any TriggerRule

    /// `defaultRule` must be one of `rules`; if it is not, the first rule is used.
    public init(rules: [any TriggerRule], defaultRule: any TriggerRule) {
        precondition(!rules.isEmpty, "TriggerCatalog needs at least one rule")
        self.all = rules
        self.default = rules.first { $0.id == defaultRule.id } ?? rules[0]
    }

    /// The catalog the app ships with.
    public static let standard = TriggerCatalog(
        rules: [ExternalWithBuiltinOffRule(), LidClosedRule(), AnyExternalRule()],
        defaultRule: ExternalWithBuiltinOffRule()
    )

    /// The rule with this ID, or the default for an unknown ID.
    public func rule(for id: String) -> any TriggerRule {
        all.first { $0.id == id } ?? `default`
    }
}
