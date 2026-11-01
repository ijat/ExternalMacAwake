import Foundation
import IOKit.pwr_mgt

/// A held request to the system to keep the display awake. Acquire and release are idempotent.
@MainActor
public protocol PowerAssertion: AnyObject {
    var isHeld: Bool { get }
    func acquire(reason: String) throws
    func release()
}

public struct PowerAssertionError: Error, LocalizedError, Equatable {
    public let code: Int32

    public init(code: Int32) { self.code = code }

    public var errorDescription: String? {
        "The system refused the keep-awake request (IOReturn \(code))."
    }
}

/// Prevents idle display sleep through IOKit. The system drops it if the process exits or crashes.
@MainActor
public final class IOPMDisplaySleepAssertion: PowerAssertion {
    public static let assertionName = "ExternalMacAwake: keeping external display awake"

    private var assertionID: IOPMAssertionID = IOPMAssertionID(kIOPMNullAssertionID)
    private var held = false

    public init() {}

    isolated deinit {
        release()
    }

    public var isHeld: Bool { held }

    public func acquire(reason: String) throws {
        guard !held else { return }
        var id = IOPMAssertionID(kIOPMNullAssertionID)
        let result = IOPMAssertionCreateWithDescription(
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString,
            Self.assertionName as CFString,
            reason as CFString,
            nil, nil, 0, nil,
            &id)
        guard result == kIOReturnSuccess else { throw PowerAssertionError(code: result) }
        assertionID = id
        held = true
    }

    public func release() {
        guard held else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = IOPMAssertionID(kIOPMNullAssertionID)
        held = false
    }
}
