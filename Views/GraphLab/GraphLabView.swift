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

                // テーマ切り替えボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    ThemeToggleButton(appTheme: $appState.appTheme)
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
                    
                    // テーマ切り替え
                    Menu {
                        Picker("テーマ", selection: $appState.appTheme) {
                            ForEach(AppState.AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                    } label: {
                        Label("テーマ: \(appState.appTheme.rawValue)", systemImage: "paintpalette")
                    }
                }

                // --- 課金・サポート ---
                Section {
                    Button(action: {
                        // TODO: 実際の課金処理（StoreKit）
                        print("広告削除ボタン押下")
                    }) {
                        Label("広告を非表示にする (課金)", systemImage: "megaphone.slash")
                    }
                    
                    Button(action: {
                        // 募金ページ（例としてGoogleを指定していますが、自身のURLに変更してください）
                        if let url = URL(string: "https://www.google.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("開発者を応援する (募金)", systemImage: "heart.circle")
                    }
                }

                // --- サポート・情報 (ここが本番！) ---
                Section {
                    Button(action: {
                        // お問い合わせフォームなどのURL
                        if let url = URL(string: "https://forms.gle/your-form-url") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("お問い合わせ", systemImage: "envelope")
                    }
                    
                    Button(action: {
                        // プライバシーポリシーのURL
                        if let url = URL(string: "https://your-site.com/privacy") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("プライバシーポリシー", systemImage: "doc.text")
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

// MARK: - Theme Toggle Button Component
struct ThemeToggleButton: View {
    @Binding var appTheme: AppState.AppTheme
    @Environment(\.colorScheme) var systemColorScheme

    var body: some View {
        Button(action: cycleTheme) {
            Image(systemName: themeIcon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.accentColor)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("テーマ切り替え")
        .accessibilityValue(appTheme.rawValue)
    }

    private var themeIcon: String {
        switch appTheme {
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        case .blackboard:
            return "square.fill"
        }
    }

    private func cycleTheme() {
        let themes = AppState.AppTheme.allCases
        if let currentIndex = themes.firstIndex(of: appTheme) {
            let nextIndex = (currentIndex + 1) % themes.count
            appTheme = themes[nextIndex]
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
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
