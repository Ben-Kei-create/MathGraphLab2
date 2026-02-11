//
//  GraphCanvasView.swift
//  MathGraph Lab
//
//  Layer 2: Graph rendering for parabola and line with ghosting
//  Implements IDD Section 3.2 Layer 2 specifications
//

import SwiftUI

// MARK: - Graph Canvas View
/// Renders the parabola and line functions
/// Includes ghosting effect for previous state during drag operations
struct GraphCanvasView: View {
    
    @EnvironmentObject var appState: AppState
    
    // Graph configuration
    private let mathRange: ClosedRange<Double> = -10...10
    private let stepSize: Double = 0.1  // IDD: stride by 0.1 for smooth curves
    private let lineWidth: CGFloat = 3.0
    private let ghostLineWidth: CGFloat = 2.0
    
    var body: some View {
        Canvas { context, size in
            // Create coordinate conversion helper
            // Create coordinate conversion helper
            let coordSystem = CoordinateSystem(
                size: size,
                zoomScale: appState.zoomScale,
                panOffset: appState.panOffset
            )
            
            // Draw ghost graphs first (behind current graphs)
            if let previousParabola = appState.previousParabola {
                drawParabola(
                    context: context,
                    size: size,
                    parabola: previousParabola,
                    coordSystem: coordSystem,
                    isGhost: true
                )
            }
            
            if let previousLine = appState.previousLine {
                drawLine(
                    context: context,
                    size: size,
                    line: previousLine,
                    coordSystem: coordSystem,
                    isGhost: true
                )
            }
            
            // Draw current graphs on top
            drawParabola(
                context: context,
                size: size,
                parabola: appState.parabola,
                coordSystem: coordSystem,
                isGhost: false
            )
            
            drawLine(
                context: context,
                size: size,
                line: appState.line,
                coordSystem: coordSystem,
                isGhost: false
            )
        }
    }
    
    // MARK: - Drawing Methods
    
    /// Draw parabola: y = a(x - p)² + q
    private func drawParabola(
        context: GraphicsContext,
        size: CGSize,
        parabola: Parabola,
        coordSystem: CoordinateSystem,
        isGhost: Bool
    ) {
        // ★追加
        guard appState.showParabolaGraph else { return }
        
        var path = Path()
        var isFirstPoint = true
        
        // IDD: Use stride(from: -10, through: 10, by: 0.1) for smooth curves
        for x in stride(from: mathRange.lowerBound, through: mathRange.upperBound, by: stepSize) {
            let y = parabola.evaluate(at: x)
            
            // Skip points that are too far outside visible range
            guard abs(y) < 50 else { continue }
            
            let screenPoint = coordSystem.screenPosition(mathX: x, mathY: y)
            
            // Check if point is within canvas bounds (with margin)
            guard screenPoint.y >= -100 && screenPoint.y <= size.height + 100 else {
                isFirstPoint = true
                continue
            }
            
            if isFirstPoint {
                path.move(to: screenPoint)
                isFirstPoint = false
            } else {
                path.addLine(to: screenPoint)
            }
        }
        
        // IDD Section 5: Parabola color is System Blue
        let color = Color.blue
        
        if isGhost {
            // Ghost style: dashed gray line
            context.stroke(
                path,
                with: .color(Color.gray.opacity(0.4)),
                style: StrokeStyle(
                    lineWidth: ghostLineWidth,
                    dash: [5, 5]
                )
            )
        } else {
            // Normal style: solid colored line
            context.stroke(
                path,
                with: .color(color),
                lineWidth: lineWidth
            )
        }
    }
    
    /// Draw line: y = mx + n
    private func drawLine(
        context: GraphicsContext,
        size: CGSize,
        line: Line,
        coordSystem: CoordinateSystem,
        isGhost: Bool
    ) {
        // ★追加
        guard appState.showLinearGraph else { return }
        
        var path = Path()
        
        // For linear functions, we only need two points
        // Calculate intersection with canvas boundaries
        let mathBounds = coordSystem.mathBounds()
        
        let x1 = mathBounds.minX
        let y1 = line.evaluate(at: x1)
        
        let x2 = mathBounds.maxX
        let y2 = line.evaluate(at: x2)
        
        let point1 = coordSystem.screenPosition(mathX: x1, mathY: y1)
        let point2 = coordSystem.screenPosition(mathX: x2, mathY: y2)
        
        path.move(to: point1)
        path.addLine(to: point2)
        
        // IDD Section 5: Line color is System Red
        let color = Color.red
        
        if isGhost {
            // Ghost style: dashed gray line
            context.stroke(
                path,
                with: .color(Color.gray.opacity(0.4)),
                style: StrokeStyle(
                    lineWidth: ghostLineWidth,
                    dash: [5, 5]
                )
            )
        } else {
            // Normal style: solid colored line
            context.stroke(
                path,
                with: .color(color),
                lineWidth: lineWidth
            )
        }
    }
    
    // MARK: - Helper Methods
    

}

// MARK: - Preview
#Preview {
    ZStack {
        GridBackgroundView()
        GraphCanvasView()
    }
    .environmentObject(AppState())
}
