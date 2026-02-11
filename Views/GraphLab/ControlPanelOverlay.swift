import SwiftUI

// MARK: - Control Panel Overlay
struct ControlPanelOverlay: View {
    
    @EnvironmentObject var appState: AppState
    
    // パネルの表示状態
    @State private var isPanelVisible: Bool = false
    
    // テキスト入力用の一時変数
    @State private var aText: String = "1.0"
    @State private var mText: String = "1.0"
    @State private var nText: String = "2.0"
    @State private var pText: String = "0.0"
    @State private var qText: String = "0.0"
    @State private var numerator: String = "1"
    @State private var denominator: String = "1"
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            if isPanelVisible {
                panelContent
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                compactButton
                    .transition(.scale.combined(with: .opacity))
            }
        }
        // ここが重要：背景の透明な壁を削除し、パネル部分だけを表示
        .onAppear { syncTextFields() }
        .onChange(of: appState.parabola.a) { _, _ in updateTexts() }
        .onChange(of: appState.parabola.p) { _, _ in updateTexts() }
        .onChange(of: appState.parabola.q) { _, _ in updateTexts() }
        .onChange(of: appState.line.m) { _, _ in updateTexts() }
        .onChange(of: appState.line.n) { _, _ in updateTexts() }
    }
    
    private func updateTexts() {
        if appState.coefficientInputMode == .decimal {
            aText = String(format: "%.2f", appState.parabola.a)
        }
        pText = String(format: "%.1f", appState.parabola.p)
        qText = String(format: "%.1f", appState.parabola.q)
        mText = String(format: "%.2f", appState.line.m)
        nText = String(format: "%.2f", appState.line.n)
    }
    
    // MARK: - Compact Button (開くボタン)
    private var compactButton: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isPanelVisible = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3")
                    Text("パラメータ操作")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.blue)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                )
            }
            
            // ゴミ箱（クリア）ボタン
            if appState.isGeometryModeEnabled {
                Button(action: {
                    appState.clearMarkedPoints()
                    appState.clearGeometry()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.orange))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Panel Content (開いた状態)
    private var panelContent: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                Text("設定パネル")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPanelVisible = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
            
            // 機能切り替えトグル
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Toggle(isOn: $appState.isAreaModeEnabled) {
                        Label("面積", systemImage: "triangle").font(.system(size: 12))
                    }
                    .toggleStyle(.button).tint(.green)
                    
                    Toggle(isOn: $appState.isGeometryModeEnabled) {
                        Label("作図", systemImage: "pencil.tip.crop.circle").font(.system(size: 12))
                    }
                    .toggleStyle(.button).tint(.orange)
                    
                    Toggle(isOn: $appState.showDistances) {
                        Label("距離", systemImage: "ruler").font(.system(size: 12))
                    }
                    .toggleStyle(.button).tint(.purple)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            
            Divider()
            
            // パラメータ操作エリア
            ScrollView {
                VStack(spacing: 20) {
                    
                    // 放物線セクション
                    VStack(spacing: 10) {
                        HStack {
                            Text("放物線").font(.headline).foregroundColor(.blue)
                            Spacer()
                            // ★表示/非表示トグル
                            Button(action: { appState.showParabolaGraph.toggle() }) {
                                Image(systemName: appState.showParabolaGraph ? "eye" : "eye.slash")
                                    .foregroundColor(appState.showParabolaGraph ? .blue : .gray)
                            }
                        }
                        
                        if appState.showParabolaGraph {
                            if appState.coefficientInputMode == .decimal {
                                ParameterInput(label: "a", text: $aText, range: -5.0...5.0, color: .blue) { appState.updateParabolaA($0) }
                            } else {
                                FractionInput(label: "a", numerator: $numerator, denominator: $denominator, color: .blue) { value in
                                    appState.updateParabolaA(value)
                                    aText = String(format: "%.2f", value)
                                }
                            }
                            
                            // 平行移動 (p, q)
                            HStack(spacing: 16) {
                                ParameterSlider(label: "p", value: Binding(
                                    get: { appState.parabola.p },
                                    set: { appState.updateParabolaP($0, snap: appState.isGridSnapEnabled) }
                                ), range: -5...5, color: .blue)
                                
                                ParameterSlider(label: "q", value: Binding(
                                    get: { appState.parabola.q },
                                    set: { appState.updateParabolaQ($0, snap: appState.isGridSnapEnabled) }
                                ), range: -5...5, color: .blue)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.05)))
                    
                    // 直線セクション
                    VStack(spacing: 10) {
                        HStack {
                            Text("直線").font(.headline).foregroundColor(.red)
                            Spacer()
                            // ★表示/非表示トグル
                            Button(action: { appState.showLinearGraph.toggle() }) {
                                Image(systemName: appState.showLinearGraph ? "eye" : "eye.slash")
                                    .foregroundColor(appState.showLinearGraph ? .red : .gray)
                            }
                        }
                        
                        if appState.showLinearGraph {
                            HStack(spacing: 16) {
                                ParameterSlider(label: "m", value: Binding(
                                    get: { appState.line.m },
                                    set: { appState.updateLineM($0) }
                                ), range: -5...5, color: .red)
                                
                                ParameterSlider(label: "n", value: Binding(
                                    get: { appState.line.n },
                                    set: { appState.updateLineN($0) }
                                ), range: -10...10, color: .red)
                            }
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.05)))
                    
                    // 2点からの直線生成ボタン
                    if appState.isGeometryModeEnabled && appState.markedPoints.count >= 2 {
                        Button(action: {
                            withAnimation { appState.createLineFromPoints() }
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("2点を通る直線を作成")
                            }
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                        }
                    }
                    
                    Color.clear.frame(height: 20)
                }
                .padding()
            }
            .frame(height: 300)
        }
        .background(Material.regular) // すりガラス効果
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
    
    private func syncTextFields() {
        updateTexts()
    }
}

// MARK: - Components (Included to prevent build errors)

struct ParameterInput: View {
    let label: String
    @Binding var text: String
    let range: ClosedRange<Double>
    let color: Color
    let onCommit: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
            
            TextField("0.0", text: $text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14, design: .monospaced))
                .multilineTextAlignment(.center)
                .onChange(of: text) { _, _ in commitValue() }
        }
    }
    
    private func commitValue() {
        if let value = Double(text) {
            let clamped = min(max(value, range.lowerBound), range.upperBound)
            onCommit(clamped)
        }
    }
}

struct FractionInput: View {
    let label: String
    @Binding var numerator: String
    @Binding var denominator: String
    let color: Color
    let onCommit: (Double) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
            
            HStack(spacing: 4) {
                TextField("1", text: $numerator)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .onChange(of: numerator) { _, _ in commitFraction() }
                
                Text("/")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                
                TextField("1", text: $denominator)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .onChange(of: denominator) { _, _ in commitFraction() }
            }
        }
    }
    
    private func commitFraction() {
        guard let num = Double(numerator),
              let den = Double(denominator),
              den != 0 else { return }
        onCommit(num / den)
    }
}

struct ParameterSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).font(.caption).bold().foregroundColor(color)
                Spacer()
                Text(String(format: "%.1f", value)).font(.caption).monospacedDigit()
            }
            Slider(value: $value, in: range)
                .tint(color)
        }
    }
}
