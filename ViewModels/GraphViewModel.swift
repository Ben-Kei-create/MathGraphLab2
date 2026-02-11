import SwiftUI
import Combine

class GraphViewModel: ObservableObject {
    @Published var intersections: [IntersectionPoint] = []
    @Published var areaSize: Double = 0
    
    // 計算を実行する関数
    func calculate(parabola: Parabola, line: Line) {
        // 交点を計算（IntersectionPoint型で受け取る）
        let points = MathSolver.solveIntersections(parabola: parabola, line: line)
        self.intersections = points
        
        // 面積を計算
        if points.count == 2 {
            self.areaSize = MathSolver.calculateTriangleAreaSimplified(line: line, intersections: points)
        } else {
            self.areaSize = 0
        }
    }
}
