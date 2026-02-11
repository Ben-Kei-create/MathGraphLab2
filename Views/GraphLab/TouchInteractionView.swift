//
//  TouchInteractionView.swift
//  MathGraph Lab
//
//  Layer 4: Touch interaction with improved gesture handling
//  最終版：作図モード中でもパン可能、タップとドラッグの明確な区別
//

import SwiftUI

struct TouchInteractionView: View {
    
    @EnvironmentObject var appState: AppState
    
    // ジェスチャー状態
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                
                // 1. タップ（作図用）
                .onTapGesture { location in
                    handleTap(at: location, size: geometry.size)
                }
                
                // 2. ドラッグ＆ズーム（同時認識）
                .gesture(
                    SimultaneousGesture(
                        // ズーム（ピンチ）
                        MagnificationGesture()
                            .onChanged { scale in
                                let delta = scale / currentScale
                                currentScale = scale
                                let newZoom = appState.zoomScale * delta
                                appState.zoomScale = min(max(newZoom, 0.5), 5.0)
                            }
                            .onEnded { _ in
                                currentScale = 1.0
                                if appState.isHapticsEnabled {
                                    HapticManager.shared.impact(style: .light)
                                }
                            },
                        
                        // パン（移動）
                        // ★修正: minimumDistance を 10 にして、タップと明確に区別
                        // 作図モード中でも移動可能に（guard削除）
                        DragGesture(minimumDistance: 10)
                            .onChanged { value in
                                let delta = CGSize(
                                    width: value.translation.width - currentOffset.width,
                                    height: value.translation.height - currentOffset.height
                                )
                                currentOffset = value.translation
                                appState.panOffset.width += delta.width
                                appState.panOffset.height += delta.height
                            }
                            .onEnded { _ in
                                currentOffset = .zero
                            }
                    )
                )
        }
    }
    
    // MARK: - Tap Handler
    
    private func handleTap(at location: CGPoint, size: CGSize) {
        // 作図モードOFF時は何もしない
        guard appState.isGeometryModeEnabled else { return }
        
        let system = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        
        // 画面座標 → 数学座標
        let mathPos = system.mathPosition(from: location)
        
        // 削除判定：既存の点の近く（44px以内）をタップしたか？
        if let index = appState.markedPoints.indices.reversed().first(where: { i in
            let p = appState.markedPoints[i]
            let pScreen = system.screenPosition(mathX: p.x, mathY: p.y)
            return hypot(pScreen.x - location.x, pScreen.y - location.y) < 44
        }) {
            // 削除実行
            appState.removeMarkedPoint(at: index)
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .medium)
            }
        } else {
            // 追加実行（上限10個）
            if appState.markedPoints.count < 10 {
                var x = mathPos.x
                var y = mathPos.y
                
                // グリッドスナップ（0.5刻み）
                if appState.isGridSnapEnabled {
                    x = round(x * 2) / 2
                    y = round(y * 2) / 2
                }
                
                appState.addMarkedPoint(x: x, y: y)
                if appState.isHapticsEnabled {
                    HapticManager.shared.impact(style: .light)
                }
            } else {
                print("⚠️ 点は最大10個までです")
                if appState.isHapticsEnabled {
                    HapticManager.shared.notification(type: .error)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        GridBackgroundView()
        GraphCanvasView()
        TouchInteractionView()
    }
    .environmentObject(AppState())
}
