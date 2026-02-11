//
//  GraphCanvasView.swift
//  MathGraph Lab
//
//  Layer 1: Graph rendering
//  Fixed: Incorrect argument labels in CoordinateSystem calls
//

import SwiftUI

struct GraphCanvasView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let system = CoordinateSystem(
                    size: size,
                    zoomScale: appState.zoomScale,
                    panOffset: appState.panOffset
                )
                
                // 1. Draw Axes
                drawAxes(context: context, system: system, size: size)
                
                // 2. Draw Parabola (Ghost & Real)
                if let ghost = appState.previousParabola, appState.showParabolaGraph {
                    drawParabola(context: context, system: system, parabola: ghost, color: .blue.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                if appState.showParabolaGraph {
                    drawParabola(context: context, system: system, parabola: appState.parabola, color: .blue, style: StrokeStyle(lineWidth: 3))
                }
                
                // 3. Draw Line (Ghost & Real)
                if let ghost = appState.previousLine, appState.showLinearGraph {
                    drawLine(context: context, system: system, line: ghost, color: .red.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                if appState.showLinearGraph {
                    drawLine(context: context, system: system, line: appState.line, color: .red, style: StrokeStyle(lineWidth: 3))
                }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Drawing Logic
    
    private func drawAxes(context: GraphicsContext, system: CoordinateSystem, size: CGSize) {
        // 修正: argument label 'from:'
        let center = system.screenPosition(mathX: 0, mathY: 0)
        
        // X Axis
        let xAxisPath = Path { p in
            p.move(to: CGPoint(x: 0, y: center.y))
            p.addLine(to: CGPoint(x: size.width, y: center.y))
        }
        context.stroke(xAxisPath, with: .color(.black), lineWidth: 2)
        
        // Y Axis
        let yAxisPath = Path { p in
            p.move(to: CGPoint(x: center.x, y: 0))
            p.addLine(to: CGPoint(x: center.x, y: size.height))
        }
        context.stroke(yAxisPath, with: .color(.black), lineWidth: 2)
        
        // Calculate visible range for dynamic numbering
        // 修正: argument label 'from:'
        let topLeft = system.mathPosition(from: CGPoint(x: 0, y: 0))
        let bottomRight = system.mathPosition(from: CGPoint(x: size.width, y: size.height))
        
        let startX = Int(floor(topLeft.x))
        let endX = Int(ceil(bottomRight.x))
        let startY = Int(floor(bottomRight.y)) // Math Y increases upwards
        let endY = Int(ceil(topLeft.y))
        
        // Draw Ticks and Numbers
        for i in startX...endX {
            if i == 0 { continue }
            let pos = system.screenPosition(mathX: Double(i), mathY: 0)
            
            // Draw tick
            let tickPath = Path { p in
                p.move(to: CGPoint(x: pos.x, y: center.y - 5))
                p.addLine(to: CGPoint(x: pos.x, y: center.y + 5))
            }
            context.stroke(tickPath, with: .color(.black), lineWidth: 1)
            
            // Draw number
            let text = Text("\(i)").font(.system(size: 10))
            context.draw(text, at: CGPoint(x: pos.x, y: center.y + 15))
        }
        
        for i in startY...endY {
            if i == 0 { continue }
            let pos = system.screenPosition(mathX: 0, mathY: Double(i))
            
            // Draw tick
            let tickPath = Path { p in
                p.move(to: CGPoint(x: center.x - 5, y: pos.y))
                p.addLine(to: CGPoint(x: center.x + 5, y: pos.y))
            }
            context.stroke(tickPath, with: .color(.black), lineWidth: 1)
            
            // Draw number
            let text = Text("\(i)").font(.system(size: 10))
            // Adjust text position to not overlap axis
            context.draw(text, at: CGPoint(x: center.x - 15, y: pos.y))
        }
        
        // Draw arrows
        context.draw(Text("x").font(.system(size: 14, weight: .bold)), at: CGPoint(x: size.width - 15, y: center.y + 15))
        context.draw(Text("y").font(.system(size: 14, weight: .bold)), at: CGPoint(x: center.x + 15, y: 15))
    }
    
    private func drawParabola(context: GraphicsContext, system: CoordinateSystem, parabola: Parabola, color: Color, style: StrokeStyle) {
        var path = Path()
        let step = 2.0 / system.zoomScale // Dynamic resolution
        let width = system.size.width
        
        var firstPoint = true
        
        // Iterate screen X pixels for smooth curve
        for screenX in stride(from: 0, to: width, by: step) {
            // 修正: argument label 'from:'
            let mathPos = system.mathPosition(from: CGPoint(x: screenX, y: 0))
            // y = a(x-p)^2 + q
            let mathY = parabola.a * pow(mathPos.x - parabola.p, 2) + parabola.q
            
            let screenPos = system.screenPosition(mathX: mathPos.x, mathY: mathY)
            
            // Clip largely out of bounds points to prevent drawing glitches
            if screenPos.y > -1000 && screenPos.y < system.size.height + 1000 {
                if firstPoint {
                    path.move(to: screenPos)
                    firstPoint = false
                } else {
                    path.addLine(to: screenPos)
                }
            }
        }
        context.stroke(path, with: .color(color), style: style)
    }
    
    private func drawLine(context: GraphicsContext, system: CoordinateSystem, line: Line, color: Color, style: StrokeStyle) {
        // Find intersection with visible bounds
        // y = mx + n
        // Simply draw from far left to far right of visible math coordinates
        
        // 修正: argument label 'from:'
        let topLeft = system.mathPosition(from: CGPoint(x: 0, y: 0))
        let bottomRight = system.mathPosition(from: CGPoint(x: system.size.width, y: system.size.height))
        
        let startX = topLeft.x
        let endX = bottomRight.x
        
        let startY = line.m * startX + line.n
        let endY = line.m * endX + line.n
        
        let p1 = system.screenPosition(mathX: startX, mathY: startY)
        let p2 = system.screenPosition(mathX: endX, mathY: endY)
        
        let path = Path { p in
            p.move(to: p1)
            p.addLine(to: p2)
        }
        context.stroke(path, with: .color(color), style: style)
    }
}
