import AwakeCore
import SwiftUI

struct SettingsSection: View {
    let controller: AwakeController
    let loginItem: LoginItemModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(
                "Keep awake",
                isOn: Binding(get: { controller.isEnabled }, set: { controller.setEnabled($0) })
            )
            .toggleStyle(SwitchToggleStyle())
            .font(.callout.weight(.medium))

            VStack(alignment: .leading, spacing: 4) {
                SectionLabel("Trigger")
                ForEach(controller.availableRules, id: \.id) { rule in
                    TriggerOption(
                        rule: rule,
                        isSelected: rule.id == controller.selectedRule.id,
                        isEnabled: controller.isEnabled
                    ) { controller.selectRule(id: rule.id) }
                }
            }

            if loginItem.isAvailable {
                VStack(alignment: .leading, spacing: 4) {
                    Toggle(
                        "Launch at login",
                        isOn: Binding(get: { loginItem.isOn }, set: { loginItem.setEnabled($0) })
                    )
                    .toggleStyle(SwitchToggleStyle())
                    .font(.callout.weight(.medium))
                    if loginItem.status == .requiresApproval {
                        HStack(spacing: 4) {
                            Text("Approve it in System Settings.")
                            Button("Open") { loginItem.openSystemSettings() }
                                .buttonStyle(.link)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            if let message = loginItem.errorMessage {
                Label(message, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(0.6)
    }
}

private struct TriggerOption: View {
    let rule: any TriggerRule
    let isSelected: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                    .padding(.top, 1)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 1) {
                    Text(rule.title).font(.callout)
                    Text(rule.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.55)
        .accessibilityLabel("\(rule.title). \(rule.summary)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
