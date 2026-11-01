import AwakeCore
import SwiftUI

/// Long-lived objects shared by the SwiftUI scene and the app delegate.
@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()

    let settings: any SettingsStore
    let controller: AwakeController
    let loginItem: LoginItemModel

    private init() {
        let settings = UserDefaultsSettingsStore()
        self.settings = settings
        controller = AwakeController(
            displayProvider: CoreGraphicsDisplayProvider(),
            lidProvider: IOKitLidStateProvider(),
            assertion: IOPMDisplaySleepAssertion(),
            settings: settings)
        loginItem = LoginItemModel(service: SMAppServiceLoginItem())
    }
}

struct ExternalMacAwakeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    private let environment = AppEnvironment.shared

    var body: some Scene {
        MenuBarExtra {
            PopoverView(controller: environment.controller, loginItem: environment.loginItem)
        } label: {
            Image(nsImage: StatusIcon.image(for: environment.controller.state))
                .accessibilityLabel("ExternalMacAwake")
        }
        .menuBarExtraStyle(.window)
    }
}
