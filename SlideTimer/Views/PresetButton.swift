import SwiftUI

struct PresetButton: View {
    let minutes: Int
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)m")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(isSelected ? Color.black : Color.white)
                .frame(maxWidth: .infinity, minHeight: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected
                              ? Color(red: 0, green: 0.784, blue: 0.325)
                              : Color(white: 0.173))
                )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
