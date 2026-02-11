//
//  ControlPanelOverlay.swift
//  MathGraph Lab
//
//  Layer 5: Control panel with input fields and parameter controls
//  改善版：表示/非表示の切り替え、タップで閉じる機能を追加
//

import SwiftUI

// MARK: - Control Panel Overlay
struct ControlPanelOverlay: View {
    
    @EnvironmentObject var appState: AppState
    
    // パネルの表示状態
    @State private var isPanelVisible: Bool = false
    
    // Text field bindings
    @State private var aText: String = "1.0"
    @State private var mText: String = "1.0"
    @State private var nText: String = "2.0"
    @State private var pText: String = "0.0"
    @State private var qText: String = "0.0"
    
    // Fraction input state
    @State private var numerator: String = "1"
    @State private var denominator: String = "1"
    
    var body: some View {
        ZStack {
            // パネルが開いている時の背景タップエリア
            if isPanelVisible {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 背景タップでパネルを閉じる
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isPanelVisible = false
                        }
                    }
            }
            
            VStack(spacing: 0) {
                Spacer()
                
                if isPanelVisible {
                    // コントロールパネル本体
                    panelContent
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // 閉じている時：小さなボタンのみ表示
                    compactButton
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            syncTextFields()
        }
    }
    
    // MARK: - Compact Button (閉じている時)
    
    private var compactButton: some View {
        HStack(spacing: 12) {
            // メインの開くボタン
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isPanelVisible = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 18, weight: .semibold))
                    Text("パラメータ")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.blue)
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                )
            }
            
            // クイックアクションボタン
            if appState.isGeometryModeEnabled {
                Button(action: {
                    appState.clearGeometry()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.orange))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
            }
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Panel Content (開いている時)
    
    private var panelContent: some View {
        VStack(spacing: 12) {
            // ヘッダー（✔ボタン付き）
            HStack {
                Text("パラメータ設定")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                // ✔ボタン（決定して閉じる）
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPanelVisible = false
                    }
                    
                    if appState.isHapticsEnabled {
                        HapticManager.shared.impact(style: .light)
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            Divider()
            
            // Mode toggles
            HStack(spacing: 12) {
                Toggle(isOn: $appState.isAreaModeEnabled) {
                    Label("面積", systemImage: "triangle")
                        .font(.system(size: 13, weight: .medium))
                }
                .toggleStyle(.button)
                .tint(.green)
                
                Toggle(isOn: $appState.isGeometryModeEnabled) {
                    Label("作図", systemImage: "pencil.tip.crop.circle")
                        .font(.system(size: 13, weight: .medium))
                }
                .toggleStyle(.button)
                .tint(.orange)
                
                Spacer()
                
                Toggle(isOn: $appState.isProEnabled) {
                    Label("Pro", systemImage: "star.fill")
                        .font(.system(size: 13, weight: .medium))
                }
                .toggleStyle(.button)
                .tint(.purple)
            }
            .padding(.horizontal)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 16) {
                    // Parabola section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("放物線: y = a(x - p)² + q")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.blue)
                            
                            Spacer()
                            
                            Button(action: {
                                toggleCoefficientInputMode()
                            }) {
                                Image(systemName: appState.coefficientInputMode == .fraction ? "number" : "divide")
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                    .padding(6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            if appState.coefficientInputMode == .decimal {
                                ParameterInput(
                                    label: "a",
                                    text: $aText,
                                    range: -5.0...5.0,
                                    color: .blue
                                ) { value in
                                    appState.updateParabolaA(value)
                                }
                            } else {
                                FractionInput(
                                    label: "a",
                                    numerator: $numerator,
                                    denominator: $denominator,
                                    color: .blue
                                ) { value in
                                    appState.updateParabolaA(value)
                                    aText = String(format: "%.2f", value)
                                }
                            }
                            
                            if appState.isProEnabled {
                                ParameterInput(
                                    label: "p",
                                    text: $pText,
                                    range: -5.0...5.0,
                                    color: .blue
                                ) { value in
                                    appState.updateParabolaP(value)
                                }
                                
                                ParameterInput(
                                    label: "q",
                                    text: $qText,
                                    range: -5.0...5.0,
                                    color: .blue
                                ) { value in
                                    appState.updateParabolaQ(value)
                                }
                            }
                        }
                        
                        if appState.isProEnabled {
                            VStack(spacing: 6) {
                                HStack(spacing: 8) {
                                    Text("p")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Slider(value: Binding(
                                        get: { appState.parabola.p },
                                        set: { newValue in
                                            appState.updateParabolaP(newValue, snap: appState.isGridSnapEnabled)
                                            pText = String(format: "%.1f", newValue)
                                            triggerHapticIfInteger(newValue)
                                        }
                                    ), in: -5.0...5.0)
                                    .tint(.blue)
                                    
                                    Text(String(format: "%.1f", appState.parabola.p))
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 35)
                                }
                                
                                HStack(spacing: 8) {
                                    Text("q")
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundColor(.blue)
                                        .frame(width: 20)
                                    
                                    Slider(value: Binding(
                                        get: { appState.parabola.q },
                                        set: { newValue in
                                            appState.updateParabolaQ(newValue, snap: appState.isGridSnapEnabled)
                                            qText = String(format: "%.1f", newValue)
                                            triggerHapticIfInteger(newValue)
                                        }
                                    ), in: -5.0...5.0)
                                    .tint(.blue)
                                    
                                    Text(String(format: "%.1f", appState.parabola.q))
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(.secondary)
                                        .frame(width: 35)
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Divider()
                    
                    // Line section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("直線: y = mx + n")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(.red)
                        
                        HStack(spacing: 12) {
                            ParameterInput(
                                label: "m",
                                text: $mText,
                                range: -5.0...5.0,
                                color: .red
                            ) { value in
                                appState.updateLineM(value)
                            }
                            
                            ParameterInput(
                                label: "n",
                                text: $nText,
                                range: -10.0...10.0,
                                color: .red
                            ) { value in
                                appState.updateLineN(value)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxHeight: 300)
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    resetParameters()
                }) {
                    Label("リセット", systemImage: "arrow.counterclockwise")
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                
                if appState.isGeometryModeEnabled {
                    Button(action: {
                        appState.clearGeometry()
                    }) {
                        Label("クリア", systemImage: "trash")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 20, y: -10)
        )
                .onChange(of: appState.parabola.a) { oldValue, newValue in
                    if appState.coefficientInputMode == .decimal {
                        aText = String(format: "%.2f", newValue)
                    }
                }
                .onChange(of: appState.parabola.p) { oldValue, newValue in
                    pText = String(format: "%.1f", newValue)
                }
                .onChange(of: appState.parabola.q) { oldValue, newValue in
                    qText = String(format: "%.1f", newValue)
                }
                .onChange(of: appState.line.m) { oldValue, newValue in
                    mText = String(format: "%.2f", newValue)
                }
                .onChange(of: appState.line.n) { oldValue, newValue in
                    nText = String(format: "%.2f", newValue)
                }
            } // body の閉じカッコ
    
    // MARK: - Helper Methods
    
    private func syncTextFields() {
        aText = String(format: "%.2f", appState.parabola.a)
        mText = String(format: "%.2f", appState.line.m)
        nText = String(format: "%.2f", appState.line.n)
        pText = String(format: "%.1f", appState.parabola.p)
        qText = String(format: "%.1f", appState.parabola.q)
    }
    
    private func resetParameters() {
        appState.reset()
        syncTextFields()
        numerator = "1"
        denominator = "1"
        
        if appState.isHapticsEnabled {
            HapticManager.shared.impact(style: .medium)
        }
    }
    
    private func toggleCoefficientInputMode() {
        appState.coefficientInputMode = appState.coefficientInputMode == .decimal ? .fraction : .decimal
        
        if appState.coefficientInputMode == .fraction {
            let value = appState.parabola.a
            if abs(value - round(value)) < 0.01 {
                numerator = String(Int(round(value)))
                denominator = "1"
            }
        }
    }
    
    private func triggerHapticIfInteger(_ value: Double) {
        guard appState.isHapticsEnabled else { return }
        if abs(value - round(value)) < 0.05 {
            HapticManager.shared.impact(style: .light)
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.gray.opacity(0.2)
            .ignoresSafeArea()
        
        ControlPanelOverlay()
    }
    .environmentObject(AppState())
}
