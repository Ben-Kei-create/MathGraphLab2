//
//  MathModels.swift
//  MathGraph Lab
//
//  Data models for mathematical functions and analysis results
//  Strictly follows IDD Section 2.1 specifications
//

import Foundation
import CoreGraphics

// MARK: - Parabola Model
/// Represents a quadratic function: y = a(x - p)² + q
struct Parabola: Equatable {
    /// Coefficient (controls vertical stretch/compression and orientation)
    /// Range: -5.0 to 5.0
    var a: Double
    
    /// Horizontal translation (vertex x-coordinate)
    /// Range: -5.0 to 5.0
    /// Only active in Pro Mode
    var p: Double
    
    /// Vertical translation (vertex y-coordinate)
    /// Range: -5.0 to 5.0
    /// Only active in Pro Mode
    var q: Double
    
    /// Default initializer with IDD-specified defaults
    init(a: Double = 1.0, p: Double = 0.0, q: Double = 0.0) {
        self.a = a.clamped(to: -5.0...5.0)
        self.p = p.clamped(to: -5.0...5.0)
        self.q = q.clamped(to: -5.0...5.0)
    }
    
    /// Calculate y-value for given x-coordinate
    /// Formula: y = a(x - p)² + q
    func evaluate(at x: Double) -> Double {
        return a * pow(x - p, 2) + q
    }
}

// MARK: - Line Model
/// Represents a linear function: y = mx + n
struct Line: Equatable {
    /// Slope
    /// Range: -5.0 to 5.0
    var m: Double
    
    /// Y-intercept
    /// Range: -10.0 to 10.0
    var n: Double
    
    /// Default initializer with IDD-specified defaults
    init(m: Double = 1.0, n: Double = 2.0) {
        self.m = m.clamped(to: -5.0...5.0)
        self.n = n.clamped(to: -10.0...10.0)
    }
    
    /// Calculate y-value for given x-coordinate
    /// Formula: y = mx + n
    func evaluate(at x: Double) -> Double {
        return m * x + n
    }
}

// MARK: - Intersection Point Model
/// Represents a point where the parabola and line intersect
struct IntersectionPoint: Identifiable, Equatable {
    let id: UUID
    let x: Double
    let y: Double
    
    init(x: Double, y: Double) {
        self.id = UUID()
        self.x = x
        self.y = y
    }
    
    /// Convert to CGPoint for drawing
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Marked Point Model
/// 作図モードでユーザーが打った点
struct MarkedPoint: Identifiable, Equatable {
    let id: UUID = UUID()
    var label: String  // "A", "B", "C", ...
    let x: Double
    let y: Double
    
    /// Convert to CGPoint for drawing
    var cgPoint: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Geometry Element Model
/// Represents user-drawn geometric elements in interactive mode
enum GeometryElement: Identifiable, Equatable {
    case point(id: UUID, x: Double, y: Double)
    case lineSegment(id: UUID, start: CGPoint, end: CGPoint)
    
    var id: UUID {
        switch self {
        case .point(let id, _, _):
            return id
        case .lineSegment(let id, _, _):
            return id
        }
    }
}

// MARK: - Helper Extension
private extension Double {
    /// Clamp value to specified range
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}
