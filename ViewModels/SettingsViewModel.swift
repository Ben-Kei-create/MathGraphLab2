import SwiftUI
import Foundation
import Combine // これを追加

// AppStateのAppTheme定義を使用
extension SettingsViewModel {
    typealias AppTheme = AppState.AppTheme
}

class SettingsViewModel: ObservableObject {
    // 変更を通知するための仕組みを追加
    let objectWillChange = ObservableObjectPublisher()
    
    @AppStorage("isGridSnapEnabled") var isGridSnapEnabled = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isHapticsEnabled") var isHapticsEnabled = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appTheme") var appTheme: AppTheme = .light {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isProEnabled") var isProEnabled = false {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isAdRemoved") var isAdRemoved = false {
        willSet { objectWillChange.send() }
    }
    
    init() {}
}
