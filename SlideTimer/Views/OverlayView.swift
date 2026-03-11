import SwiftUI

struct OverlayView: View {
    @Environment(TimerModel.self)         private var timerModel
    @Environment(AppearanceSettings.self) private var appearance

    // Flash state — driven by .onReceive timer when finished
    @State private var flashOn      = false
    @State private var isFlashing   = false
    @State private var flashCount   = 0

    // Timer publisher used only during flash sequence
    private let flashPublisher = Timer.publish(every: 0.25, on: .main, in: .common).autoconnect()

    // MARK: - Derived colors

    private var effectiveTimerColor: Color {
        if timerModel.isFinished {
            return flashOn ? .white : Color(red: 1, green: 0.239, blue: 0)
        } else if timerModel.isInDangerZone {
            return Color(red: 1, green: 0.239, blue: 0)   // #FF3D00
        } else if timerModel.isInWarningZone {
            return Color(red: 1, green: 0.569, blue: 0)   // #FF9100
        } else {
            return appearance.timerColor
        }
    }

    private var effectiveBackground: Color {
        if timerModel.isFinished && flashOn {
            return Color(red: 1, green: 0.239, blue: 0)   // red flash background
        }
        return appearance.backgroundColor
    }

    // MARK: - Body

    var body: some View {
        Text(timerModel.displayTime)
            .font(.system(
                size: appearance.fontSizeCategory.overlayFontSize,
                weight: .bold,
                design: .monospaced
            ))
            .foregroundStyle(effectiveTimerColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(effectiveBackground)
            )
            .shadow(color: .black.opacity(0.45), radius: 8)
            .animation(.easeInOut(duration: 0.15), value: flashOn)
            .animation(.easeInOut(duration: 0.2), value: effectiveTimerColor)
            // Flash tick — fires 4x/sec; only does work while isFlashing
            .onReceive(flashPublisher) { _ in
                guard isFlashing else { return }
                flashCount += 1
                flashOn.toggle()
                if flashCount >= 12 {
                    // Settle: 12 toggles (even) → back to false = normal bg + red text
                    isFlashing = false
                    flashOn    = false
                    flashCount = 0
                }
            }
            // Start/stop flash when timer finishes or resets
            .onChange(of: timerModel.isFinished) { _, finished in
                if finished {
                    flashCount = 0
                    flashOn    = false
                    isFlashing = true
                } else {
                    isFlashing = false
                    flashOn    = false
                    flashCount = 0
                }
            }
    }
}
