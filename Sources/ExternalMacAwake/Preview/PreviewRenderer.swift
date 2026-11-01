import AppKit
import AwakeCore
import SwiftUI

/// Renders the popover with fixture data to PNGs, offscreen (no screen capture).
@MainActor
enum PreviewRenderer {
    private struct Scenario {
        let name: String
        let displays: [DisplayInfo]
        let enabled: Bool
    }

    static func run(outputDirectory: URL) -> Int32 {
        do {
            try FileManager.default.createDirectory(
                at: outputDirectory, withIntermediateDirectories: true)
        } catch {
            FileHandle.standardError.write(
                Data("cannot create \(outputDirectory.path): \(error)\n".utf8))
            return 73
        }

        let scenarios = [
            Scenario(
                name: "active",
                displays: [PreviewData.studio, PreviewData.macbook(asleep: true)], enabled: true),
            Scenario(
                name: "waiting",
                displays: [PreviewData.studio, PreviewData.macbook(asleep: false)], enabled: true),
            Scenario(
                name: "disabled",
                displays: [PreviewData.studio, PreviewData.macbook(asleep: true)], enabled: false),
        ]

        var failures = 0
        for scenario in scenarios {
            for scheme in [ColorScheme.light, .dark] {
                let name = "\(scenario.name)-\(scheme == .dark ? "dark" : "light").png"
                if render(
                    scenario, scheme: scheme, to: outputDirectory.appendingPathComponent(name))
                {
                    print("wrote \(name)")
                } else {
                    failures += 1
                    FileHandle.standardError.write(Data("failed to render \(name)\n".utf8))
                }
            }
        }
        return failures == 0 ? 0 : 1
    }

    private static func render(_ scenario: Scenario, scheme: ColorScheme, to url: URL) -> Bool {
        let settings = PreviewSettings(isEnabled: scenario.enabled)
        let controller = AwakeController(
            displayProvider: PreviewDisplays(scenario.displays),
            lidProvider: PreviewLid(),
            assertion: PreviewAssertion(),
            settings: settings,
            pollInterval: nil)
        controller.start()
        let loginItem = LoginItemModel(service: PreviewLoginItem())

        // Offscreen there is no window material, so draw the window background by hand.
        let background = scheme == .dark ? Color(white: 0.17) : Color(white: 0.96)
        let view = PopoverView(controller: controller, loginItem: loginItem)
            .background(background)
            .environment(\.colorScheme, scheme)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage, let tiff = image.tiffRepresentation,
            let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:])
        else { return false }
        do {
            try png.write(to: url)
            controller.shutdown()
            return true
        } catch {
            return false
        }
    }
}

private enum PreviewData {
    static let studio = DisplayInfo(
        id: 2, name: "Studio Display", isBuiltin: false, isActive: true, isAsleep: false,
        isMain: false, pixelWidth: 5120, pixelHeight: 2880)

    static func macbook(asleep: Bool) -> DisplayInfo {
        DisplayInfo(
            id: 1, name: "Built-in Retina Display", isBuiltin: true, isActive: true,
            isAsleep: asleep,
            isMain: true, pixelWidth: 3456, pixelHeight: 2234)
    }
}

@MainActor private final class PreviewDisplays: DisplayProvider {
    let displays: [DisplayInfo]
    init(_ displays: [DisplayInfo]) { self.displays = displays }
    func snapshotDisplays() -> [DisplayInfo] { displays }
    func startObserving(_ handler: @escaping @MainActor () -> Void) {}
    func stopObserving() {}
}

@MainActor private final class PreviewLid: LidStateProvider {
    func isLidClosed() -> Bool? { false }
}

@MainActor private final class PreviewAssertion: PowerAssertion {
    private(set) var isHeld = false
    func acquire(reason: String) throws { isHeld = true }
    func release() { isHeld = false }
}

@MainActor private final class PreviewSettings: SettingsStore {
    var isEnabled: Bool
    var triggerID = TriggerCatalog.standard.default.id
    var hasRegisteredLoginItem = true
    init(isEnabled: Bool) { self.isEnabled = isEnabled }
}

@MainActor private final class PreviewLoginItem: LoginItemService {
    var status: LoginItemStatus = .enabled
    func setEnabled(_ enabled: Bool) throws {}
    func openSystemSettings() {}
}
