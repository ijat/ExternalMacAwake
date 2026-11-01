/// Everything the trigger rules are allowed to look at.
public struct SystemSnapshot: Sendable, Equatable {
    public var displays: [DisplayInfo]
    /// `nil` when the lid state is unknown (no lid, or the key is missing).
    public var lidClosed: Bool?

    public init(displays: [DisplayInfo] = [], lidClosed: Bool? = nil) {
        self.displays = displays
        self.lidClosed = lidClosed
    }

    /// Online displays that are not the built-in panel.
    public var externals: [DisplayInfo] { displays.filter { !$0.isBuiltin } }

    /// The built-in panel, if it is online at all.
    public var builtin: DisplayInfo? { displays.first { $0.isBuiltin } }

    /// External displays that are active and awake.
    public var litExternals: [DisplayInfo] { externals.filter(\.isLit) }

    /// True when the built-in panel is absent, inactive or asleep.
    public var builtinIsOff: Bool { builtin.map { !$0.isLit } ?? true }
}
