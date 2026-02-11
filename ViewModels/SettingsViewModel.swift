import SwiftUI
import Foundation
import Combine

/// 設定画面用の ViewModel
/// 注意: 現在は AppState が設定の一元管理を担っているため、
/// このクラスは後方互換性のために残しています。
class SettingsViewModel: ObservableObject {
    // AppState を直接使用するため、このクラスのプロパティは参照用
}
