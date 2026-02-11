//
//  MathGraphLabApp.swift
//  MathGraph Lab
//
//  App entry point
//  Implements IDD requirements for AppState injection and AdMob initialization
//

import SwiftUI

@main
struct MathGraphLabApp: App {
    // IDD: アプリの状態を管理するオブジェクトを初期化
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            // 広告なしでメイン画面（GraphLabView）を直接表示
            GraphLabView()
                .environmentObject(appState)
        }
    }
}
