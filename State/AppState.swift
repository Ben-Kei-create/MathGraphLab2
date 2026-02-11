//
//  AppState.swift
//  MathGraph Lab
//

import SwiftUI
import Combine

// MARK: - App State
final class AppState: ObservableObject {
    
    // MARK: - Enums (クラス内で定義して管理を楽にする)
    
    enum AppTheme: String, CaseIterable, Identifiable {
        case light = "ライト"
        case dark = "ダーク"
        case blackboard = "黒板"
        var id: String { self.rawValue }
    }

    enum InputMode: String, CaseIterable, Identifiable {
        case decimal = "小数"
        case fraction = "分数"
        var id: String { self.rawValue }
    }

    // MARK: - User Settings (プロパティラッパーは必ずクラス内で定義)
    
    @AppStorage("appTheme") var appTheme: AppTheme = .light {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isGridSnapEnabled") var isGridSnapEnabled: Bool = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isHapticsEnabled") var isHapticsEnabled: Bool = true {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isProEnabled") var isProEnabled: Bool = false {
        willSet { objectWillChange.send() }
    }
    @AppStorage("isAdRemoved") var isAdRemoved: Bool = false {
        willSet { objectWillChange.send() }
    }
    
    // MARK: - Core Parameters
    
    @Published var parabola = Parabola()
    @Published var line = Line()
    @Published var showParabolaGraph: Bool = true
    @Published var showLinearGraph: Bool = true
    @Published var showAdvancedParabola: Bool = false
    @Published var coefficientInputMode: InputMode = .decimal
    
    // 式ラベルの移動量
    @Published var parabolaLabelOffset: CGSize = .zero
    @Published var lineLabelOffset: CGSize = .zero
    
    @Published var previousParabola: Parabola?
    @Published var previousLine: Line?
    @Published var intersectionPoints: [IntersectionPoint] = []
    
    // UI State
    @Published var isAreaModeEnabled: Bool = false
    @Published var isGeometryModeEnabled: Bool = false
    @Published var geometryElements: [GeometryElement] = []
    @Published var markedPoints: [MarkedPoint] = []
    @Published var zoomScale: CGFloat = 1.0
    @Published var panOffset: CGSize = .zero
    @Published var showDistances: Bool = false
    @Published var isLineFromPoints: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var pointLabelIndex: Int = 0

    // MARK: - Initialization
    
    init() {
        // AppStorageを使っているので、initでの手動読み込みやUserDefaultsの監視は不要になりました。
        // これでコードがさらにシンプルになります。
    }
    
    // --- 以下、計算プロパティやメソッド ---

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

    func updateParabolaA(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap { newValue = round(newValue) }
        parabola.a = newValue
    }
    
    func updateParabolaP(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap { newValue = round(newValue) }
        parabola.p = newValue
    }
    
    func updateParabolaQ(_ value: Double, snap: Bool = false) {
        var newValue = max(-5.0, min(5.0, value))
        if snap { newValue = round(newValue) }
        parabola.q = newValue
    }
    
    func updateLineM(_ value: Double) {
        line.m = max(-5.0, min(5.0, value))
    }
    
    func updateLineN(_ value: Double) {
        line.n = max(-10.0, min(10.0, value))
    }
    
    func addMarkedPoint(x: Double, y: Double) {
        guard markedPoints.count < 10 else { return }
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        markedPoints.append(MarkedPoint(label: labels[markedPoints.count], x: x, y: y))
    }
    
    func removeMarkedPoint(at index: Int) {
        guard markedPoints.indices.contains(index) else { return }
        markedPoints.remove(at: index)
        relabelPoints()
    }
    
    private func relabelPoints() {
        let labels = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        for i in 0..<markedPoints.count {
            markedPoints[i].label = labels[i]
        }
    }
    
    func clearMarkedPoints() {
        markedPoints.removeAll()
    }
    
    func clearGeometry() {
        geometryElements.removeAll()
    }
    
    func resetZoomAndPan() {
        zoomScale = 1.0
        panOffset = .zero
    }
    
    func createLineFromPoints() {
        guard markedPoints.count >= 2 else { return }
        let p1 = markedPoints[0], p2 = markedPoints[1]
        if p1.x == p2.x { return }
        let m = (p2.y - p1.y) / (p2.x - p1.x)
        let n = p1.y - m * p1.x
        updateLineM(m)
        updateLineN(n)
        isLineFromPoints = true
    }
    
    func resetLabelPositions() {
        parabolaLabelOffset = .zero
        lineLabelOffset = .zero
        if isHapticsEnabled { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
    }
    
    func reset() {
        parabola = Parabola()
        line = Line()
        isAreaModeEnabled = false
        isGeometryModeEnabled = false
        clearMarkedPoints()
        resetZoomAndPan()
        showAdvancedParabola = false
        resetLabelPositions()
    }
}
