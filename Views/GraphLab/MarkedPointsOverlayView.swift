//
//  MarkedPointsOverlayView.swift
//  MathGraph Lab
//
//  Display user-marked points with coordinates
//

import SwiftUI

struct MarkedPointsOverlayView: View {
    
    @EnvironmentObject var appState: AppState
    
    private let pointRadius: CGFloat = 8.0
    private let labelOffset: CGFloat = 20.0
    
    var body: some View {
        Canvas { context, size in
            let coordSystem = CoordinateSystem(
                size: size,
                zoomScale: appState.zoomScale,
                panOffset: appState.panOffset
            )
            
            // 各点を描画
            for point in appState.markedPoints {
                let screenPos = coordSystem.screenPosition(mathX: point.x, mathY: point.y)
                
                // 点の円
                let circle = Circle()
                    .path(in: CGRect(
                        x: screenPos.x - pointRadius,
                        y: screenPos.y - pointRadius,
                        width: pointRadius * 2,
                        height: pointRadius * 2
                    ))
                
                // 塗りつぶし（オレンジ）
                context.fill(circle, with: .color(Color.orange))
                
                // 枠線（白）
                context.stroke(
                    circle,
                    with: .color(Color.white),
                    lineWidth: 2.5
                )
                
                // ラベル（A, B, C...）
                let label = Text(point.label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                
                context.draw(
                    label,
                    at: CGPoint(x: screenPos.x + labelOffset, y: screenPos.y - labelOffset)
                )
                
                // 座標表示
                let coordText = Text("(\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y)))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange.opacity(0.9))
                
                // 背景（読みやすさのため）
                let textSize = CGSize(width: 60, height: 16)
                let textRect = CGRect(
                    x: screenPos.x + labelOffset - textSize.width / 2,
                    y: screenPos.y - labelOffset + 18,
                    width: textSize.width,
                    height: textSize.height
                )
                
                context.fill(
                    Path(roundedRect: textRect, cornerRadius: 4),
                    with: .color(Color.white.opacity(0.9))
                )
                
                context.draw(
                    coordText,
                    at: CGPoint(x: screenPos.x + labelOffset, y: screenPos.y - labelOffset + 26)
                )
            }
        }
    }
}

#Preview {
    ZStack {
        GridBackgroundView()
        MarkedPointsOverlayView()
    }
    .environmentObject(AppState())
}
