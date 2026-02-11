//
//  ControlPanelOverlay.swift
//  MathGraph Lab
//
//  Layer 5: Control panel with coordinate input mode
//  Update: Added "Reset Labels" button
//

import SwiftUI

struct ControlPanelOverlay: View {
    
    @EnvironmentObject var appState: AppState
    
    @State private var isPanelVisible: Bool = false
    
    // Decimal Input States
    @State private var aText: String = "1.0"
    @State private var pText: String = "0.0"
    @State private var qText: String = "0.0"
    @State private var mText: String = "1.0"
    @State private var nText: String = "2.0"
    
    // Fraction Input States
    @State private var aNum: String = "1"; @State private var aDen: String = "1"
    @State private var pNum: String = "0"; @State private var pDen: String = "1"
    @State private var qNum: String = "0"; @State private var qDen: String = "1"
    @State private var mNum: String = "1"; @State private var mDen: String = "1"
    @State private var nNum: String = "2"; @State private var nDen: String = "1"
    
    // Geometry Input States
    @State private var inputX: String = ""
    @State private var inputY: String = ""
    
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
        .onAppear { syncValuesToText() }
        .onChange(of: appState.parabola.a) { _, _ in syncValuesToText() }
        .onChange(of: appState.parabola.p) { _, _ in syncValuesToText() }
        .onChange(of: appState.parabola.q) { _, _ in syncValuesToText() }
        .onChange(of: appState.line.m) { _, _ in syncValuesToText() }
        .onChange(of: appState.line.n) { _, _ in syncValuesToText() }
    }
    
    private func syncValuesToText() {
        if appState.coefficientInputMode == .decimal {
            aText = String(format: "%.2f", appState.parabola.a)
            pText = String(format: "%.1f", appState.parabola.p)
            qText = String(format: "%.1f", appState.parabola.q)
            mText = String(format: "%.2f", appState.line.m)
            nText = String(format: "%.2f", appState.line.n)
        }
    }
    
    // MARK: - Compact Button
    private var compactButton: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isPanelVisible = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: appState.isGeometryModeEnabled ? "pencil.and.outline" : "slider.horizontal.3")
                    Text(appState.isGeometryModeEnabled ? "座標入力パネル" : "パラメータ操作")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(appState.isGeometryModeEnabled ? Color.orange : Color.blue)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                )
            }
            
            if appState.isGeometryModeEnabled {
                Button(action: {
                    appState.clearMarkedPoints()
                    appState.clearGeometry()
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.red))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Panel Content
    private var panelContent: some View {
        VStack(spacing: 0) {
            // ヘッダー
            HStack {
                if appState.isGeometryModeEnabled {
                    Text("作図・座標入力").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                } else {
                    HStack(spacing: 12) {
                        Text("パラメータ設定").font(.system(size: 14, weight: .bold)).foregroundColor(.secondary)
                        
                        Picker("Input Mode", selection: $appState.coefficientInputMode) {
                            ForEach(AppState.InputMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                        
                        // ★追加: ラベル位置リセットボタン
                        // (ラベルが移動しているときだけ表示)
                        if appState.parabolaLabelOffset != .zero || appState.lineLabelOffset != .zero {
                            Button(action: {
                                withAnimation {
                                    appState.resetLabelPositions()
                                }
                            }) {
                                Image(systemName: "arrow.uturn.backward.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
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
            
            // トグルボタン列
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
                .padding(.horizontal).padding(.vertical, 10)
            }
            
            Divider()
            
            ScrollView {
                if appState.isGeometryModeEnabled {
                    geometryInputSection
                } else {
                    functionParameterSection
                }
            }
            .frame(height: 300)
        }
        .background(Material.regular)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 10).padding(.bottom, 10)
    }
    
    // ... (以下、functionParameterSection や GeometryInputSection は元のコードのまま変更なしでOKですが、
    // ビルドエラー防止のため、必ずファイルの最後まで記述してください) ...
    
    // MARK: - Function Parameters
    private var functionParameterSection: some View {
        VStack(spacing: 20) {
            
            // --- 放物線設定 ---
            VStack(spacing: 10) {
                HStack {
                    Text("放物線").font(.headline).foregroundColor(.blue)
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(appState.showAdvancedParabola ? "高校" : "中学")
                            .font(.caption).foregroundColor(.secondary)
                        Toggle("p, q", isOn: $appState.showAdvancedParabola)
                            .labelsHidden()
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: { appState.showParabolaGraph.toggle() }) {
                        Image(systemName: appState.showParabolaGraph ? "eye" : "eye.slash")
                            .foregroundColor(appState.showParabolaGraph ? .blue : .gray)
                            .font(.system(size: 20))
                    }
                }
                
                if appState.showParabolaGraph {
                    if appState.coefficientInputMode == .decimal {
                        ParameterInput(label: "a", text: $aText, range: -5.0...5.0, color: .blue) { appState.updateParabolaA($0) }
                    } else {
                        FractionInput(label: "a", numerator: $aNum, denominator: $aDen, color: .blue) { val in appState.updateParabolaA(val) }
                    }
                    
                    if appState.showAdvancedParabola {
                        if appState.coefficientInputMode == .decimal {
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
                        } else {
                            HStack(spacing: 16) {
                                FractionInput(label: "p", numerator: $pNum, denominator: $pDen, color: .blue) { val in appState.updateParabolaP(val) }
                                FractionInput(label: "q", numerator: $qNum, denominator: $qDen, color: .blue) { val in appState.updateParabolaQ(val) }
                            }
                        }
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.05)))
            
            // --- 直線設定 ---
            VStack(spacing: 10) {
                HStack {
                    Text("直線").font(.headline).foregroundColor(.red)
                    Spacer()
                    Button(action: { appState.showLinearGraph.toggle() }) {
                        Image(systemName: appState.showLinearGraph ? "eye" : "eye.slash")
                            .foregroundColor(appState.showLinearGraph ? .red : .gray)
                            .font(.system(size: 20))
                    }
                }
                
                if appState.showLinearGraph {
                    if appState.coefficientInputMode == .decimal {
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
                    } else {
                        HStack(spacing: 16) {
                            FractionInput(label: "m", numerator: $mNum, denominator: $mDen, color: .red) { val in appState.updateLineM(val) }
                            FractionInput(label: "n", numerator: $nNum, denominator: $nDen, color: .red) { val in appState.updateLineN(val) }
                        }
                    }
                }
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.05)))
            
            Color.clear.frame(height: 20)
        }
        .padding()
    }
    
    // MARK: - Geometry Input
    private var geometryInputSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("X").font(.caption).bold().foregroundColor(.secondary)
                    TextField("0.0", text: $inputX).keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 80)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Y").font(.caption).bold().foregroundColor(.secondary)
                    TextField("0.0", text: $inputY).keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 80)
                }
                Button(action: { addPointFromInput() }) {
                    Text("追加").bold().foregroundColor(.white).padding(.horizontal, 16).padding(.vertical, 8).background(Color.orange).cornerRadius(8)
                }
            }
            .padding(.top, 8)
            Divider()
            if appState.markedPoints.isEmpty {
                Text("グラフをタップ、または座標を入力して点を追加").font(.caption).foregroundColor(.secondary).padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(appState.markedPoints.enumerated()), id: \.element.id) { index, point in
                        HStack {
                            Circle().fill(Color.orange).frame(width: 8, height: 8)
                            Text("点\(point.label)").font(.system(size: 14, weight: .bold))
                            Text("(\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y)))").font(.system(size: 14, design: .monospaced)).foregroundColor(.secondary)
                            Spacer()
                            Button(action: { appState.removeMarkedPoint(at: index) }) {
                                Image(systemName: "trash").foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal).padding(.vertical, 4).background(Color.white.opacity(0.5)).cornerRadius(8)
                    }
                }
            }
            if appState.markedPoints.count >= 2 {
                Divider()
                Button(action: {
                    withAnimation { appState.createLineFromPoints() }
                    if appState.isHapticsEnabled { HapticManager.shared.impact(style: .heavy) }
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("この2点を通る直線を作成")
                    }
                    .bold().foregroundColor(.white).frame(maxWidth: .infinity).padding().background(Color.red).cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    private func addPointFromInput() {
        guard let x = Double(inputX), let y = Double(inputY) else { return }
        appState.addMarkedPoint(x: x, y: y)
        inputX = ""; inputY = ""
        if appState.isHapticsEnabled { HapticManager.shared.impact(style: .medium) }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Subcomponents
struct ParameterInput: View {
    let label: String; @Binding var text: String; let range: ClosedRange<Double>; let color: Color; let onCommit: (Double) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(color)
            TextField("0.0", text: $text).keyboardType(.decimalPad).textFieldStyle(.roundedBorder).font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center).onChange(of: text) { _, _ in commitValue() }
        }
    }
    private func commitValue() { if let value = Double(text) { onCommit(min(max(value, range.lowerBound), range.upperBound)) } }
}
struct FractionInput: View {
    let label: String; @Binding var numerator: String; @Binding var denominator: String; let color: Color; let onCommit: (Double) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(color)
            HStack(spacing: 4) {
                TextField("1", text: $numerator).keyboardType(.numberPad).textFieldStyle(.roundedBorder).font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center).onChange(of: numerator) { _, _ in commitFraction() }
                Text("/").font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(color)
                TextField("1", text: $denominator).keyboardType(.numberPad).textFieldStyle(.roundedBorder).font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center).onChange(of: denominator) { _, _ in commitFraction() }
            }
        }
    }
    private func commitFraction() { guard let n = Double(numerator), let d = Double(denominator), d != 0 else { return }; onCommit(n / d) }
}
struct ParameterSlider: View {
    let label: String; @Binding var value: Double; let range: ClosedRange<Double>; let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack { Text(label).font(.caption).bold().foregroundColor(color); Spacer(); Text(String(format: "%.1f", value)).font(.caption).monospacedDigit() }
            Slider(value: $value, in: range).tint(color)
        }
    }
}
