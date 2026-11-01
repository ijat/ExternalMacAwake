import SwiftUI

/// A pure-SwiftUI switch. Unlike the AppKit-backed one it also renders in `ImageRenderer` previews.
struct SwitchToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer(minLength: 8)
                ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                    Capsule()
                        .fill(
                            configuration.isOn ? Color.accentColor : Color.secondary.opacity(0.35)
                        )
                        .frame(width: 36, height: 20)
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.25), radius: 1, y: 0.5)
                        .frame(width: 16, height: 16)
                        .padding(2)
                }
                .animation(.snappy(duration: 0.15), value: configuration.isOn)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}
