//
//  DistanceLinesOverlayView.swift
//  MathGraph Lab
//
//  Display line segments and distances between marked points
//

import SwiftUI

struct DistanceLinesOverlayView: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Canvas { context, size in
            let coordSystem = CoordinateSystem(
                size: size,
                zoomScale: appState.zoomScale,
                panOffset: appState.panOffset
            )
            
            // 距離表示がOFFなら何もしない
            guard appState.showDistances else { return }
            
            // 連続する点を線で結ぶ
            guard appState.markedPoints.count >= 2 else { return }
            
            for i in 0..<appState.markedPoints.count - 1 {
                let pointA = appState.markedPoints[i]
                let pointB = appState.markedPoints[i + 1]
                
                let posA = coordSystem.screenPosition(mathX: pointA.x, mathY: pointA.y)
                let posB = coordSystem.screenPosition(mathX: pointB.x, mathY: pointB.y)
                
                // 線分を描画
                var path = Path()
                path.move(to: posA)
                path.addLine(to: posB)
                
                context.stroke(
                    path,
                    with: .color(Color.purple),
                    lineWidth: 2.5
                )
                
                // 距離を計算
                let dx = pointB.x - pointA.x
                let dy = pointB.y - pointA.y
                let distance = sqrt(dx * dx + dy * dy)
                
                // 中点に距離を表示
                let midX = (posA.x + posB.x) / 2
                let midY = (posA.y + posB.y) / 2
                
                let distanceText = Text("\(pointA.label)\(pointB.label) = \(String(format: "%.2f", distance))")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                
                // 背景
                let textSize = CGSize(width: 100, height: 24)
                let backgroundRect = CGRect(
                    x: midX - textSize.width / 2,
                    y: midY - textSize.height / 2,
                    width: textSize.width,
                    height: textSize.height
                )
                
                context.fill(
                    Path(roundedRect: backgroundRect, cornerRadius: 4),
                    with: .color(Color.white.opacity(0.9))
                )
                
                context.draw(distanceText, at: CGPoint(x: midX, y: midY))
            }
        }
    }
}

#Preview {
    ZStack {
        GridBackgroundView()
        DistanceLinesOverlayView()
    }
    .environmentObject(AppState())
}
