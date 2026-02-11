import SwiftUI

class ThemeManager {
    static let shared = ThemeManager()
    
    func backgroundColor(for theme: String) -> Color {
        switch theme {
        case "dark": return .black
        case "blackboard": return Color(red: 0, green: 0.3, blue: 0)
        default: return .white
        }
    }
}
