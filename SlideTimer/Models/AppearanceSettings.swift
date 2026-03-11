import SwiftUI
import Observation

enum FontSizeCategory: String, CaseIterable {
    case small  = "Small"
    case medium = "Medium"
    case large  = "Large"
    case xLarge = "XL"

    var overlayFontSize: CGFloat {
        switch self {
        case .small:  return 36
        case .medium: return 54
        case .large:  return 72
        case .xLarge: return 96
        }
    }

    var overlaySize: (width: CGFloat, height: CGFloat) {
        switch self {
        case .small:  return (200, 70)
        case .medium: return (280, 90)
        case .large:  return (360, 110)
        case .xLarge: return (440, 130)
        }
    }
}

@MainActor
@Observable
final class AppearanceSettings {
    var timerColor: Color       = .white
    var backgroundColor: Color  = .black
    var fontSizeCategory: FontSizeCategory = .large
    var overlayOpacity: Double  = 0.9
    var showOverlay: Bool       = false
}
