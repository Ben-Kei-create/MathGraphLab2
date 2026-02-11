//
//  EquationOverlayView.swift
//  MathGraph Lab
//
//  Displays the current equations on the canvas
//  Update: Fixed HitTesting issues (Allows touch pass-through)
//

import SwiftUI

struct EquationOverlayView: View {
    @EnvironmentObject var appState: AppState
    
    @GestureState private var dragParabolaState: CGSize = .zero
    @GestureState private var dragLineState: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            // --- 放物線の式 ---
            if appState.showParabolaGraph {
                equationLabel(text: parabolaEquationString(), color: .blue)
                    .offset(x: appState.parabolaLabelOffset.width + dragParabolaState.width,
                            y: appState.parabolaLabelOffset.height + dragParabolaState.height)
                    .gesture(
                        DragGesture()
                            .updating($dragParabolaState) { value, state, _ in state = value.translation }
                            .onEnded { value in
                                appState.parabolaLabelOffset.width += value.translation.width
                                appState.parabolaLabelOffset.height += value.translation.height
                            }
                    )
                    .padding(.top, 0)
            }
            
            // --- 直線の式 ---
            if appState.showLinearGraph {
                equationLabel(text: lineEquationString(), color: .red)
                    .offset(x: appState.lineLabelOffset.width + dragLineState.width,
                            y: appState.lineLabelOffset.height + dragLineState.height)
                    .gesture(
                        DragGesture()
                            .updating($dragLineState) { value, state, _ in state = value.translation }
                            .onEnded { value in
                                appState.lineLabelOffset.width += value.translation.width
                                appState.lineLabelOffset.height += value.translation.height
                            }
                    )
                    .padding(.top, 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 100)
        .padding(.leading, 20)
        // ★修正: 透明な壁を作っていた以下の行を削除しました。
        // .contentShape(Rectangle())
        // .allowsHitTesting(true)
    }
    
    // ラベルのデザイン
    private func equationLabel(text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text)
                .font(.system(size: 14, weight: .bold, design: .serif))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
        )
    }
    
    // --- 数式ロジック (変更なし) ---
    private func parabolaEquationString() -> String {
        let a = appState.parabola.a; let p = appState.parabola.p; let q = appState.parabola.q
        let aStr = toFractionString(a)
        
        if appState.showAdvancedParabola {
            let pPart = (p == 0) ? "x²" : "(x \(signStrForInner(-p)))²"
            let qPart = (q == 0) ? "" : " \(signStrForOuter(q))"
            let aDisplay: String = (a == 1) ? "" : (a == -1 ? "-" : aStr)
            return "y = \(aDisplay)\(pPart)\(qPart)"
        } else {
            if p == 0 && q == 0 {
                let aDisplay = (a == 1) ? "" : (a == -1 ? "-" : aStr)
                return "y = \(aDisplay)x²"
            } else {
                let pPart = (p == 0) ? "x²" : "(x \(signStrForInner(-p)))²"
                let qPart = (q == 0) ? "" : " \(signStrForOuter(q))"
                let aDisplay = (a == 1) ? "" : (a == -1 ? "-" : aStr)
                return "y = \(aDisplay)\(pPart)\(qPart)"
            }
        }
    }
    
    private func lineEquationString() -> String {
        let m = appState.line.m; let n = appState.line.n
        let mDisplay: String = (m == 1) ? "" : (m == -1 ? "-" : toFractionString(m))
        let nPart = (n == 0) ? "" : " \(signStrForOuter(n))"
        if m == 0 { return "y = \(toFractionString(n))" }
        else { return "y = \(mDisplay)x\(nPart)" }
    }
    
    private func signStrForInner(_ val: Double) -> String {
        let str = toFractionString(abs(val))
        return val >= 0 ? "+ \(str)" : "- \(str)"
    }
    private func signStrForOuter(_ val: Double) -> String {
        let str = toFractionString(abs(val))
        return val >= 0 ? "+ \(str)" : "- \(str)"
    }
    private func toFractionString(_ value: Double) -> String {
        let tolerance = 0.001
        if abs(value - round(value)) < tolerance { return String(format: "%.0f", value) }
        for denominator in 2...20 {
            let numerator = value * Double(denominator)
            if abs(numerator - round(numerator)) < tolerance {
                let n = Int(round(numerator))
                return "\(n)/\(denominator)"
            }
        }
        return String(format: "%.2f", value)
    }
}
