import AppKit
import AwakeCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var signalSources: [DispatchSourceSignal] = []

    func applicationWillFinishLaunching(_ notification: Notification) {
        // Belt and braces next to LSUIElement: never show a Dock icon.
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let environment = AppEnvironment.shared
        environment.controller.start()
        environment.loginItem.registerOnFirstLaunch(settings: environment.settings)
        installSignalHandlers()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppEnvironment.shared.controller.shutdown()
    }

    /// SIGTERM/SIGINT release the assertion and exit. (The system also drops it when the process dies.)
    private func installSignalHandlers() {
        for number in [SIGTERM, SIGINT] {
            signal(number, SIG_IGN)
            let source = DispatchSource.makeSignalSource(signal: number, queue: .main)
            source.setEventHandler {
                MainActor.assumeIsolated {
                    AppEnvironment.shared.controller.shutdown()
                }
                exit(0)
            }
            source.resume()
            signalSources.append(source)
        }
    }
}
