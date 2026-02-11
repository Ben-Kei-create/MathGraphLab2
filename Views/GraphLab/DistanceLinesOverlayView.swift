//
//  DistanceLinesOverlayView.swift
//  MathGraph Lab
//
//  Display distance between marked points
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
            
            // 距離表示がオンの時だけ描画
            guard appState.showDistances else { return }
            
            for (pA, pB, dist) in appState.pointDistances {
                let posA = coordSystem.screenPosition(mathX: pA.x, mathY: pA.y)
                let posB = coordSystem.screenPosition(mathX: pB.x, mathY: pB.y)
                
                // 1. 線分を引く（紫色の点線などが見やすいです）
                var path = Path()
                path.move(to: posA)
                path.addLine(to: posB)
                
                context.stroke(
                    path,
                    with: .color(Color.purple.opacity(0.8)),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 5])
                )
                
                // 2. 距離ラベル（中点に表示）
                let mid = CGPoint(x: (posA.x + posB.x)/2, y: (posA.y + posB.y)/2)
                let labelText = Text("\(pA.label)\(pB.label) = \(String(format: "%.2f", dist))")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.purple)
                
                // 文字を見やすくするための背景
                let bgRect = CGRect(x: mid.x - 45, y: mid.y - 12, width: 90, height: 24)
                context.fill(Path(roundedRect: bgRect, cornerRadius: 4), with: .color(.white.opacity(0.8)))
                
                context.draw(labelText, at: mid)
            }
        }
    }
}
