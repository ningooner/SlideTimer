import AppKit
import SwiftUI

@MainActor
class OverlayPanelController {
    static let shared = OverlayPanelController()
    private init() {}

    private var panel: NSPanel?

    // MARK: - Public API

    func showOverlay(timerModel: TimerModel, appearance: AppearanceSettings) {
        if panel == nil {
            createPanel(timerModel: timerModel, appearance: appearance)
        }
        panel?.orderFront(nil)
    }

    func hideOverlay() {
        panel?.orderOut(nil)
    }

    func setOpacity(_ opacity: Double) {
        panel?.alphaValue = opacity
    }

    func updateSize(for category: FontSizeCategory) {
        guard let panel = panel else { return }
        let size = category.overlaySize
        var frame = panel.frame
        frame.size = NSSize(width: size.width, height: size.height)
        panel.setFrame(frame, display: true, animate: true)
    }

    // MARK: - Private

    private func createPanel(timerModel: TimerModel, appearance: AppearanceSettings) {
        let size = appearance.fontSizeCategory.overlaySize

        let panel = NSPanel(
            contentRect: NSRect(x: 200, y: 200, width: size.width, height: size.height),
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        // Float above all windows including fullscreen presentations
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Transparent chrome — SwiftUI view provides its own background
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true

        // CRITICAL: false = overlay stays visible when user clicks into PowerPoint/Keynote
        panel.hidesOnDeactivate = false

        // Clicking the overlay must NOT steal focus from the presentation app
        // isMovableByWindowBackground = true lets users drag from anywhere inside
        panel.isMovableByWindowBackground = true
        panel.animationBehavior = .utilityWindow

        panel.alphaValue = appearance.overlayOpacity

        let overlayView = OverlayView()
            .environment(timerModel)
            .environment(appearance)

        panel.contentView = NSHostingView(rootView: overlayView)
        self.panel = panel
    }
}
