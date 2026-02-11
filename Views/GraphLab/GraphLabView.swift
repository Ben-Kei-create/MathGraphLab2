//
//  GraphLabView.swift
//  MathGraph Lab
//
//  Main interactive workspace that orchestrates all graph layers
//  Implements IDD Section 3.1 and 3.2 (Graph Lab View Structure)
//

import SwiftUI
// import GoogleMobileAds

// MARK: - Graph Lab View
/// Main workspace view that stacks all interactive layers
/// IDD Section 3.2: ZStack Layering (5 layers + controls + ads)
struct GraphLabView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. 最奥：背景
                GridBackgroundView()
                
                // 2. 中層：グラフと解析結果
                GraphCanvasView()
                AnalysisOverlayView()
                MarkedPointsOverlayView()
                DistanceLinesOverlayView()
                
                // 3. 【修正】タッチ操作レイヤー
                // これをパネルの下（手前）に持ってくることで、グラフエリアのタップが有効になります
                TouchInteractionView()
                
                // 4. 最前面：操作パネル（UI）
                VStack {
                    Spacer()
                    ControlPanelOverlay()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("MathGraph Lab")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    ShareButton().environmentObject(appState)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    settingsMenu
                }
            }
        }
    }
    
    // Settings Menu Component
    private var settingsMenu: some View {
        Menu {
            Toggle(isOn: $appState.isGridSnapEnabled) {
                Label("Snap to Grid", systemImage: "grid")
            }
            
            Toggle(isOn: $appState.isHapticsEnabled) {
                Label("Haptics", systemImage: "hand.tap")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.system(size: 18))
        }
    }
    
    // MARK: - Helper Methods
    
    /// Get background color based on current theme
    private func getBackgroundColor() -> Color {
        switch appState.appTheme {
        case "dark":
            return Color.black
        case "blackboard":
            return Color(red: 0, green: 0.3, blue: 0)  // Dark green #004d00
        default:  // "light"
            return Color.white
        }
    }
    
    /// グラフを画像として共有
    private func shareGraphImage() {
        // ImageRenderer を使用してグラフをキャプチャ
        let renderer = ImageRenderer(content: graphContentForExport)
        renderer.scale = 3.0  // 高解像度
        
        if let image = renderer.uiImage {
            // 共有シートを表示
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .medium)
            }
            
            print("📤 画像を共有")
        }
    }

    /// 写真ライブラリに保存
    private func saveToPhotoLibrary() {
        let renderer = ImageRenderer(content: graphContentForExport)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .heavy)
            }
            
            print("💾 写真に保存しました")
        }
    }

    /// 書き出し用のグラフコンテンツ（UI要素を除外）
    private var graphContentForExport: some View {
        ZStack {
            GridBackgroundView()
            GraphCanvasView()
            AnalysisOverlayView()
            MarkedPointsOverlayView()
            DistanceLinesOverlayView()
            
            // ウォーターマーク
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("MathGraph Lab")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(16)
                }
            }
        }
        .frame(width: 1200, height: 1200)
        .environmentObject(appState)
    }
}

// MARK: - Share Button Component
struct ShareButton: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Menu {
            Button(action: {
                shareGraphImage()
            }) {
                Label("画像として共有", systemImage: "square.and.arrow.up")
            }
            
            Button(action: {
                saveToPhotoLibrary()
            }) {
                Label("写真に保存", systemImage: "photo.on.rectangle")
            }
        } label: {
            Image(systemName: "square.and.arrow.up.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.blue)
        }
    }
    
    /// グラフを画像として共有
    private func shareGraphImage() {
        let renderer = ImageRenderer(content: graphContentForExport)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            let activityVC = UIActivityViewController(
                activityItems: [image],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
            
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .medium)
            }
        }
    }

    /// 写真ライブラリに保存
    private func saveToPhotoLibrary() {
        let renderer = ImageRenderer(content: graphContentForExport)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .heavy)
            }
        }
    }

    /// 書き出し用のグラフコンテンツ
    private var graphContentForExport: some View {
        ZStack {
            GridBackgroundView()
            GraphCanvasView()
            AnalysisOverlayView()
            MarkedPointsOverlayView()
            DistanceLinesOverlayView()
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("MathGraph Lab")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(16)
                }
            }
        }
        .frame(width: 1200, height: 1200)
        .environmentObject(appState)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GraphLabView()
            .environmentObject(AppState())
    }
}

// MARK: - Missing Components (Consolidated for Build)

struct MarkedPointsOverlayView: View {
    @EnvironmentObject var appState: AppState
    private let pointRadius: CGFloat = 8.0
    private let labelOffset: CGFloat = 20.0
    
    var body: some View {
        Canvas { context, size in
            let coordSystem = CoordinateSystem(size: size, zoomScale: appState.zoomScale, panOffset: appState.panOffset)
            for point in appState.markedPoints {
                let screenPos = coordSystem.screenPosition(mathX: point.x, mathY: point.y)
                let circle = Circle().path(in: CGRect(x: screenPos.x - pointRadius, y: screenPos.y - pointRadius, width: pointRadius * 2, height: pointRadius * 2))
                context.fill(circle, with: .color(Color.orange))
                context.stroke(circle, with: .color(Color.white), lineWidth: 2.5)
                
                let label = Text(point.label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                context.draw(label, at: CGPoint(x: screenPos.x + labelOffset, y: screenPos.y - labelOffset))
            }
        }
    }
}

struct DistanceLinesOverlayView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Canvas { context, size in
            let coordSystem = CoordinateSystem(size: size, zoomScale: appState.zoomScale, panOffset: appState.panOffset)
            guard appState.showDistances else { return }
            
            for (pA, pB, dist) in appState.pointDistances {
                let posA = coordSystem.screenPosition(mathX: pA.x, mathY: pA.y)
                let posB = coordSystem.screenPosition(mathX: pB.x, mathY: pB.y)
                
                var path = Path()
                path.move(to: posA)
                path.addLine(to: posB)
                
                context.stroke(path, with: .color(Color.purple.opacity(0.8)), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5]))
                
                let mid = CGPoint(x: (posA.x + posB.x)/2, y: (posA.y + posB.y)/2)
                let labelText = Text("\(pA.label)\(pB.label) = \(String(format: "%.2f", dist))")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                
                let bgRect = CGRect(x: mid.x - 45, y: mid.y - 12, width: 90, height: 24)
                context.fill(Path(roundedRect: bgRect, cornerRadius: 4), with: .color(.white.opacity(0.8)))
                context.draw(labelText, at: mid)
            }
        }
    }
}

struct BannerAdView: View {
    var body: some View {
        Color.gray.opacity(0.2)
            .overlay(Text("Ads Disabled").font(.caption))
    }
}
