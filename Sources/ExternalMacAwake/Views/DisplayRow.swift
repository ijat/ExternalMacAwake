import AwakeCore
import SwiftUI

struct DisplayRow: View {
    let display: DisplayInfo

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: display.isBuiltin ? "laptopcomputer" : "display")
                .font(.title3)
                .frame(width: 26)
                .foregroundStyle(display.isLit ? Color.accentColor : Color.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 3) {
                Text(display.name)
                    .font(.callout.weight(.medium))
                    .lineLimit(1)
                    .truncationMode(.tail)
                HStack(spacing: 5) {
                    Text(verbatim: "\(display.pixelWidth) × \(display.pixelHeight)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    ForEach(tags, id: \.self) { TagView(text: $0) }
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(display.name), \(display.pixelWidth) by \(display.pixelHeight)"
                + (tags.isEmpty ? "" : ", " + tags.joined(separator: ", ")))
    }

    private var tags: [String] {
        var result: [String] = []
        if display.isBuiltin { result.append("Built-in") }
        if display.isMain { result.append("Main") }
        if display.isAsleep {
            result.append("Asleep")
        } else if !display.isActive {
            result.append("Inactive")
        }
        return result
    }
}

private struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .padding(.horizontal, 5)
            .padding(.vertical, 1)
            .background(.secondary.opacity(0.18), in: Capsule())
            .foregroundStyle(.secondary)
    }
}
