//
//  GraphSelectionOverlay.swift
//  MathGraph Lab
//
//  グラフ拘束移動：交点タップ後のグラフ選択UI
//

import SwiftUI

struct GraphSelectionOverlay: View {
    
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if let pointIndex = appState.constrainedPointIndex,
           appState.intersectionPoints.indices.contains(pointIndex) {
            let intersection = appState.intersectionPoints[pointIndex]
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("グラフを選択してください")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("点 (\(String(format: "%.1f", intersection.x)), \(String(format: "%.1f", intersection.y)))")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        // 放物線ボタン
                        Button(action: {
                            selectGraph(.parabola)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "function")
                                    .font(.system(size: 32))
                                Text("放物線")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .frame(width: 120, height: 100)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        // 直線ボタン
                        Button(action: {
                            selectGraph(.line)
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "line.diagonal")
                                    .font(.system(size: 32))
                                Text("直線")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .frame(width: 120, height: 100)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    
                    Button("キャンセル") {
                        appState.constrainedPointIndex = nil
                        appState.constrainedGraphType = nil
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func selectGraph(_ graphType: AppState.GraphType) {
        appState.constrainedGraphType = graphType
        if appState.isHapticsEnabled {
            HapticManager.shared.impact(style: .medium)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
        GraphSelectionOverlay()
    }
    .environmentObject({
        let state = AppState()
        state.constrainedPointIndex = 0
        state.intersectionPoints = [IntersectionPoint(x: 2.0, y: 4.0)]
        return state
    }())
}
