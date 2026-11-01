import AppKit
import AwakeCore

/// Draws the menu-bar glyph as a template image: a display, plus a badge for the state.
@MainActor
enum StatusIcon {
    static func image(for state: AwakeState) -> NSImage {
        let size = NSSize(width: 22, height: 16)
        let image = NSImage(size: size, flipped: false) { rect in
            let displayConfig = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            guard
                let display = NSImage(systemSymbolName: "display", accessibilityDescription: nil)?
                    .withSymbolConfiguration(displayConfig)
            else { return true }

            let alpha: CGFloat
            switch state {
            case .disabled: alpha = 0.45
            case .waiting, .active, .error: alpha = 1
            }
            let displayRect = NSRect(
                x: 0, y: (rect.height - display.size.height) / 2,
                width: display.size.width, height: display.size.height)
            display.draw(in: displayRect, from: .zero, operation: .sourceOver, fraction: alpha)

            let badgeName: String?
            switch state {
            case .active: badgeName = "bolt.fill"
            case .error: badgeName = "exclamationmark.triangle.fill"
            case .disabled: badgeName = "slash.circle"
            case .waiting: badgeName = nil
            }
            if let badgeName,
                let badge = NSImage(systemSymbolName: badgeName, accessibilityDescription: nil)?
                    .withSymbolConfiguration(.init(pointSize: 9, weight: .bold))
            {
                let badgeRect = NSRect(
                    x: rect.width - badge.size.width, y: 0,
                    width: badge.size.width, height: badge.size.height)
                // Knock out the display behind the badge so it stays legible.
                NSGraphicsContext.current?.saveGraphicsState()
                NSGraphicsContext.current?.compositingOperation = .clear
                NSBezierPath(ovalIn: badgeRect.insetBy(dx: -1.5, dy: -1.5)).fill()
                NSGraphicsContext.current?.restoreGraphicsState()
                badge.draw(in: badgeRect, from: .zero, operation: .sourceOver, fraction: 1)
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "ExternalMacAwake"
        return image
    }
}
