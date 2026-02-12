//
//  TouchInteractionView.swift
//  MathGraph Lab
//
//  Layer 4: Touch interaction with long-press point dragging
//  タップ: 点の追加/削除
//  長押し+ドラッグ: 点の移動
//  通常ドラッグ: グラフ全体のパン
//

import SwiftUI

struct TouchInteractionView: View {
    
    @EnvironmentObject var appState: AppState
    
    // ジェスチャー状態
    @State private var currentScale: CGFloat = 1.0
    @State private var currentOffset: CGSize = .zero
    
    // ドラッグ用の状態（パン専用に簡素化）
    @State private var dragStartLocation: CGPoint? = nil
    @State private var lastDragLocation: CGPoint? = nil
    
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .contentShape(Rectangle())
                
                // ズーム（ピンチ）
                .gesture(
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
                        }
                )
                
                // 統合ドラッグジェスチャー（タップとパンを処理）
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            handleDragChanged(value: value, size: geometry.size)
                        }
                        .onEnded { value in
                            handleDragEnded(value: value, size: geometry.size)
                        }
                )
        }
    }
    
    // MARK: - Drag Handlers
    
    private func handleDragChanged(value: DragGesture.Value, size: CGSize) {
        // 1. 初回タッチ時の初期化
        if dragStartLocation == nil {
            dragStartLocation = value.startLocation
            lastDragLocation = value.location
            return
        }

        // 2. 移動量の計算
        guard let lastLoc = lastDragLocation else { return }
        let delta = CGSize(
            width: value.location.x - lastLoc.x,
            height: value.location.y - lastLoc.y
        )

        // 3. パン操作を最優先・最速で処理
        appState.panOffset.width += delta.width
        appState.panOffset.height += delta.height
        
        // 次のフレームのために位置を保存
        lastDragLocation = value.location
    }
    
    private func handleDragEnded(value: DragGesture.Value, size: CGSize) {
        guard let startLoc = dragStartLocation else {
            resetDragState()
            return
        }
        
        let moved = hypot(
            value.location.x - startLoc.x,
            value.location.y - startLoc.y
        )
        
        // タップ判定（移動が少ない）
        if moved < 10 {
            handleTap(at: value.startLocation, size: size)
        }
        
        resetDragState()
    }
    
    private func resetDragState() {
        dragStartLocation = nil
        lastDragLocation = nil
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
        
        // 優先度1: 交点をタップしたか？（グラフ拘束移動モード）
        if let intersectionIndex = findNearestIntersectionIndex(at: location, size: size) {
            // 交点をタップ → グラフ選択モードに入る
            appState.constrainedPointIndex = intersectionIndex
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .medium)
            }
            return
        }
        
        // 優先度2: 削除判定：既存の点の近く（44px以内）をタップしたか？
        if let index = findNearestPointIndex(at: location, size: size) {
            // 削除実行
            appState.removeMarkedPoint(at: index)
            if appState.isHapticsEnabled {
                HapticManager.shared.impact(style: .medium)
            }
        } else {
            // 優先度3: 追加実行（上限10個）
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
    
    // MARK: - Helper
    
    private func findNearestPointIndex(at location: CGPoint, size: CGSize) -> Int? {
        let system = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        
        return appState.markedPoints.indices.reversed().first { i in
            let p = appState.markedPoints[i]
            let pScreen = system.screenPosition(mathX: p.x, mathY: p.y)
            return hypot(pScreen.x - location.x, pScreen.y - location.y) < 44
        }
    
    private func findNearestIntersectionIndex(at location: CGPoint, size: CGSize) -> Int? {
        let system = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        
        return appState.intersectionPoints.indices.first { i in
            let p = appState.intersectionPoints[i]
            let pScreen = system.screenPosition(mathX: p.x, mathY: p.y)
            return hypot(pScreen.x - location.x, pScreen.y - location.y) < 44
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
