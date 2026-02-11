//
//  GridBackgroundView.swift
//  MathGraph Lab
//
//  Layer 1: Background grid and coordinate axes
//  Implements IDD Section 3.2 Layer 1 specifications
//

import SwiftUI

// MARK: - Grid Background View
/// Draws the coordinate system grid with axes and gridlines
/// Adapts appearance based on app theme (Light/Dark/Blackboard)
struct GridBackgroundView: View {
    
    @EnvironmentObject var appState: AppState
    
    // Grid configuration
    private let gridStep: CGFloat = 1.0  // Grid spacing in math coordinates
    private let axisLineWidth: CGFloat = 2.0
    private let gridLineWidth: CGFloat = 0.5
    
    var body: some View {
        Canvas { context, size in
            // Get theme-specific colors
            let colors = getThemeColors()
            
            // Draw grid lines first (behind axes)
            drawGridLines(context: context, size: size, color: colors.grid)
            
            // Draw coordinate axes on top
            drawAxes(context: context, size: size, color: colors.axis)
            
            // Draw axis labels (optional, for better UX)
            drawAxisLabels(context: context, size: size, color: colors.text)
        }
        .background(getBackgroundColor())
    }
    
    // MARK: - Drawing Methods
    
    /// Draw vertical and horizontal grid lines
    private func drawGridLines(context: GraphicsContext, size: CGSize, color: Color) {
        var path = Path()
        
        // Determine visible range in math coordinates
        let mathBounds = getMathBounds(for: size)
        
        // Vertical grid lines (parallel to Y-axis)
        var x = floor(mathBounds.minX)
        while x <= mathBounds.maxX {
            let screenPoint = screenPosition(mathX: x, mathY: 0, in: size)
            path.move(to: CGPoint(x: screenPoint.x, y: 0))
            path.addLine(to: CGPoint(x: screenPoint.x, y: size.height))
            x += gridStep
        }
        
        // Horizontal grid lines (parallel to X-axis)
        var y = floor(mathBounds.minY)
        while y <= mathBounds.maxY {
            let screenPoint = screenPosition(mathX: 0, mathY: y, in: size)
            path.move(to: CGPoint(x: 0, y: screenPoint.y))
            path.addLine(to: CGPoint(x: size.width, y: screenPoint.y))
            y += gridStep
        }
        
        context.stroke(
            path,
            with: .color(color),
            lineWidth: gridLineWidth
        )
    }
    
    /// Draw X and Y coordinate axes
    private func drawAxes(context: GraphicsContext, size: CGSize, color: Color) {
        var path = Path()
        
        let origin = screenPosition(mathX: 0, mathY: 0, in: size)
        
        // X-axis (horizontal line through origin)
        path.move(to: CGPoint(x: 0, y: origin.y))
        path.addLine(to: CGPoint(x: size.width, y: origin.y))
        
        // Y-axis (vertical line through origin)
        path.move(to: CGPoint(x: origin.x, y: 0))
        path.addLine(to: CGPoint(x: origin.x, y: size.height))
        
        context.stroke(
            path,
            with: .color(color),
            lineWidth: axisLineWidth
        )
        
        // Draw axis arrows (optional enhancement)
        drawAxisArrows(context: context, size: size, origin: origin, color: color)
    }
    
    /// Draw arrow heads on axes (optional, enhances educational value)
    private func drawAxisArrows(
        context: GraphicsContext,
        size: CGSize,
        origin: CGPoint,
        color: Color
    ) {
        let arrowSize: CGFloat = 8
        var arrowPath = Path()
        
        // X-axis arrow (pointing right)
        let xArrowTip = CGPoint(x: size.width - 10, y: origin.y)
        arrowPath.move(to: xArrowTip)
        arrowPath.addLine(to: CGPoint(x: xArrowTip.x - arrowSize, y: xArrowTip.y - arrowSize/2))
        arrowPath.move(to: xArrowTip)
        arrowPath.addLine(to: CGPoint(x: xArrowTip.x - arrowSize, y: xArrowTip.y + arrowSize/2))
        
        // Y-axis arrow (pointing up)
        let yArrowTip = CGPoint(x: origin.x, y: 10)
        arrowPath.move(to: yArrowTip)
        arrowPath.addLine(to: CGPoint(x: yArrowTip.x - arrowSize/2, y: yArrowTip.y + arrowSize))
        arrowPath.move(to: yArrowTip)
        arrowPath.addLine(to: CGPoint(x: yArrowTip.x + arrowSize/2, y: yArrowTip.y + arrowSize))
        
        context.stroke(
            arrowPath,
            with: .color(color),
            lineWidth: axisLineWidth
        )
    }
    
    /// Draw axis labels (0, ±1, ±2, etc.)
    private func drawAxisLabels(context: GraphicsContext, size: CGSize, color: Color) {
        let mathBounds = getMathBounds(for: size)
        let origin = screenPosition(mathX: 0, mathY: 0, in: size)
        
        // X-axis labels
        var x = floor(mathBounds.minX)
        while x <= mathBounds.maxX {
            guard abs(x) > 0.1 else { x += gridStep; continue } // Skip origin
            let screenPoint = screenPosition(mathX: x, mathY: 0, in: size)
            
            let text = Text(String(format: "%.0f", x))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(color)
            
            context.draw(
                text,
                at: CGPoint(x: screenPoint.x, y: origin.y + 15)
            )
            x += gridStep
        }
        
        // Y-axis labels
        var y = floor(mathBounds.minY)
        while y <= mathBounds.maxY {
            guard abs(y) > 0.1 else { y += gridStep; continue } // Skip origin
            let screenPoint = screenPosition(mathX: 0, mathY: y, in: size)
            
            let text = Text(String(format: "%.0f", y))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(color)
            
            context.draw(
                text,
                at: CGPoint(x: origin.x + 20, y: screenPoint.y)
            )
            y += gridStep
        }
        
        // Draw "O" at origin
        let originLabel = Text("O")
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundColor(color)
        
        context.draw(
            originLabel,
            at: CGPoint(x: origin.x + 15, y: origin.y + 15)
        )
    }
    
    // MARK: - Coordinate Conversion (IDD Helper Function)
    
    /// Convert mathematical coordinates to screen coordinates
    /// IDD Specification: Center of screen is (0, 0) in math coordinates
    ///
    /// - Parameters:
    ///   - mathX: X-coordinate in mathematical space
    ///   - mathY: Y-coordinate in mathematical space
    ///   - size: Canvas size
    /// - Returns: Screen position as CGPoint
    func screenPosition(mathX: Double, mathY: Double, in size: CGSize) -> CGPoint {
        let coordSystem = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        return coordSystem.screenPosition(mathX: mathX, mathY: mathY)
    }
    
    /// Convert screen coordinates back to mathematical coordinates
    /// Inverse of screenPosition function
    func mathPosition(screenX: Double, screenY: Double, in size: CGSize) -> (x: Double, y: Double) {
        let coordSystem = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        return coordSystem.mathPosition(screenX: screenX, screenY: screenY)
    }
    
    /// Get the visible mathematical bounds for current canvas size
    private func getMathBounds(for size: CGSize) -> (minX: Double, maxX: Double, minY: Double, maxY: Double) {
        let coordSystem = CoordinateSystem(
            size: size,
            zoomScale: appState.zoomScale,
            panOffset: appState.panOffset
        )
        return coordSystem.mathBounds()
    }
    
    // MARK: - Theme Support (IDD Section 5)
    
    /// Get background color based on theme
    private func getBackgroundColor() -> Color {
        switch appState.appTheme {
        case .light:
            return Color.white
        case .dark:
            return Color(white: 0.05)
        case .blackboard:
            return Color(red: 0.0, green: 0.2, blue: 0.15)
        }
    }
    
    /// Get theme-specific colors for grid elements
    private func getThemeColors() -> (grid: Color, axis: Color, text: Color) {
        switch appState.appTheme {
        case .light:
            return (
                grid: Color.black.opacity(0.1),
                axis: Color.black.opacity(0.8),
                text: Color.black.opacity(0.7)
            )
        case .dark:
            return (
                grid: Color.white.opacity(0.2),
                axis: Color.white.opacity(0.8),
                text: Color.white.opacity(0.7)
            )
        case .blackboard:
            return (
                grid: Color.white.opacity(0.15),
                axis: Color.white.opacity(0.85),
                text: Color.white.opacity(0.75)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    GridBackgroundView()
        .environmentObject(AppState())
}
