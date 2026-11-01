import CoreGraphics

/// A point-in-time description of one online display.
public struct DisplayInfo: Identifiable, Hashable, Sendable {
    public let id: CGDirectDisplayID
    public let name: String
    public let isBuiltin: Bool
    public let isActive: Bool
    public let isAsleep: Bool
    public let isMain: Bool
    public let pixelWidth: Int
    public let pixelHeight: Int

    public init(
        id: CGDirectDisplayID,
        name: String,
        isBuiltin: Bool,
        isActive: Bool,
        isAsleep: Bool,
        isMain: Bool,
        pixelWidth: Int,
        pixelHeight: Int
    ) {
        self.id = id
        self.name = name
        self.isBuiltin = isBuiltin
        self.isActive = isActive
        self.isAsleep = isAsleep
        self.isMain = isMain
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
    }

    /// True when the display is online, drawing and not asleep.
    public var isLit: Bool { isActive && !isAsleep }
}
