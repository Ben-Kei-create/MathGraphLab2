import UIKit

// MARK: - Haptic Manager
/// Singleton for managing haptic feedback
class HapticManager {
    static let shared = HapticManager()
    
    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    private init() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        notificationGenerator.prepare()
    }
    
    /// Trigger impact feedback
    /// - Parameter style: The feedback style
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            lightGenerator.impactOccurred()
            lightGenerator.prepare()
        case .medium:
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare()
        case .heavy:
            heavyGenerator.impactOccurred()
            heavyGenerator.prepare()
        case .soft:
            softGenerator.impactOccurred()
            softGenerator.prepare()
        case .rigid:
            rigidGenerator.impactOccurred()
            rigidGenerator.prepare()
        @unknown default:
            // 未知のスタイルが追加された場合は中程度で対応
            mediumGenerator.impactOccurred()
            mediumGenerator.prepare()
        }
    }

    /// 通知フィードバック（成功/警告/エラー）
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
        notificationGenerator.prepare()
    }
}
