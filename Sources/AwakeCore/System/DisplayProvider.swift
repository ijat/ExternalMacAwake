import AppKit
import CoreGraphics

/// Reads the online displays and reports when they change.
@MainActor
public protocol DisplayProvider: AnyObject {
    func snapshotDisplays() -> [DisplayInfo]
    /// Calls `handler` (on the main actor) after any display change. Replaces a previous handler.
    func startObserving(_ handler: @escaping @MainActor () -> Void)
    func stopObserving()
}

/// Retained C context for the CoreGraphics reconfiguration callback.
private final class CallbackBox: @unchecked Sendable {
    let handler: @MainActor () -> Void
    init(_ handler: @escaping @MainActor () -> Void) { self.handler = handler }
}

private let reconfigurationCallback: CGDisplayReconfigurationCallBack = { _, flags, userInfo in
    // Each change is reported twice; act once, after the configuration is applied.
    guard !flags.contains(.beginConfigurationFlag), let userInfo else { return }
    let box = Unmanaged<CallbackBox>.fromOpaque(userInfo).takeUnretainedValue()
    Task { @MainActor in box.handler() }
}

@MainActor
public final class CoreGraphicsDisplayProvider: DisplayProvider {
    private var box: Unmanaged<CallbackBox>?
    private var observers: [NSObjectProtocol] = []

    public init() {}

    isolated deinit {
        stopObserving()
    }

    public func snapshotDisplays() -> [DisplayInfo] {
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(0, nil, &count) == .success, count > 0 else { return [] }
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetOnlineDisplayList(count, &ids, &count) == .success else { return [] }

        let names = screenNames()
        return ids.prefix(Int(count)).map { id in
            let builtin = CGDisplayIsBuiltin(id) != 0
            return DisplayInfo(
                id: id,
                name: names[id] ?? (builtin ? "Built-in Display" : "Display \(id)"),
                isBuiltin: builtin,
                isActive: CGDisplayIsActive(id) != 0,
                isAsleep: CGDisplayIsAsleep(id) != 0,
                isMain: CGDisplayIsMain(id) != 0,
                pixelWidth: CGDisplayPixelsWide(id),
                pixelHeight: CGDisplayPixelsHigh(id)
            )
        }
    }

    public func startObserving(_ handler: @escaping @MainActor () -> Void) {
        stopObserving()
        let newBox = Unmanaged.passRetained(CallbackBox(handler))
        box = newBox
        CGDisplayRegisterReconfigurationCallback(reconfigurationCallback, newBox.toOpaque())

        // Display sleep/wake does not always trigger a reconfiguration.
        let workspace = NSWorkspace.shared.notificationCenter
        for name in [NSWorkspace.screensDidSleepNotification, NSWorkspace.screensDidWakeNotification] {
            observers.append(
                workspace.addObserver(forName: name, object: nil, queue: .main) { _ in
                    MainActor.assumeIsolated { handler() }
                })
        }
        observers.append(
            NotificationCenter.default.addObserver(
                forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
            ) { _ in
                MainActor.assumeIsolated { handler() }
            })
    }

    public func stopObserving() {
        if let box {
            CGDisplayRemoveReconfigurationCallback(reconfigurationCallback, box.toOpaque())
            box.release()
            self.box = nil
        }
        for observer in observers {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }

    private func screenNames() -> [CGDirectDisplayID: String] {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        var result: [CGDirectDisplayID: String] = [:]
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[key] as? NSNumber {
                result[CGDirectDisplayID(number.uint32Value)] = screen.localizedName
            }
        }
        return result
    }
}
