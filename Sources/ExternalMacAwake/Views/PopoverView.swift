import AppKit
import AwakeCore
import SwiftUI

struct PopoverView: View {
    let controller: AwakeController
    let loginItem: LoginItemModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            StatusHeader(state: controller.state, rule: controller.selectedRule)

            Card(title: "Displays") {
                if controller.snapshot.displays.isEmpty {
                    Text("No displays found.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(controller.snapshot.displays) { DisplayRow(display: $0) }
                    }
                }
            }

            Card {
                SettingsSection(controller: controller, loginItem: loginItem)
            }

            Footer()
        }
        .padding(16)
        .frame(width: 320)
    }
}

private struct Card<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title { SectionLabel(title) }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            .quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct Footer: View {
    var body: some View {
        HStack {
            Text("Version \(Self.version)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                HStack(spacing: 6) {
                    Text("Quit")
                    Text("⌘Q").foregroundStyle(.secondary)
                }
                .font(.callout)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.18), in: Capsule())
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q")
            .accessibilityLabel("Quit")
            .accessibilityHint("Releases the keep-awake request and quits")
        }
    }

    private static let version: String =
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "dev"
}
