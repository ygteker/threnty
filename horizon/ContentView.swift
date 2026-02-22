//
//  ContentView.swift
//  horizon
//

import SwiftUI

struct PopoverContentView: View {
    let timerModel: EyeTimer

    var body: some View {
        VStack(spacing: 12) {
            Text(timerModel.phaseLabel)
                .font(.headline)

            if timerModel.phase != .idle {
                Text(timerModel.menuBarLabel)
                    .font(.system(.title2, design: .monospaced))
                    .foregroundStyle(.secondary)
            }

            Button(timerModel.phase == .idle ? "Start" : "Stop") {
                timerModel.toggle()
            }
            .keyboardShortcut(.defaultAction)

            Divider()

            Button("Quit Horizon") {
                NSApp.terminate(nil)
            }
            .foregroundStyle(.red)
        }
        .padding(16)
        .frame(width: 200)
    }
}
