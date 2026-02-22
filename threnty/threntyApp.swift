
import SwiftUI

@main
struct threntyApp: App {
    private let timerModel = EyeTimer()
    private let overlayController = OverlayWindowController()

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
        timerModel.onBreakStart = { [overlayController, weak timerModel] in
            guard let timerModel else { return }
            overlayController.show(timerModel: timerModel)
        }
        timerModel.onBreakEnd = { [overlayController] in
            overlayController.dismiss()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverContentView(timerModel: timerModel)
        } label: {
            Text(timerModel.menuBarLabel)
        }
        .menuBarExtraStyle(.window)
    }
}
