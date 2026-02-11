//
//  GraphCanvasView.swift
//  MathGraph Lab
//
//  Layer 1: Graph rendering
//  Fixed: Axis labels and scope error
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
                
                // 1. 軸と数字の描画（整理したメソッドを呼び出す）
                drawAxes(context: context, system: system, size: size)
                
                // 2. グラフの色と太さを決定
                let parabolaColor = getParabolaColor()
                let lineColor = getLineColor()
                let lineWidth: CGFloat = appState.appTheme == .blackboard ? 3.5 : 3.0
                
                // 3. 放物線の描画
                if appState.showParabolaGraph {
                    drawParabola(context: context, system: system, parabola: appState.parabola, color: parabolaColor, style: StrokeStyle(lineWidth: lineWidth))
                }
                
                // 4. 直線の描画
                if appState.showLinearGraph {
                    drawLine(context: context, system: system, line: appState.line, color: lineColor, style: StrokeStyle(lineWidth: lineWidth))
                }
            }
        }
        .drawingGroup()
    }
    
    // MARK: - Drawing Logic (bodyの外側に配置)
    
    private func drawAxes(context: GraphicsContext, system: CoordinateSystem, size: CGSize) {
        let center = system.screenPosition(mathX: 0, mathY: 0)

        // 背景テーマに合わせた色（黒板なら白、ライトなら黒）
        let axisColor: Color = (appState.appTheme == .light) ? .black : .white

        // 軸線の描画
        let xAxisPath = Path { p in
            p.move(to: CGPoint(x: 0, y: center.y))
            p.addLine(to: CGPoint(x: size.width, y: center.y))
        }
        context.stroke(xAxisPath, with: .color(axisColor), lineWidth: 2)

        let yAxisPath = Path { p in
            p.move(to: CGPoint(x: center.x, y: 0))
            p.addLine(to: CGPoint(x: center.x, y: size.height))
        }
        context.stroke(yAxisPath, with: .color(axisColor), lineWidth: 2)

        // ズーム倍率に応じた目盛り間隔を計算
        let tickStep = optimalTickStep(for: system)

        // 現在の表示範囲
        let topLeft = system.mathPosition(from: CGPoint(x: 0, y: 0))
        let bottomRight = system.mathPosition(from: CGPoint(x: size.width, y: size.height))

        // --- X軸: 目盛りと数字 ---
        var x = ceil(topLeft.x / tickStep) * tickStep
        while x <= bottomRight.x {
            if abs(x) < tickStep * 0.1 { x += tickStep; continue }
            let pos = system.screenPosition(mathX: x, mathY: 0)

            let tickPath = Path { p in
                p.move(to: CGPoint(x: pos.x, y: center.y - 5))
                p.addLine(to: CGPoint(x: pos.x, y: center.y + 5))
            }
            context.stroke(tickPath, with: .color(axisColor), lineWidth: 1)

            let label = formatTickLabel(x, step: tickStep)
            let text = Text(label).font(.system(size: 10)).foregroundColor(axisColor)
            context.draw(text, at: CGPoint(x: pos.x, y: center.y + 15))
            x += tickStep
        }

        // --- Y軸: 目盛りと数字 ---
        var y = ceil(bottomRight.y / tickStep) * tickStep
        while y <= topLeft.y {
            if abs(y) < tickStep * 0.1 { y += tickStep; continue }
            let pos = system.screenPosition(mathX: 0, mathY: y)

            let tickPath = Path { p in
                p.move(to: CGPoint(x: center.x - 5, y: pos.y))
                p.addLine(to: CGPoint(x: center.x + 5, y: pos.y))
            }
            context.stroke(tickPath, with: .color(axisColor), lineWidth: 1)

            let label = formatTickLabel(y, step: tickStep)
            let text = Text(label).font(.system(size: 10)).foregroundColor(axisColor)
            context.draw(text, at: CGPoint(x: center.x - 15, y: pos.y))
            y += tickStep
        }

        // 原点 0
        context.draw(Text("0").font(.system(size: 10)).foregroundColor(axisColor),
                     at: CGPoint(x: center.x - 10, y: center.y + 10))

        // ラベル
        context.draw(Text("x").font(.system(size: 14, weight: .bold)).foregroundColor(axisColor),
                     at: CGPoint(x: size.width - 15, y: center.y + 15))
        context.draw(Text("y").font(.system(size: 14, weight: .bold)).foregroundColor(axisColor),
                     at: CGPoint(x: center.x + 15, y: 15))
    }

    /// ズーム倍率に応じて最適な目盛り間隔を計算
    /// ラベル同士が重ならないよう、画面上で40〜100px間隔になるステップを選ぶ
    private func optimalTickStep(for system: CoordinateSystem) -> Double {
        let pixelsPerUnit = Double(system.scale) // 1数学単位あたりのピクセル数
        let candidates: [Double] = [0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50]
        let minPixelGap = 40.0

        for step in candidates {
            if step * pixelsPerUnit >= minPixelGap {
                return step
            }
        }
        return 50
    }

    /// 目盛りの数値を適切な書式で表示
    private func formatTickLabel(_ value: Double, step: Double) -> String {
        if step >= 1 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
    
    private func drawParabola(context: GraphicsContext, system: CoordinateSystem, parabola: Parabola, color: Color, style: StrokeStyle) {
        var path = Path()
        let step = 2.0 / system.zoomScale
        let width = system.size.width
        var firstPoint = true
        
        for screenX in stride(from: 0, to: width, by: step) {
            let mathPos = system.mathPosition(from: CGPoint(x: screenX, y: 0))
            let mathY = parabola.a * pow(mathPos.x - parabola.p, 2) + parabola.q
            let screenPos = system.screenPosition(mathX: mathPos.x, mathY: mathY)
            
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
    
    private func getParabolaColor() -> Color {
        switch appState.appTheme {
        case .light: return .blue
        case .dark: return Color(red: 0.4, green: 0.7, blue: 1.0)
        case .blackboard: return Color(red: 0.5, green: 0.9, blue: 0.5)
        }
    }
    
    private func getLineColor() -> Color {
        switch appState.appTheme {
        case .light: return .red
        case .dark: return Color(red: 1.0, green: 0.5, blue: 0.5)
        case .blackboard: return Color(red: 1.0, green: 0.9, blue: 0.5)
        }
    }
}
