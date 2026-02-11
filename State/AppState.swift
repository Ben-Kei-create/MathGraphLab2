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
    }
}
