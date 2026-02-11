//
//  AppState.swift
//  MathGraph Lab
//
//  Global state container
//  Implements IDD Section 2 (Data Model & State Specifications)
//

import SwiftUI
import Combine

// MARK: - App State
/// Global state object managing all data models and settings
/// Acts as the Single Source of Truth for the application
final class AppState: ObservableObject { // ★ここ重要: ObservableObject を継承していること
    
    // MARK: - Core Parameters (IDD 2.1)
    
    @Published var parabola = Parabola()
    @Published var line = Line()
    
    // Graph visibility toggles
    @Published var showParabolaGraph: Bool = true
    @Published var showLinearGraph: Bool = true
    
    // ★追加: 高校数学モード（p, qを表示するかどうか）
    @Published var showAdvancedParabola: Bool = false
    
    // ★追加: 数式ラベルの移動オフセット（ドラッグで動かした量）
    @Published var parabolaLabelOffset: CGSize = .zero
    @Published var lineLabelOffset: CGSize = .zero
    
    // Previous state for ghosting effect
    @Published var previousParabola: Parabola?
    @Published var previousLine: Line?
    
    // Calculated data
    @Published var intersectionPoints: [IntersectionPoint] = []
    
    // MARK: - User Settings (IDD 2.2)
    
    @AppStorage("isGridSnapEnabled") var isGridSnapEnabled: Bool = true
    @AppStorage("isHapticsEnabled") var isHapticsEnabled: Bool = true
    @AppStorage("appTheme") var appTheme: String = "light" // "light", "dark", "blackboard"
    @AppStorage("isProEnabled") var isProEnabled: Bool = false
    @AppStorage("isAdRemoved") var isAdRemoved: Bool = false
    
    // UI State
    @Published var isAreaModeEnabled: Bool = false
    @Published var isGeometryModeEnabled: Bool = false
    @Published var geometryElements: [GeometryElement] = []
    
    // 作図モードで打った点を管理
    @Published var markedPoints: [MarkedPoint] = []
    
    // ズームとパンの状態
    @Published var zoomScale: CGFloat = 1.0
    @Published var panOffset: CGSize = .zero
    
    // 距離を表示するかどうかのスイッチ
    @Published var showDistances: Bool = false
    
    // 2点から直線を自動生成したかどうかのフラグ
    @Published var isLineFromPoints: Bool = false
    
    // Helper state for input mode
    enum InputMode: String, CaseIterable, Identifiable {
            case decimal = "小数"
            case fraction = "分数"
            var id: String { self.rawValue }
        }
        @Published var coefficientInputMode: InputMode = .decimal
    
    // 連続する2点間の距離とペアを計算して返す
    var pointDistances: [(MarkedPoint, MarkedPoint, Double)] {
        var result: [(MarkedPoint, MarkedPoint, Double)] = []
        guard markedPoints.count >= 2 else { return result }
        
        for i in 0..<markedPoints.count - 1 {
            let pA = markedPoints[i]
            let pB = markedPoints[i + 1]
            let dx = pB.x - pA.x
            let dy = pB.y - pA.y
            let distance = sqrt(dx * dx + dy * dy)
            result.append((pA, pB, distance))
        }
        return result
    }
    
    // 点のラベル管理（A, B, C, ...）
    private var pointLabelIndex: Int = 0
    
    // MARK: - Actions
    
    /// Updates parabola coefficient 'a' with validation
    func updateParabolaA(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap {
            newValue = round(newValue)
        }
        parabola.a = newValue
    }
    
    /// Updates parabola 'p'
    func updateParabolaP(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap {
            newValue = round(newValue)
        }
        parabola.p = newValue
    }
    
    /// Updates parabola 'q'
    func updateParabolaQ(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap {
            newValue = round(newValue)
        }
        parabola.q = newValue
    }
    
    /// Updates line slope 'm'
    func updateLineM(_ value: Double) {
        let newValue = max(-5.0, min(5.0, value))
        line.m = newValue
    }
    
    /// Updates line intercept 'n'
    func updateLineN(_ value: Double) {
        let newValue = max(-10.0, min(10.0, value))
        line.n = newValue
    }
    
    /// 作図モードで打った点を追加（最大10個）
    func addMarkedPoint(x: Double, y: Double) {
        guard markedPoints.count < 10 else {
            print("⚠️ 点は最大10個までです")
            return
        }
        
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        let label = labels[markedPoints.count]
        
        let point = MarkedPoint(label: label, x: x, y: y)
        markedPoints.append(point)
        
        print("📍 点\(label)を追加: (\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))")
    }
    
    /// 指定したインデックスの点を削除
    func removeMarkedPoint(at index: Int) {
        guard markedPoints.indices.contains(index) else { return }
        let removed = markedPoints.remove(at: index)
        print("🗑️ 点\(removed.label)を削除")
        
        // ラベルを再割り当て
        relabelPoints()
    }
    
    /// 点のラベルを再割り当て
    private func relabelPoints() {
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        for (index, _) in markedPoints.enumerated() {
            if index < labels.count {
                markedPoints[index].label = labels[index]
            }
        }
    }
    
    /// 打った点をすべてクリア
    func clearMarkedPoints() {
        markedPoints.removeAll()
        pointLabelIndex = 0
        print("🗑️ すべての点をクリア")
    }
    
    /// Resets zoom and pan to default
    func resetZoomAndPan() {
        zoomScale = 1.0
        panOffset = .zero
    }
    
    func resetZoom() {
        resetZoomAndPan()
    }
    
    /// 2点から直線を生成
    func createLineFromPoints() {
        guard markedPoints.count >= 2 else {
            print("⚠️ 点が2つ必要です")
            return
        }
        
        let p1 = markedPoints[0]
        let p2 = markedPoints[1]
        
        // 垂直線はスキップ
        if p1.x == p2.x {
            print("❌ 垂直線のため直線の式を生成できません")
            return
        }
        
        let m = (p2.y - p1.y) / (p2.x - p1.x)
        let n = p1.y - m * p1.x
        
        updateLineM(m)
        updateLineN(n)
        isLineFromPoints = true
        
        print("✅ 直線を更新: y = \(String(format: "%.2f", m))x + \(String(format: "%.2f", n))")
    }
    
    /// Begins a drag operation (enables ghosting)
    func beginDrag() {
        previousParabola = parabola
        previousLine = line
    }
    
    /// Ends a drag operation (disables ghosting)
    func endDrag() {
        previousParabola = nil
        previousLine = nil
    }
    
    /// Adds a geometry point
    func addGeometryPoint(at location: CGPoint, graphX: Double, graphY: Double) {
        let point = GeometryElement.point(id: UUID(), x: graphX, y: graphY)
        geometryElements.append(point)
    }
    
    /// Clears all user-drawn geometry
    func clearGeometry() {
        geometryElements.removeAll()
    }
    
    // ★追加: ラベル位置のリセット関数
    func resetLabelPositions() {
        parabolaLabelOffset = .zero
        lineLabelOffset = .zero
        if isHapticsEnabled { HapticManager.shared.impact(style: .medium) }
    }
    
    /// Resets all parameters to default
    func reset() {
        parabola = Parabola() // Resets to defaults
        line = Line()         // Resets to defaults
        geometryElements.removeAll()
        isAreaModeEnabled = false
        isGeometryModeEnabled = false
        
        clearMarkedPoints()
        resetZoom()
        isLineFromPoints = false
        showAdvancedParabola = false // 中学生モードへ
        
        // ★追加: ラベル位置もリセット
        resetLabelPositions()
    }
}
