import SwiftUI
import Foundation
import Combine // これを追加

class SettingsViewModel: ObservableObject {
    // 変更を通知するための仕組みを追加
    let objectWillChange = ObservableObjectPublisher()
    
    @AppStorage("isGridSnapEnabled") var isGridSnapEnabled = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isHapticsEnabled") var isHapticsEnabled = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("appTheme") var appTheme: AppState.AppTheme = .light {
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
