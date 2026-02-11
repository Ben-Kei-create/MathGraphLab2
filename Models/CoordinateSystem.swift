//
//  CoordinateSystem.swift
//  MathGraph Lab
//
//  Shared coordinate conversion logic
//  Ensures consistent mapping between mathematical and screen coordinates across all layers
//

import Foundation
import CoreGraphics

// MARK: - Coordinate System
/// Shared coordinate conversion utilities
/// IDD Specification: Center of screen is (0, 0) in math coordinates
struct CoordinateSystem {
    let size: CGSize
    
    // Scale factor: how many screen points per math unit
    // IDD: Use min(width, height) / 12.0 to show approximately ±6 units
    var scale: CGFloat {
        return min(size.width, size.height) / 12.0
    }
    
    // Origin position in screen coordinates (center of canvas)
    var centerX: CGFloat {
        return size.width / 2.0
    }
    
    var centerY: CGFloat {
        return size.height / 2.0
    }
    
    // MARK: - Coordinate Conversion
    
    /// Convert mathematical coordinates to screen coordinates
    /// - Parameters:
    ///   - mathX: X-coordinate in mathematical space
    ///   - mathY: Y-coordinate in mathematical space
    /// - Returns: Screen position as CGPoint
    func screenPosition(mathX: Double, mathY: Double) -> CGPoint {
        let screenX = centerX + mathX * scale
        let screenY = centerY - mathY * scale  // Invert Y-axis
        return CGPoint(x: screenX, y: screenY)
    }
    
    /// Convert screen coordinates to mathematical coordinates
    /// - Parameters:
    ///   - screenX: X-coordinate in screen space
    ///   - screenY: Y-coordinate in screen space
    /// - Returns: Mathematical position as tuple (x, y)
    func mathPosition(screenX: Double, screenY: Double) -> (x: Double, y: Double) {
        let mathX = (screenX - centerX) / scale
        let mathY = (centerY - screenY) / scale  // Invert Y-axis
        return (mathX, mathY)
    }
    
    /// Convert CGPoint to mathematical coordinates
    func mathPosition(from point: CGPoint) -> (x: Double, y: Double) {
        return mathPosition(screenX: point.x, screenY: point.y)
    }
    
    /// Get visible mathematical bounds for current canvas
    func mathBounds() -> (minX: Double, maxX: Double, minY: Double, maxY: Double) {
        let rangeX = size.width / scale / 2.0
        let rangeY = size.height / scale / 2.0
        
        return (
            minX: -rangeX,
            maxX: rangeX,
            minY: -rangeY,
            maxY: rangeY
        )
    }
    
    /// Check if a mathematical point is within visible bounds
    func isVisible(mathX: Double, mathY: Double, margin: Double = 2.0) -> Bool {
        let bounds = mathBounds()
        return mathX >= bounds.minX - margin &&
               mathX <= bounds.maxX + margin &&
               mathY >= bounds.minY - margin &&
               mathY <= bounds.maxY + margin
    }
}
