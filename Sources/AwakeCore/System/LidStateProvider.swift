import IOKit

/// Reads whether the laptop lid is closed.
@MainActor
public protocol LidStateProvider: AnyObject {
    /// `nil` when the state cannot be read (desktop Mac, missing key).
    func isLidClosed() -> Bool?
}

@MainActor
public final class IOKitLidStateProvider: LidStateProvider {
    public init() {}

    public func isLidClosed() -> Bool? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))
        guard service != IO_OBJECT_NULL else { return nil }
        defer { IOObjectRelease(service) }

        guard
            let property = IORegistryEntryCreateCFProperty(
                service, "AppleClamshellState" as CFString, kCFAllocatorDefault, 0)
        else { return nil }
        let value = property.takeRetainedValue()
        guard CFGetTypeID(value) == CFBooleanGetTypeID() else { return nil }
        return CFBooleanGetValue((value as! CFBoolean))
    }
}
