import XCTest
@testable import MathGraphLab

final class MathSolverTests: XCTestCase {

    // Test Case: y = x^2 and y = x + 2
    // Intersections should be (-1, 1) and (2, 4)
    func testStandardIntersections() {
        let parabola = Parabola(a: 1, p: 0, q: 0)
        let line = Line(m: 1, n: 2)
        
        let points = MathSolver.solveIntersections(parabola: parabola, line: line)
        
        XCTAssertEqual(points.count, 2, "Should have 2 intersections")
        
        // Check first point (-1, 1)
        XCTAssertEqual(points[0].x, -1.0, accuracy: 0.001)
        XCTAssertEqual(points[0].y, 1.0, accuracy: 0.001)
        
        // Check second point (2, 4)
        XCTAssertEqual(points[1].x, 2.0, accuracy: 0.001)
        XCTAssertEqual(points[1].y, 4.0, accuracy: 0.001)
    }

    // Test Case: Area Calculation
    // For y = x^2 and y = x + 2, Area should be 4.5
    // Base (|n|) = 2, Height (|2 - (-1)|) = 3
    // S = 1/2 * 2 * 3 = 3.0 ? No, wait.
    // Let's check logic:
    // Origin(0,0), A(-1,1), B(2,4).
    // Cross Product: |(-1*4) - (2*1)| / 2 = |-4 - 2| / 2 = |-6| / 2 = 3.0
    // Simplified Formula: 1/2 * |n| * |x2 - x1| = 1/2 * 2 * (2 - (-1)) = 1/2 * 2 * 3 = 3.0
    func testAreaCalculation() {
        let line = Line(m: 1, n: 2)
        let points = [IntersectionPoint(x: -1, y: 1), IntersectionPoint(x: 2, y: 4)]
        
        let area = MathSolver.calculateTriangleAreaSimplified(line: line, intersections: points)
        
        XCTAssertEqual(area, 3.0, accuracy: 0.001)
    }
}
