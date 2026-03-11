import SwiftUI

// MARK: - ControlWindow

struct ControlWindow: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    TimerDisplay()
                    rowDivider
                    ModeToggleRow()
                    rowDivider
                    TimeInputRow()
                    rowDivider
                    PresetsRow()
                    rowDivider
                    ControlButtonsRow()
                    rowDivider
                    AppearanceRow()
                    rowDivider
                    OverlayRow()
                }
                .padding(16)
            }
            CreditRow()
                .padding(.bottom, 12)
        }
        .frame(minWidth: 380, maxWidth: 520, minHeight: 580, maxHeight: 900)
        .background(Color(red: 0.102, green: 0.102, blue: 0.102))
        .preferredColorScheme(.dark)
    }

    private var rowDivider: some View {
        Divider()
            .background(Color(white: 0.23))
            .padding(.vertical, 10)
    }
}

// MARK: - Credit

private struct CreditRow: View {
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color(white: 0.165)) // #2A2A2A
                .padding(.bottom, 12)

            Text("Created by Bruno Zingg · 2025")
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color(white: 0.333)) // #555555
        }
    }
}


// MARK: - Mode Toggle

private struct ModeToggleRow: View {
    @Environment(TimerModel.self) private var timerModel

    var body: some View {
        @Bindable var tm = timerModel
        HStack {
            sectionLabel("Mode")
            Spacer()
            Picker("Mode", selection: $tm.isCountdown) {
                Text("Countdown").tag(true)
                Text("Stopwatch").tag(false)
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
        }
    }
}

// MARK: - Time Input

private struct TimeInputRow: View {
    @Environment(TimerModel.self) private var timerModel

    @State private var minutesText = "05"
    @State private var secondsText = "00"

    private var isDisabled: Bool {
        !timerModel.isCountdown || timerModel.isRunning
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Duration")
            HStack(spacing: 4) {
                timeField($minutesText)
                Text(":")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.5))
                timeField($secondsText)
            }
            .opacity(isDisabled ? 0.4 : 1.0)
        }
        .onAppear { syncFromModel() }
        .onChange(of: timerModel.targetDuration) { _, _ in syncFromModel() }
    }

    private func timeField(_ text: Binding<String>) -> some View {
        TextField("00", text: text)
            .font(.system(size: 22, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.center)
            .frame(width: 60, height: 44)
            .background(Color(white: 0.173))
            .cornerRadius(8)
            .disabled(isDisabled)
            .onSubmit { applyInput() }
    }

    private func syncFromModel() {
        let total = Int(timerModel.targetDuration)
        minutesText = String(format: "%02d", total / 60)
        secondsText = String(format: "%02d", total % 60)
    }

    private func applyInput() {
        let mins = Int(minutesText) ?? 0
        let secs = min(59, Int(secondsText) ?? 0)
        timerModel.setDuration(minutes: mins, seconds: secs)
    }
}

// MARK: - Presets

private struct PresetsRow: View {
    @Environment(TimerModel.self) private var timerModel

    private let presets = [1, 2, 3, 5, 10, 15, 20, 25]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel("Presets")
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(minimum: 36)), count: 4),
                spacing: 6
            ) {
                ForEach(presets, id: \.self) { minutes in
                    PresetButton(
                        minutes: minutes,
                        isSelected: timerModel.targetDuration == Double(minutes * 60),
                        isDisabled: timerModel.isRunning
                    ) {
                        timerModel.setPreset(minutes: minutes)
                    }
                }
            }
        }
    }
}

// MARK: - Control Buttons

private struct ControlButtonsRow: View {
    @Environment(TimerModel.self) private var timerModel

    var body: some View {
        HStack(spacing: 12) {
            actionButton(
                label: primaryLabel,
                icon: primaryIcon,
                color: primaryColor,
                action: primaryAction
            )
            .keyboardShortcut(.space, modifiers: [])

            actionButton(
                label: "Reset",
                icon: "arrow.counterclockwise",
                color: Color(white: 0.267),
                action: { timerModel.reset() }
            )
            .keyboardShortcut("r", modifiers: .command)
        }
        // Hidden Escape shortcut — stops and resets timer
        .background(
            Button("") { timerModel.reset() }
                .keyboardShortcut(.escape, modifiers: [])
                .opacity(0)
        )
    }

    private func actionButton(
        label: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(color)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private var primaryLabel: String {
        switch timerModel.timerState {
        case .ready, .paused: return "Start"
        case .running:        return "Pause"
        case .finished:       return "Restart"
        }
    }

    private var primaryIcon: String {
        timerModel.isRunning ? "pause.fill" : "play.fill"
    }

    private var primaryColor: Color {
        timerModel.isRunning
            ? Color(red: 1,   green: 0.561, blue: 0)      // amber  #FF8F00
            : Color(red: 0,   green: 0.784, blue: 0.325)  // green  #00C853
    }

    private func primaryAction() {
        if timerModel.isRunning {
            timerModel.pause()
        } else {
            timerModel.start()
        }
    }
}

// MARK: - Appearance

private struct AppearanceRow: View {
    @Environment(AppearanceSettings.self) private var appearance

    private let timerColorPresets: [Color] = [
        .white,
        Color(red: 0,    green: 0.784, blue: 0.325),  // green
        .cyan,
        .orange,
        .red,
        .yellow,
        Color(red: 1,    green: 0.176, blue: 0.333),  // hot pink
    ]

    private let bgColorPresets: [Color] = [
        .black,
        Color(white: 0.15),                                    // dark gray
        Color(red: 0.05, green: 0.05,  blue: 0.2),            // dark blue
        Color(white: 0,  opacity: 0),                          // transparent
    ]

    var body: some View {
        @Bindable var ap = appearance

        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Appearance")

            // Timer color
            HStack {
                Text("Timer Color")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                colorSwatches(presets: timerColorPresets, current: ap.timerColor) {
                    ap.timerColor = $0
                }
                ColorPicker("", selection: $ap.timerColor)
                    .labelsHidden()
                    .frame(width: 26, height: 26)
            }

            // Background color
            HStack {
                Text("Background")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                colorSwatches(presets: bgColorPresets, current: ap.backgroundColor) {
                    ap.backgroundColor = $0
                }
                ColorPicker("", selection: $ap.backgroundColor)
                    .labelsHidden()
                    .frame(width: 26, height: 26)
            }

            // Font size
            HStack {
                Text("Font Size")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                Picker("", selection: $ap.fontSizeCategory) {
                    ForEach(FontSizeCategory.allCases, id: \.self) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 220)
                .labelsHidden()
            }

            // Overlay opacity
            HStack {
                Text("Opacity")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
                Slider(value: $ap.overlayOpacity, in: 0.3...1.0)
                    .frame(width: 150)
                Text("\(Int(ap.overlayOpacity * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(Color(white: 0.6))
                    .frame(width: 38, alignment: .trailing)
            }
        }
    }

    private func colorSwatches(
        presets: [Color],
        current: Color,
        onSelect: @escaping (Color) -> Void
    ) -> some View {
        HStack(spacing: 5) {
            ForEach(Array(presets.enumerated()), id: \.offset) { _, color in
                Circle()
                    .fill(color)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: current == color ? 2 : 0)
                    )
                    .onTapGesture { onSelect(color) }
            }
        }
    }
}

// MARK: - Overlay toggle

private struct OverlayRow: View {
    @Environment(AppearanceSettings.self) private var appearance
    @Environment(TimerModel.self)         private var timerModel

    var body: some View {
        VStack(spacing: 8) {
            Button {
                appearance.showOverlay.toggle()
            } label: {
                Text(appearance.showOverlay ? "Hide Overlay" : "Show Overlay")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .background(
                        appearance.showOverlay
                            ? Color(white: 0.267)
                            : Color(red: 0, green: 0.784, blue: 0.325)
                    )
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("o", modifiers: .command)

            Text("Drag the overlay window onto your presentation screen")
                .font(.caption2)
                .foregroundStyle(Color(white: 0.5))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        // Show / hide the NSPanel when toggle changes
        .onChange(of: appearance.showOverlay) { _, show in
            if show {
                OverlayPanelController.shared.showOverlay(
                    timerModel: timerModel,
                    appearance: appearance
                )
                OverlayPanelController.shared.setOpacity(appearance.overlayOpacity)
            } else {
                OverlayPanelController.shared.hideOverlay()
            }
        }
        // Live opacity updates from the slider
        .onChange(of: appearance.overlayOpacity) { _, opacity in
            OverlayPanelController.shared.setOpacity(opacity)
        }
        // Resize panel when font size category changes
        .onChange(of: appearance.fontSizeCategory) { _, category in
            OverlayPanelController.shared.updateSize(for: category)
        }
    }
}

// MARK: - Shared helpers

private func sectionLabel(_ text: String) -> some View {
    Text(text)
        .font(.caption)
        .foregroundStyle(Color(white: 0.6))
        .textCase(.uppercase)
        .tracking(1.2)
}
