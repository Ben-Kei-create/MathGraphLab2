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
final class AppState: ObservableObject {
    
    // MARK: - Core Parameters (IDD 2.1)
    
    @Published var parabola = Parabola()
    @Published var line = Line()
    
    // Graph visibility toggles
    @Published var showParabolaGraph: Bool = true
    @Published var showLinearGraph: Bool = true
    
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
    
    // Helper state for input mode
    enum InputMode {
        case decimal
        case fraction
    }
    @Published var coefficientInputMode: InputMode = .decimal
    
    // MARK: - Actions
    
    /// Updates parabola coefficient 'a' with validation
    func updateParabolaA(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap {
            newValue = round(newValue)
        }
        parabola.a = newValue
    }
    
    /// Updates parabola 'p' (Pro only)
    func updateParabolaP(_ value: Double, snap: Bool = false) {
        guard isProEnabled else { return }
        var newValue = max(-5.0, min(5.0, value))
        if snap {
            newValue = round(newValue)
        }
        parabola.p = newValue
    }
    
    /// Updates parabola 'q' (Pro only)
    func updateParabolaQ(_ value: Double, snap: Bool = false) {
        guard isProEnabled else { return }
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
    
    /// 作図モードで点を追加
    func addMarkedPoint(x: Double, y: Double) {
        let label = generatePointLabel()
        let point = MarkedPoint(label: label, x: x, y: y)
        markedPoints.append(point)
        
        print("📍 点\(label)を追加: (\(String(format: "%.2f", x)), \(String(format: "%.2f", y)))")
    }
    
    /// 点のラベルを生成（A, B, C, ...）
    private func generatePointLabel() -> String {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let index = pointLabelIndex % alphabet.count
        let label = String(alphabet[alphabet.index(alphabet.startIndex, offsetBy: index)])
        pointLabelIndex += 1
        return label
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
        
        // Assuming MathSolver is available and has calculateLineEquation
        // For this example, I'll provide a placeholder for MathSolver.calculateLineEquation
        // In a real app, you'd have this utility.
        // Example placeholder:
        struct LineEquation {
            let m: Double
            let n: Double
        }
        
        // Placeholder for MathSolver
        class MathSolver {
            static func calculateLineEquation(p1: MarkedPoint, p2: MarkedPoint) -> LineEquation? {
                // Handle vertical line case
                if p1.x == p2.x {
                    return nil // Vertical line, cannot be represented as y = mx + n
                }
                
                let m = (p2.y - p1.y) / (p2.x - p1.x)
                let n = p1.y - m * p1.x
                return LineEquation(m: m, n: n)
            }
        }
        
        if let equation = MathSolver.calculateLineEquation(p1: p1, p2: p2) {
            updateLineM(equation.m)
            updateLineN(equation.n)
            isLineFromPoints = true
            
            print("✅ 直線を更新: y = \(String(format: "%.2f", equation.m))x + \(String(format: "%.2f", equation.n))")
        } else {
            print("❌ 垂直線のため直線の式を生成できません")
        }
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
    
    /// Adds a geometry line segment
    func addGeometryLineSegment(start: CGPoint, end: CGPoint) {
        // In a real implementation, we would convert screen points to graph coordinates here
        // For now, we'll simplify IDD logic
        // geometryElements.append(.lineSegment(...))
    }
    
    /// Clears all user-drawn geometry
    func clearGeometry() {
        geometryElements.removeAll()
    }
    
    /// Resets all parameters to default
    func reset() {
        parabola = Parabola() // Resets to defaults
        line = Line()         // Resets to defaults
        geometryElements.removeAll()
        isAreaModeEnabled = false
        isGeometryModeEnabled = false
        
        // 追加
        clearMarkedPoints()
        resetZoom()
        isLineFromPoints = false
    }
}
