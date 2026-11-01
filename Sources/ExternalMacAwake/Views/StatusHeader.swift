import AwakeCore
import SwiftUI

struct StatusHeader: View {
    let state: AwakeState
    let rule: any TriggerRule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "display")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text("ExternalMacAwake")
                    .font(.headline)
                Spacer()
                StatePill(state: state)
            }
            Text(explanation)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("state-explanation")
        }
        .accessibilityElement(children: .combine)
    }

    private var explanation: String {
        switch state {
        case .active: "Keeping the display awake: \(rule.title.lowercased())."
        case .waiting(let reason): reason
        case .disabled: "Keep awake is off. Your Mac sleeps as usual."
        case .error(let message): message
        }
    }
}

struct StatePill: View {
    let state: AwakeState

    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(color.opacity(0.16), in: Capsule())
        .foregroundStyle(color)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Status: \(label)")
    }

    private var label: String {
        switch state {
        case .active: "Awake"
        case .waiting: "Waiting"
        case .disabled: "Off"
        case .error: "Error"
        }
    }

    private var color: Color {
        switch state {
        case .active: .green
        case .waiting: .orange
        case .disabled: .secondary
        case .error: .red
        }
    }
}
