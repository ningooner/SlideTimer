import SwiftUI

struct TimerDisplay: View {
    @Environment(TimerModel.self)        private var timerModel
    @Environment(AppearanceSettings.self) private var appearance

    @State private var pulseOpacity: Double = 1.0

    private var timerColor: Color {
        if timerModel.isInDangerZone || timerModel.isFinished {
            return Color(red: 1, green: 0.239, blue: 0)  // #FF3D00
        } else if timerModel.isInWarningZone {
            return Color(red: 1, green: 0.569, blue: 0)  // #FF9100
        } else {
            return appearance.timerColor
        }
    }

    private var statusText: String {
        switch timerModel.timerState {
        case .ready:    return "Ready"
        case .running:  return timerModel.isCountdown ? "Running" : "Counting Up"
        case .paused:   return "Paused"
        case .finished: return "Done!"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(timerModel.displayTime)
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(timerColor)
                .opacity(pulseOpacity)
                .onChange(of: timerModel.isFinished) { _, finished in
                    if finished {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            pulseOpacity = 0.3
                        }
                    } else {
                        withAnimation(.default) {
                            pulseOpacity = 1.0
                        }
                    }
                }

            Text(statusText)
                .font(.caption)
                .foregroundStyle(Color(white: 0.6))
                .textCase(.uppercase)
                .tracking(1.5)
                .padding(.top, 2)

            // Progress bar — full at start, drains to empty as time passes
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(white: 0.2))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(timerColor)
                        .frame(width: geo.size.width * max(0, 1.0 - timerModel.progress))
                        .animation(.linear(duration: 0.05), value: timerModel.progress)
                }
                .frame(height: 4)
            }
            .frame(height: 4)
            .padding(.top, 6)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
}
