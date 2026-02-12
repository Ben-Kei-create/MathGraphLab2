//
//  ControlPanelOverlay.swift
//  MathGraph Lab
//
//  Layer 5: Control panel with coordinate input mode
//  Fixed: Method call error ($appState -> appState)
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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()

                if isPanelVisible {
                    panelContent(availableHeight: geometry.size.height)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    compactButton
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear { syncAllValues() }
        .onChange(of: appState.coefficientInputMode) { _, _ in syncAllValues() }
        .onChange(of: appState.parabola.a) { _, _ in syncAllValues() }
        .onChange(of: appState.parabola.p) { _, _ in syncAllValues() }
        .onChange(of: appState.parabola.q) { _, _ in syncAllValues() }
        .onChange(of: appState.line.m) { _, _ in syncAllValues() }
        .onChange(of: appState.line.n) { _, _ in syncAllValues() }
    }

    /// 小数テキスト・分数テキストの両方を現在の値で同期
    private func syncAllValues() {
        let a = appState.parabola.a
        let p = appState.parabola.p
        let q = appState.parabola.q
        let m = appState.line.m
        let n = appState.line.n

        // 小数テキストを同期
        aText = String(format: "%.2f", a)
        pText = String(format: "%.1f", p)
        qText = String(format: "%.1f", q)
        mText = String(format: "%.2f", m)
        nText = String(format: "%.2f", n)

        // 分数テキストを同期
        let (aFN, aFD) = toFraction(a)
        aNum = "\(aFN)"; aDen = "\(aFD)"
        let (pFN, pFD) = toFraction(p)
        pNum = "\(pFN)"; pDen = "\(pFD)"
        let (qFN, qFD) = toFraction(q)
        qNum = "\(qFN)"; qDen = "\(qFD)"
        let (mFN, mFD) = toFraction(m)
        mNum = "\(mFN)"; mDen = "\(mFD)"
        let (nFN, nFD) = toFraction(n)
        nNum = "\(nFN)"; nDen = "\(nFD)"
    }

    /// Double を分数（分子, 分母）に近似変換
    private func toFraction(_ value: Double) -> (Int, Int) {
        let tolerance = 0.001
        // 整数チェック
        if abs(value - round(value)) < tolerance {
            return (Int(round(value)), 1)
        }
        // 分母 2〜20 で近似
        for d in 2...20 {
            let n = value * Double(d)
            if abs(n - round(n)) < tolerance {
                return (Int(round(n)), d)
            }
        }
        // フォールバック: 小数2桁 → 100分の
        let n100 = Int(round(value * 100))
        return (n100, 100)
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
            
            // 修正後（$を取るだけ！）
            if appState.isGeometryModeEnabled {
                Button(action: {
                    // 直接 appState を呼び出します
                    appState.clearMarkedPoints()
                    appState.clearGeometry()
                }){
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
    
    // MARK: - Theme Toggle Buttons
    private var themeToggleButtons: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                cycleTheme()
            }
            if appState.isHapticsEnabled {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }) {
            Image(systemName: themeIconName)
                .font(.system(size: 18))
                .foregroundColor(themeIconColor)
                .frame(width: 32, height: 32)
                .background(Circle().fill(Color(uiColor: .tertiarySystemBackground)))
        }
    }

    private var themeIconName: String {
        switch appState.appTheme {
        case .light: return "sun.max"
        case .dark: return "moon"
        case .blackboard: return "square.fill"
        }
    }

    private var themeIconColor: Color {
        switch appState.appTheme {
        case .light: return .orange
        case .dark: return .indigo
        case .blackboard: return Color(red: 0.0, green: 0.6, blue: 0.4)
        }
    }

    private func cycleTheme() {
        let allThemes = AppState.AppTheme.allCases
        guard let currentIndex = allThemes.firstIndex(of: appState.appTheme) else { return }
        let nextIndex = (currentIndex + 1) % allThemes.count
        let nextTheme = allThemes[nextIndex]
        // Pro未購入の場合、blackboardをスキップ
        if nextTheme == .blackboard && !appState.isProEnabled {
            appState.appTheme = allThemes[(nextIndex + 1) % allThemes.count]
        } else {
            appState.appTheme = nextTheme
        }
    }

    // MARK: - Panel Content
    private func panelContent(availableHeight: CGFloat) -> some View {
        let scrollHeight = min(300, max(120, availableHeight * 0.45 - 100))
        return VStack(spacing: 0) {
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

                        // テーマ切替ボタン（⚫◯で瞬時に切替）
                        themeToggleButtons

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
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Toggle(isOn: $appState.isAreaModeEnabled) { Label("面積", systemImage: "triangle").font(.system(size: 12)) }.toggleStyle(.button).tint(.green)
                    Toggle(isOn: $appState.isGeometryModeEnabled) { Label("作図", systemImage: "pencil.tip.crop.circle").font(.system(size: 12)) }.toggleStyle(.button).tint(.orange)
                    Toggle(isOn: $appState.showDistances) { Label("距離", systemImage: "ruler").font(.system(size: 12)) }.toggleStyle(.button).tint(.purple)
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
            .frame(height: scrollHeight)
        }
        .background(Material.regular)
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal, 10).padding(.bottom, 10)
    }
    
    // MARK: - Function Parameters
    private var functionParameterSection: some View {
        VStack(spacing: 20) {
            VStack(spacing: 10) {
                HStack {
                    Text("放物線").font(.headline).foregroundColor(.blue)
                    Spacer()
                    HStack(spacing: 8) {
                        Text(appState.showAdvancedParabola ? "高校" : "中学").font(.caption).foregroundColor(.secondary)
                        Toggle("p, q", isOn: $appState.showAdvancedParabola).labelsHidden().toggleStyle(SwitchToggleStyle(tint: .blue))
                    }
                    .padding(.trailing, 8)
                    Button(action: { appState.showParabolaGraph.toggle() }) {
                        Image(systemName: appState.showParabolaGraph ? "eye" : "eye.slash").foregroundColor(appState.showParabolaGraph ? .blue : .gray).font(.system(size: 20))
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
                                ParameterSlider(label: "p", value: Binding(get: { appState.parabola.p }, set: { appState.updateParabolaP($0, snap: appState.isGridSnapEnabled) }), range: -5...5, color: .blue)
                                ParameterSlider(label: "q", value: Binding(get: { appState.parabola.q }, set: { appState.updateParabolaQ($0, snap: appState.isGridSnapEnabled) }), range: -5...5, color: .blue)
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
            .padding(12).background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.05)))
            
            VStack(spacing: 10) {
                HStack {
                    Text("直線").font(.headline).foregroundColor(.red)
                    Spacer()
                    Button(action: { appState.showLinearGraph.toggle() }) {
                        Image(systemName: appState.showLinearGraph ? "eye" : "eye.slash").foregroundColor(appState.showLinearGraph ? .red : .gray).font(.system(size: 20))
                    }
                }
                if appState.showLinearGraph {
                    if appState.coefficientInputMode == .decimal {
                        HStack(spacing: 16) {
                            ParameterSlider(label: "m", value: Binding(get: { appState.line.m }, set: { appState.updateLineM($0) }), range: -5...5, color: .red)
                            ParameterSlider(label: "n", value: Binding(get: { appState.line.n }, set: { appState.updateLineN($0) }), range: -10...10, color: .red)
                        }
                    } else {
                        HStack(spacing: 16) {
                            FractionInput(label: "m", numerator: $mNum, denominator: $mDen, color: .red) { val in appState.updateLineM(val) }
                            FractionInput(label: "n", numerator: $nNum, denominator: $nDen, color: .red) { val in appState.updateLineN(val) }
                        }
                    }
                }
            }
            .padding(12).background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.05)))
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
                    TextField("0.0", text: $inputX)
                        .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 80)
                        .onChange(of: inputX) { _, newValue in
                            if newValue.count > 7 { inputX = String(newValue.prefix(7)) }
                        }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Y").font(.caption).bold().foregroundColor(.secondary)
                    TextField("0.0", text: $inputY)
                        .keyboardType(.decimalPad).textFieldStyle(.roundedBorder).frame(width: 80)
                        .onChange(of: inputY) { _, newValue in
                            if newValue.count > 7 { inputY = String(newValue.prefix(7)) }
                        }
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
                if let error = appState.lineCreationError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                        Text(error).font(.system(size: 12)).foregroundColor(.red)
                    }
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(Color.red.opacity(0.1)).cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    private func addPointFromInput() {
        let xTrimmed = inputX.trimmingCharacters(in: .whitespaces)
        let yTrimmed = inputY.trimmingCharacters(in: .whitespaces)
        guard !xTrimmed.isEmpty, !yTrimmed.isEmpty,
              let x = Double(xTrimmed), let y = Double(yTrimmed),
              x.isFinite, y.isFinite else { return }
        let clampedX = min(max(x, -100), 100)
        let clampedY = min(max(y, -100), 100)
        appState.addMarkedPoint(x: clampedX, y: clampedY)
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
            TextField("0.0", text: $text)
                .keyboardType(.decimalPad).textFieldStyle(.roundedBorder)
                .font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center)
                .onChange(of: text) { _, newValue in
                    if newValue.count > 8 { text = String(newValue.prefix(8)) }
                    commitValue()
                }
        }
    }
    private func commitValue() {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || trimmed == "." || trimmed == "-" || trimmed == "-." { return }
        guard let value = Double(trimmed), value.isFinite else { return }
        onCommit(min(max(value, range.lowerBound), range.upperBound))
    }
}
struct FractionInput: View {
    let label: String; @Binding var numerator: String; @Binding var denominator: String; let color: Color; let onCommit: (Double) -> Void
    @State private var showZeroWarning: Bool = false
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.system(size: 12, weight: .semibold, design: .monospaced)).foregroundColor(color)
            HStack(spacing: 4) {
                TextField("1", text: $numerator)
                    .keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center)
                    .onChange(of: numerator) { _, newValue in
                        if newValue.count > 6 { numerator = String(newValue.prefix(6)) }
                        commitFraction()
                    }
                Text("/").font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundColor(color)
                TextField("1", text: $denominator)
                    .keyboardType(.numberPad).textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced)).multilineTextAlignment(.center)
                    .overlay(showZeroWarning ? RoundedRectangle(cornerRadius: 6).stroke(Color.red, lineWidth: 2) : nil)
                    .onChange(of: denominator) { _, newValue in
                        if newValue.count > 6 { denominator = String(newValue.prefix(6)) }
                        commitFraction()
                    }
            }
            if showZeroWarning {
                Text("分母に0は使えません").font(.system(size: 10)).foregroundColor(.red)
            }
        }
    }
    private func commitFraction() {
        guard let n = Double(numerator), let d = Double(denominator) else { showZeroWarning = false; return }
        if d == 0 { showZeroWarning = true; return }
        showZeroWarning = false
        let result = n / d
        guard result.isFinite else { return }
        onCommit(result)
    }
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
