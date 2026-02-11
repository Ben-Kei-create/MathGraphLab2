//
//  MathGraphLabApp.swift
//  MathGraph Lab
//
//  App entry point
//

import SwiftUI
import GoogleMobileAds

@main
struct MathGraphLabApp: App {
    // IDD: アプリの状態を管理するオブジェクトを初期化
    @StateObject private var appState = AppState()
    
    // アプリ起動時の初期化処理
    init() {
        // エラー修正:
        // 旧: GADMobileAds.sharedInstance().start(completionHandler: nil)
        // 新: MobileAds.shared.start(completionHandler: nil)
        MobileAds.shared.start(completionHandler: nil)
    }
    
    var body: some Scene {
        WindowGroup {
            // メイン画面（GraphLabView）を表示
            GraphLabView()
                .environmentObject(appState)
        }
    }
}
