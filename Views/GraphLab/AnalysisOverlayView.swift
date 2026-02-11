//
//  AnalysisOverlayView.swift
//  MathGraph Lab
//
//  Layer 3: Intersection points, droplines, and area visualization
//  Implements IDD Section 3.2 Layer 3 specifications
//

import SwiftUI

// MARK: - Analysis Overlay View
/// Renders intersection points, droplines, and filled area triangles
struct AnalysisOverlayView: View {
    
    @EnvironmentObject var appState: AppState
    
    // Visual configuration
    private let intersectionDotRadius: CGFloat = 6.0
    private let droplineWidth: CGFloat = 1.5
    private let areaOpacity: Double = 0.3
    
    var body: some View {
        Canvas { context, size in
            let coordSystem = CoordinateSystem(
                size: size,
                zoomScale: appState.zoomScale,
                panOffset: appState.panOffset
            )
            
            // Calculate intersection points using MathSolver
            let intersections = MathSolver.solveIntersections(
                parabola: appState.parabola,
                line: appState.line
            )
            
            // Store intersections in AppState for other components
            DispatchQueue.main.async {
                appState.intersectionPoints = intersections
            }
            
            // Draw area fill if mode is enabled and we have 2 intersections
            if appState.isAreaModeEnabled && intersections.count == 2 {
                drawAreaTriangles(
                    context: context,
                    coordSystem: coordSystem,
                    intersections: intersections
                )
                
                drawAreaLabel(
                    context: context,
                    coordSystem: coordSystem,
                    intersections: intersections
                )
            }
            
            // Draw droplines from intersections to X-axis
            drawDroplines(
                context: context,
                coordSystem: coordSystem,
                intersections: intersections
            )
            
            // Draw intersection points (green dots)
            drawIntersectionPoints(
                context: context,
                coordSystem: coordSystem,
                intersections: intersections
            )
        }
    }
    
    // MARK: - Drawing Methods
    
    /// Draw green dots at intersection points
    /// IDD Section 5: Intersections are System Green
    private func drawIntersectionPoints(
        context: GraphicsContext,
        coordSystem: CoordinateSystem,
        intersections: [IntersectionPoint]
    ) {
        for point in intersections {
            let screenPos = coordSystem.screenPosition(mathX: point.x, mathY: point.y)
            
            // Draw outer glow
            let glowCircle = Circle()
                .path(in: CGRect(
                    x: screenPos.x - intersectionDotRadius - 2,
                    y: screenPos.y - intersectionDotRadius - 2,
                    width: (intersectionDotRadius + 2) * 2,
                    height: (intersectionDotRadius + 2) * 2
                ))
            
            context.fill(
                glowCircle,
                with: .color(Color.green.opacity(0.3))
            )
            
            // Draw main dot
            let circle = Circle()
                .path(in: CGRect(
                    x: screenPos.x - intersectionDotRadius,
                    y: screenPos.y - intersectionDotRadius,
                    width: intersectionDotRadius * 2,
                    height: intersectionDotRadius * 2
                ))
            
            context.fill(circle, with: .color(Color.green))
            
            // Draw white border
            context.stroke(
                circle,
                with: .color(Color.white),
                lineWidth: 2.0
            )
        }
    }
    
    /// Draw dashed lines from intersection points to X-axis
    private func drawDroplines(
        context: GraphicsContext,
        coordSystem: CoordinateSystem,
        intersections: [IntersectionPoint]
    ) {
        for point in intersections {
            let topPoint = coordSystem.screenPosition(mathX: point.x, mathY: point.y)
            let bottomPoint = coordSystem.screenPosition(mathX: point.x, mathY: 0)
            
            var path = Path()
            path.move(to: topPoint)
            path.addLine(to: bottomPoint)
            
            context.stroke(
                path,
                with: .color(Color.green.opacity(0.6)),
                style: StrokeStyle(
                    lineWidth: droplineWidth,
                    dash: [4, 4]
                )
            )
        }
    }
    
    /// Draw filled area triangles
    /// IDD Section 3.2: Split by Y-axis, Left=Red tint, Right=Blue tint
    private func drawAreaTriangles(
        context: GraphicsContext,
        coordSystem: CoordinateSystem,
        intersections: [IntersectionPoint]
    ) {
        guard intersections.count == 2 else { return }
        
        let origin = coordSystem.screenPosition(mathX: 0, mathY: 0)
        let point1 = coordSystem.screenPosition(
            mathX: intersections[0].x,
            mathY: intersections[0].y
        )
        let point2 = coordSystem.screenPosition(
            mathX: intersections[1].x,
            mathY: intersections[1].y
        )
        
        // Determine if points are on opposite sides of Y-axis
        let x1 = intersections[0].x
        let x2 = intersections[1].x
        
        if (x1 < 0 && x2 > 0) || (x1 > 0 && x2 < 0) {
            // Points on opposite sides - split into two triangles
            
            // Find where the line crosses the Y-axis (x = 0)
            let yIntercept = appState.line.n
            let yAxisPoint = coordSystem.screenPosition(mathX: 0, mathY: yIntercept)
            
            // Left triangle (Red tint)
            let leftPoint = x1 < 0 ? point1 : point2
            var leftPath = Path()
            leftPath.move(to: origin)
            leftPath.addLine(to: leftPoint)
            leftPath.addLine(to: yAxisPoint)
            leftPath.closeSubpath()
            
            context.fill(
                leftPath,
                with: .color(Color.red.opacity(areaOpacity))
            )
            
            // Right triangle (Blue tint)
            let rightPoint = x1 > 0 ? point1 : point2
            var rightPath = Path()
            rightPath.move(to: origin)
            rightPath.addLine(to: yAxisPoint)
            rightPath.addLine(to: rightPoint)
            rightPath.closeSubpath()
            
            context.fill(
                rightPath,
                with: .color(Color.blue.opacity(areaOpacity))
            )
        } else {
            // Both points on same side - single triangle
            let color = x1 < 0 ? Color.red : Color.blue
            
            var path = Path()
            path.move(to: origin)
            path.addLine(to: point1)
            path.addLine(to: point2)
            path.closeSubpath()
            
            context.fill(
                path,
                with: .color(color.opacity(areaOpacity))
            )
        }
        
        // Draw triangle outline
        var outlinePath = Path()
        outlinePath.move(to: origin)
        outlinePath.addLine(to: point1)
        outlinePath.addLine(to: point2)
        outlinePath.closeSubpath()
        
        context.stroke(
            outlinePath,
            with: .color(Color.green.opacity(0.5)),
            style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
        )
    }
    
    /// Draw area value label
    private func drawAreaLabel(
        context: GraphicsContext,
        coordSystem: CoordinateSystem,
        intersections: [IntersectionPoint]
    ) {
        // Calculate area using IDD simplified formula
        let area = MathSolver.calculateTriangleAreaSimplified(
            line: appState.line,
            intersections: intersections
        )
        
        // Position label at centroid of triangle
        let centroidX = (intersections[0].x + intersections[1].x) / 3.0
        let centroidY = (intersections[0].y + intersections[1].y) / 3.0
        
        let labelPos = coordSystem.screenPosition(mathX: centroidX, mathY: centroidY)
        
        // Create formatted text
        let areaText = Text("S = \(String(format: "%.2f", area))")
            .font(.system(size: 16, weight: .bold, design: .monospaced))
            .foregroundColor(.green)
        
        // Draw background
        let textSize = CGSize(width: 80, height: 24)
        let backgroundRect = CGRect(
            x: labelPos.x - textSize.width / 2,
            y: labelPos.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        context.fill(
            Path(roundedRect: backgroundRect, cornerRadius: 4),
            with: .color(Color.black.opacity(0.7))
        )
        
        // Draw text
        context.draw(areaText, at: labelPos)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        GridBackgroundView()
        GraphCanvasView()
        AnalysisOverlayView()
    }
    .environmentObject(AppState())
}
