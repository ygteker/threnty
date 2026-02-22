
import AppKit
import SwiftUI

final class OverlayWindowController {
    private var panels: [NSPanel] = []

    func show(timerModel: EyeTimer) {
        guard panels.isEmpty else { return }

        for screen in NSScreen.screens {
            let panel = NSPanel(
                contentRect: screen.frame,
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.level = .screenSaver
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.ignoresMouseEvents = false
            panel.contentView = NSHostingView(rootView: BreakOverlayView(timerModel: timerModel))
            panel.setFrame(screen.frame, display: true)
            panel.orderFrontRegardless()
            panels.append(panel)
        }
    }

    func dismiss() {
        panels.forEach { $0.orderOut(nil) }
        panels.removeAll()
    }
}
