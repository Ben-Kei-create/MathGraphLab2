//
//  GraphLabView.swift
//  MathGraph Lab
//
//  Main workspace with banner ad at bottom
//

import SwiftUI

struct GraphLabView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        // ★ここが重要！これがないと上のバーが出ません
        NavigationStack {
            VStack(spacing: 0) {
                // メイングラフエリア
                ZStack {
                    GridBackgroundView()
                    GraphCanvasView()
                    AnalysisOverlayView()
                    MarkedPointsOverlayView()
                    DistanceLinesOverlayView()
                    // ★追加: 数式オーバーレイ
                    EquationOverlayView()
                    // 指移動（パン/ズーム）を有効にするためここに配置
                    TouchInteractionView()
                    
                    VStack {
                        Spacer()
                        ControlPanelOverlay()
                    }
                }
                .background(getBackgroundColor())
                
                // 広告バナーエリア
                if !appState.isAdRemoved {
                    BannerAdView()
                        .frame(height: 60)
                        .background(Color(uiColor: .systemBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MathGraph Lab")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                
                // シェアボタン
                ToolbarItem(placement: .navigationBarLeading) {
                    ShareButton()
                }
                
                // 設定メニュー
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsMenu
                }
            }
        }
    }
    
    private var settingsMenu: some View {
            Menu {
                // --- 一般設定 ---
                Section {
                    Toggle(isOn: $appState.isGridSnapEnabled) {
                        Label("グリッドにスナップ", systemImage: "grid")
                    }
                    Toggle(isOn: $appState.isHapticsEnabled) {
                        Label("触覚フィードバック", systemImage: "hand.tap")
                    }
                    
                    // テーマ切り替え（Pickerだとメニューが閉じるバグがあるためButtonで実装）
                    Menu {
                        ForEach(AppState.AppTheme.allCases) { theme in
                            Button(action: {
                                appState.appTheme = theme
                            }) {
                                if appState.appTheme == theme {
                                    Label(theme.rawValue, systemImage: "checkmark")
                                } else {
                                    Text(theme.rawValue)
                                }
                            }
                        }
                    } label: {
                        Label("テーマ: \(appState.appTheme.rawValue)", systemImage: "paintpalette")
                    }
                }

                // --- リセット ---
                Section {
                    Button(role: .destructive, action: {
                        appState.reset()
                    }) {
                        Label("グラフを初期状態に戻す", systemImage: "arrow.counterclockwise")
                    }
                }
                
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .contentShape(Rectangle()) // タップ判定を安定させる
            }
        }
    
    private func getBackgroundColor() -> Color {
        switch appState.appTheme {
        case .light:
            return Color.white
        case .dark:
            return Color(white: 0.05) // ほぼ黒
        case .blackboard:
            return Color(red: 0.0, green: 0.2, blue: 0.15) // 深みのあるチョークボード色
        }
    }
}

// MARK: - Share Button Component
struct ShareButton: View {
    var body: some View {
        Button(action: shareAction) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    func shareAction() {
        // 現在のウィンドウを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // スクリーンショットを撮影
        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        let image = renderer.image { context in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        // シェアシートを表示
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let rootVC = window.rootViewController {
            // iPad対応: ポップオーバーの位置設定
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = rootVC.view
                popover.sourceRect = CGRect(x: 50, y: 50, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
