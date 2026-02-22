//
//  BreakOverlayView.swift
//  horizon
//

import SwiftUI

struct BreakOverlayView: View {
    let timerModel: EyeTimer

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Image(systemName: "eye")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

                Text("Look 20 meters away")
                    .font(.title)
                    .foregroundStyle(.white)

                Text("\(timerModel.secondsRemaining)")
                    .font(.system(size: 96, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.default, value: timerModel.secondsRemaining)

                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 400, height: 8)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: 400 * timerModel.breakProgress, height: 8)
                            .animation(.linear(duration: 1), value: timerModel.breakProgress)
                    }

                Button("Skip") {
                    timerModel.skipBreak()
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(0.5))
                .font(.callout)
            }
            .padding(60)
        }
    }
}
