/// At least one external display is lit and the built-in display is off or absent.
public struct ExternalWithBuiltinOffRule: TriggerRule {
    public static let ruleID = "externalWithBuiltinOff"

    public init() {}

    public var id: String { Self.ruleID }
    public var title: String { "External display, built-in off" }
    public var summary: String {
        "An external display is on and the built-in display is off or closed."
    }
    public var waitingReason: String {
        "Waiting for an external display with the built-in display off."
    }

    public func shouldKeepAwake(_ snapshot: SystemSnapshot) -> Bool {
        !snapshot.litExternals.isEmpty && snapshot.builtinIsOff
    }
}

/// An external display is lit and the lid is closed.
public struct LidClosedRule: TriggerRule {
    public static let ruleID = "lidClosed"

    public init() {}

    public var id: String { Self.ruleID }
    public var title: String { "Lid closed" }
    public var summary: String { "An external display is on and the lid is closed." }
    public var waitingReason: String { "Waiting for the lid to close with an external display." }

    public func shouldKeepAwake(_ snapshot: SystemSnapshot) -> Bool {
        !snapshot.litExternals.isEmpty && snapshot.lidClosed == true
    }
}

/// Any external display is lit, whatever the built-in display is doing.
public struct AnyExternalRule: TriggerRule {
    public static let ruleID = "anyExternal"

    public init() {}

    public var id: String { Self.ruleID }
    public var title: String { "Any external display" }
    public var summary: String { "Any external display is connected and on." }
    public var waitingReason: String { "Waiting for an external display." }

    public func shouldKeepAwake(_ snapshot: SystemSnapshot) -> Bool {
        !snapshot.litExternals.isEmpty
    }
}
