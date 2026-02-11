//
//  MathSolver.swift
//  MathGraph Lab
//
//  Pure mathematical functions for intersection solving and area calculation
//  Implements IDD Section 4.1 (Intersection Solver) and Section 4.2 (Area Calculation)
//

import Foundation
import CoreGraphics

// MARK: - Math Solver
/// Pure functions for mathematical computations
/// No side effects - suitable for unit testing
enum MathSolver {
    
    // MARK: - Intersection Solver (IDD Section 4.1)
    
    /// Solve for intersection points between parabola and line
    ///
    /// Equation: a(x - p)² + q = mx + n
    /// Expanding: ax² - 2apx + ap² + q = mx + n
    /// Standard form: ax² + (-2ap - m)x + (ap² + q - n) = 0
    ///
    /// Coefficients:
    /// - A = a
    /// - B = -2ap - m
    /// - C = ap² + q - n
    ///
    /// For non-Pro mode (p=0, q=0): ax² - mx - n = 0
    /// - A = a
    /// - B = -m
    /// - C = -n
    ///
    /// Using quadratic formula: x = (-B ± √(B² - 4AC)) / 2A
    ///
    /// - Parameters:
    ///   - parabola: The quadratic function y = a(x - p)² + q
    ///   - line: The linear function y = mx + n
    /// - Returns: Array of intersection points sorted by x-coordinate (0, 1, or 2 points)
    static func solveIntersections(parabola: Parabola, line: Line) -> [IntersectionPoint] {
        let a = parabola.a
        let p = parabola.p
        let q = parabola.q
        let m = line.m
        let n = line.n
        
        // EDGE CASE: a = 0 (degenerate parabola becomes horizontal line y = q)
        guard abs(a) > 1e-10 else {
            // Parabola: y = q
            // Line: y = mx + n
            // Intersection: q = mx + n → x = (q - n) / m
            guard abs(m) > 1e-10 else {
                // Both are horizontal lines
                // Either parallel (no intersection) or coincident (infinite intersections)
                return []
            }
            let x = (q - n) / m
            let y = q
            return [IntersectionPoint(x: x, y: y)]
        }
        
        // STANDARD FORM: Ax² + Bx + C = 0
        // Expanding a(x - p)² + q = mx + n:
        // a(x² - 2px + p²) + q = mx + n
        // ax² - 2apx + ap² + q = mx + n
        // ax² - 2apx - mx + ap² + q - n = 0
        // ax² + (-2ap - m)x + (ap² + q - n) = 0
        
        let A = a
        let B = -2.0 * a * p - m
        let C = a * p * p + q - n
        
        // Calculate discriminant: D = B² - 4AC
        let discriminant = B * B - 4.0 * A * C
        
        // IDD Section 4.1: Handle three cases based on discriminant
        
        // CASE 1: D < 0 - No real intersections
        if discriminant < 0 {
            return []
        }
        
        // CASE 2: D = 0 - One intersection (tangent point)
        if abs(discriminant) < 1e-10 {
            let x = -B / (2.0 * A)
            let y = line.evaluate(at: x)
            return [IntersectionPoint(x: x, y: y)]
        }
        
        // CASE 3: D > 0 - Two intersections
        let sqrtDiscriminant = sqrt(discriminant)
        
        // Quadratic formula: x = (-B ± √D) / 2A
        let x1 = (-B - sqrtDiscriminant) / (2.0 * A)
        let x2 = (-B + sqrtDiscriminant) / (2.0 * A)
        
        // Calculate corresponding y-values using the line equation
        // (more numerically stable than using parabola equation)
        let y1 = line.evaluate(at: x1)
        let y2 = line.evaluate(at: x2)
        
        // Create intersection points
        let point1 = IntersectionPoint(x: x1, y: y1)
        let point2 = IntersectionPoint(x: x2, y: y2)
        
        // IDD Section 4.1: Return sorted by x-coordinate (ascending order)
        return x1 < x2 ? [point1, point2] : [point2, point1]
    }
    
    // MARK: - Area Calculation (IDD Section 4.2)
    
    /// Calculate the area of triangle formed by Origin and two intersection points
    ///
    /// IDD Simplified Formula (Educational):
    /// - Base = |n| (Y-intercept of the line, vertical distance from origin to line)
    /// - Height = |x₂ - x₁| (Horizontal distance between intersection points)
    /// - S = ½ × |n| × |x₂ - x₁|
    ///
    /// Mathematical Justification:
    /// The triangle has vertices at O(0,0), P₁(x₁, y₁), P₂(x₂, y₂)
    /// Since both P₁ and P₂ lie on the line y = mx + n:
    /// - The line crosses the y-axis at (0, n)
    /// - The triangle has a "base" along the y-axis from (0,0) to (0,n) with length |n|
    /// - The "height" is the perpendicular distance, which simplifies to |x₂ - x₁|
    ///   when considering the horizontal span between the intersection points
    ///
    /// - Parameters:
    ///   - origin: The first vertex of the triangle (typically (0, 0))
    ///   - intersections: Array of exactly 2 intersection points
    /// - Returns: Area value (0 if fewer than 2 intersections exist)
    static func calculateTriangleArea(
        origin: CGPoint = .zero,
        intersections: [IntersectionPoint]
    ) -> Double {
        // Need exactly 2 intersection points to form a triangle
        guard intersections.count == 2 else {
            return 0.0
        }
        
        let x1 = intersections[0].x
        let y1 = intersections[0].y
        let x2 = intersections[1].x
        let y2 = intersections[1].y
        
        // Cross Product Formula (Standard Geometric Method):
        // For triangle with vertices O(x₀, y₀), P₁(x₁, y₁), P₂(x₂, y₂)
        // Area = ½ |x₁(y₂ - y₀) - x₂(y₁ - y₀) + x₀(y₁ - y₂)|
        //
        // When origin is (0, 0):
        // Area = ½ |x₁·y₂ - x₂·y₁|
        
        let x0 = origin.x
        let y0 = origin.y
        
        let crossProduct = (x1 - x0) * (y2 - y0) - (x2 - x0) * (y1 - y0)
        let area = 0.5 * abs(crossProduct)
        
        return area
    }
    
    /// Calculate triangle area using the IDD simplified formula
    ///
    /// IDD Section 4.2 Formula:
    /// S = ½ × |n| × |x₂ - x₁|
    ///
    /// Where:
    /// - n is the y-intercept of the line
    /// - x₁, x₂ are the x-coordinates of the two intersection points
    ///
    /// Note: This formula assumes the triangle is formed by the origin and
    /// two points on a line y = mx + n. It works when the line doesn't pass
    /// through the origin (n ≠ 0).
    ///
    /// - Parameters:
    ///   - line: The linear function y = mx + n
    ///   - intersections: Array of exactly 2 intersection points
    /// - Returns: Area value (0 if fewer than 2 intersections exist)
    static func calculateTriangleAreaSimplified(
        line: Line,
        intersections: [IntersectionPoint]
    ) -> Double {
        // Need exactly 2 intersection points
        guard intersections.count == 2 else {
            return 0.0
        }
        
        let x1 = intersections[0].x
        let x2 = intersections[1].x
        let n = line.n
        
        // IDD Section 4.2 Simplified Formula:
        // Base = |n| (absolute value of y-intercept)
        let base = abs(n)
        
        // Height = |x₂ - x₁| (horizontal distance between intersections)
        let height = abs(x2 - x1)
        
        // Area = ½ × base × height
        let area = 0.5 * base * height
        
        return area
    }
    
    // MARK: - Helper Methods
    
    /// Get discriminant value for UI feedback
    /// Useful for indicating whether intersections exist before calculating them
    ///
    /// - Returns: Discriminant value D = B² - 4AC
    static func getDiscriminant(parabola: Parabola, line: Line) -> Double {
        let a = parabola.a
        let p = parabola.p
        let q = parabola.q
        let m = line.m
        let n = line.n
        
        guard abs(a) > 1e-10 else { return 0.0 }
        
        let A = a
        let B = -2.0 * a * p - m
        let C = a * p * p + q - n
        
        return B * B - 4.0 * A * C
    }
    
    /// Get number of intersections without calculating actual points
    /// Efficient for UI state management
    ///
    /// - Returns: 0, 1, or 2 depending on discriminant value
    static func getIntersectionCount(parabola: Parabola, line: Line) -> Int {
        let discriminant = getDiscriminant(parabola: parabola, line: line)
        
        if discriminant < -1e-10 {
            return 0
        } else if abs(discriminant) < 1e-10 {
            return 1
        } else {
            return 2
        }
    }
    
    /// Validate if two calculated areas are approximately equal
    /// Useful for comparing different calculation methods in tests
    static func areAreasEqual(
        _ area1: Double,
        _ area2: Double,
        tolerance: Double = 1e-6
    ) -> Bool {
        return abs(area1 - area2) < tolerance
    }
}

// MARK: - Validation Extensions

extension MathSolver {
    /// Verify that an intersection point actually satisfies both equations
    /// Used for debugging and unit tests
    ///
    /// - Parameters:
    ///   - point: The intersection point to validate
    ///   - parabola: The quadratic function
    ///   - line: The linear function
    ///   - tolerance: Acceptable numerical error (default 1e-6)
    /// - Returns: true if the point satisfies both equations within tolerance
    static func validateIntersection(
        point: IntersectionPoint,
        parabola: Parabola,
        line: Line,
        tolerance: Double = 1e-6
    ) -> Bool {
        let parabolaY = parabola.evaluate(at: point.x)
        let lineY = line.evaluate(at: point.x)
        
        // Both equations should yield approximately the same y-value
        let parabolaMatch = abs(point.y - parabolaY) < tolerance
        let lineMatch = abs(point.y - lineY) < tolerance
        let equationsMatch = abs(parabolaY - lineY) < tolerance
        
        return parabolaMatch && lineMatch && equationsMatch
    }
    
    /// Validate all intersection points
    ///
    /// - Returns: true if all points are valid intersections
    static func validateAllIntersections(
        intersections: [IntersectionPoint],
        parabola: Parabola,
        line: Line,
        tolerance: Double = 1e-6
    ) -> Bool {
        guard !intersections.isEmpty else { return true }
        
        return intersections.allSatisfy { point in
            validateIntersection(
                point: point,
                parabola: parabola,
                line: line,
                tolerance: tolerance
            )
        }
    }
    
    /// Verify that intersection points are correctly sorted
    ///
    /// - Returns: true if points are sorted by x-coordinate in ascending order
    static func areIntersectionsSorted(_ intersections: [IntersectionPoint]) -> Bool {
        guard intersections.count == 2 else { return true }
        return intersections[0].x <= intersections[1].x
    }
}
