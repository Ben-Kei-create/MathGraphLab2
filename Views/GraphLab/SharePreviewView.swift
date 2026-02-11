//
//  SharePreviewView.swift
//  MathGraph Lab
//
//  Export functionality: PNG/PDF rendering and share sheet
//

import SwiftUI
import PDFKit

// MARK: - Export Format
enum ExportFormat: String, CaseIterable, Identifiable {
    case png = "PNG画像"
    case pdf = "PDF文書"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .png: return "photo"
        case .pdf: return "doc.richtext"
        }
    }
}

// MARK: - Exportable Graph View
/// グラフ領域のみをレンダリングするビュー（ツールバー・広告・操作パネルなし）
struct ExportableGraphView: View {
    @ObservedObject var appState: AppState
    let size: CGSize

    var body: some View {
        ZStack {
            GridBackgroundView()
            GraphCanvasView()
            AnalysisOverlayView()
            MarkedPointsOverlayView()
            DistanceLinesOverlayView()
            EquationOverlayView()

            // ウォーターマーク（無料版のみ表示）
            if !appState.isProEnabled {
                watermark
            }
        }
        .frame(width: size.width, height: size.height)
        .environmentObject(appState)
    }

    private var watermark: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Created with MathGraph Lab")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(watermarkColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(watermarkBackground)
                    )
                    .padding(.trailing, 12)
                    .padding(.bottom, 12)
            }
        }
    }

    private var watermarkColor: Color {
        switch appState.appTheme {
        case .light: return Color.black.opacity(0.35)
        case .dark, .blackboard: return Color.white.opacity(0.4)
        }
    }

    private var watermarkBackground: Color {
        switch appState.appTheme {
        case .light: return Color.white.opacity(0.6)
        case .dark: return Color.black.opacity(0.4)
        case .blackboard: return Color.black.opacity(0.3)
        }
    }
}

// MARK: - Graph Exporter
/// PNG / PDF レンダリングエンジン
@MainActor
struct GraphExporter {

    /// グラフを UIImage として描画
    static func renderImage(appState: AppState, size: CGSize, scale: CGFloat = 2.0) -> UIImage? {
        let view = ExportableGraphView(appState: appState, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        renderer.proposedSize = .init(width: size.width, height: size.height)
        return renderer.uiImage
    }

    /// グラフを PDF (Data) として描画
    static func renderPDF(appState: AppState, size: CGSize) -> Data? {
        let view = ExportableGraphView(appState: appState, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: size.width, height: size.height)

        let pdfData = NSMutableData()
        renderer.render { estimatedSize, renderInContext in
            var mediaBox = CGRect(origin: .zero, size: estimatedSize)

            guard let consumer = CGDataConsumer(data: pdfData as CFMutableData),
                  let pdfContext = CGContext(consumer: consumer, mediaBox: &mediaBox, nil)
            else { return }

            pdfContext.beginPDFPage(nil)
            renderInContext(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }

        return pdfData.length > 0 ? pdfData as Data : nil
    }

    /// PDF を一時ファイルに書き出して URL を返す
    static func renderPDFToFile(appState: AppState, size: CGSize) -> URL? {
        let view = ExportableGraphView(appState: appState, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: size.width, height: size.height)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("MathGraphLab_\(dateStamp()).pdf")

        var success = false
        renderer.render { estimatedSize, renderInContext in
            var mediaBox = CGRect(origin: .zero, size: estimatedSize)

            guard let pdfContext = CGContext(url as CFURL, mediaBox: &mediaBox, nil)
            else { return }

            pdfContext.beginPDFPage(nil)
            renderInContext(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            success = true
        }

        return success ? url : nil
    }

    // MARK: - ファイル名生成

    /// 関数式からファイル名を安全に生成
    /// 例: "MathGraphLab_y=2x²_y=x+1_20260211"
    static func exportFileName(appState: AppState, ext: String) -> String {
        var parts: [String] = []

        if appState.showParabolaGraph {
            parts.append(equationSlug(for: appState.parabola))
        }
        if appState.showLinearGraph {
            parts.append(lineSlug(for: appState.line))
        }

        let equations = parts.isEmpty ? "" : "_\(parts.joined(separator: "_"))"
        let sanitized = equations
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "/", with: "⁄")  // fraction slash (safe for filename)

        return "MathGraphLab\(sanitized)_\(dateStamp()).\(ext)"
    }

    /// PNG を一時ファイルとして保存し URL を返す（ファイル名に式を含む）
    static func renderImageToFile(appState: AppState, size: CGSize, scale: CGFloat = 2.0) -> URL? {
        guard let image = renderImage(appState: appState, size: size, scale: scale),
              let data = image.pngData()
        else { return nil }

        let fileName = exportFileName(appState: appState, ext: "png")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    /// PDF ファイル名にも式を反映
    static func renderPDFToFileNamed(appState: AppState, size: CGSize) -> URL? {
        let view = ExportableGraphView(appState: appState, size: size)
        let renderer = ImageRenderer(content: view)
        renderer.proposedSize = .init(width: size.width, height: size.height)

        let fileName = exportFileName(appState: appState, ext: "pdf")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        var success = false
        renderer.render { estimatedSize, renderInContext in
            var mediaBox = CGRect(origin: .zero, size: estimatedSize)

            guard let pdfContext = CGContext(url as CFURL, mediaBox: &mediaBox, nil)
            else { return }

            pdfContext.beginPDFPage(nil)
            renderInContext(pdfContext)
            pdfContext.endPDFPage()
            pdfContext.closePDF()
            success = true
        }

        return success ? url : nil
    }

    // MARK: - Private Helpers

    private static func equationSlug(for p: Parabola) -> String {
        let a = p.a
        let aStr = a == 1 ? "" : (a == -1 ? "-" : formatCoeff(a))
        return "y=\(aStr)x²"
    }

    private static func lineSlug(for l: Line) -> String {
        let m = l.m, n = l.n
        let mStr = m == 1 ? "" : (m == -1 ? "-" : formatCoeff(m))
        let nStr: String
        if n == 0 {
            nStr = ""
        } else if n > 0 {
            nStr = "+\(formatCoeff(n))"
        } else {
            nStr = formatCoeff(n)
        }
        if m == 0 { return "y=\(formatCoeff(n))" }
        return "y=\(mStr)x\(nStr)"
    }

    private static func formatCoeff(_ v: Double) -> String {
        if abs(v - round(v)) < 0.001 { return String(format: "%.0f", v) }
        return String(format: "%.1f", v)
    }

    private static func dateStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd_HHmmss"
        return f.string(from: Date())
    }
}

// MARK: - Export Sheet View
/// エクスポート設定とプレビューを表示するシート
struct ExportSheetView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFormat: ExportFormat = .png
    @State private var isExporting = false
    @State private var exportedImage: UIImage?
    @State private var showShareSheet = false

    // エクスポートサイズ（Retina 相当）
    private let exportSize = CGSize(width: 800, height: 600)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // プレビュー
                previewSection

                // 形式選択
                formatPicker

                // エクスポートボタン
                exportButton
            }
            .padding()
            .navigationTitle("グラフをエクスポート")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }

    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("プレビュー")
                .font(.caption)
                .foregroundColor(.secondary)

            // ライブプレビュー（縮小表示）
            ExportableGraphView(appState: appState, size: exportSize)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Format Picker
    private var formatPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("出力形式")
                .font(.caption)
                .foregroundColor(.secondary)

            Picker("形式", selection: $selectedFormat) {
                ForEach(ExportFormat.allCases) { format in
                    Label(format.rawValue, systemImage: format.icon)
                        .tag(format)
                }
            }
            .pickerStyle(.segmented)

            Text(selectedFormat == .png
                 ? "高解像度の画像ファイル。SNSやメッセージでの共有に最適です。"
                 : "ベクター品質の文書ファイル。印刷やプリント教材に最適です。")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Export Button
    private var exportButton: some View {
        Button(action: performExport) {
            HStack {
                if isExporting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(isExporting ? "エクスポート中..." : "エクスポート")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isExporting ? Color.gray : Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(12)
            .font(.headline)
        }
        .disabled(isExporting)
    }

    // MARK: - Export Logic
    private func performExport() {
        isExporting = true
        if appState.isHapticsEnabled {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }

        // 少し遅延を入れてプレビューの描画を確定させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            switch selectedFormat {
            case .png:
                exportAsPNG()
            case .pdf:
                exportAsPDF()
            }
        }
    }

    private func exportAsPNG() {
        guard let url = GraphExporter.renderImageToFile(appState: appState, size: exportSize) else {
            isExporting = false
            return
        }
        presentShareSheet(items: [url])
    }

    private func exportAsPDF() {
        guard let pdfURL = GraphExporter.renderPDFToFileNamed(appState: appState, size: exportSize) else {
            isExporting = false
            return
        }
        presentShareSheet(items: [pdfURL])
    }

    private func presentShareSheet(items: [Any]) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController
        else {
            isExporting = false
            return
        }

        // 最前面の ViewController を取得
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // iPad 対応
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        activityVC.completionWithItemsHandler = { _, _, _, _ in
            isExporting = false
            if appState.isHapticsEnabled {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }

        topVC.present(activityVC, animated: true) {
            isExporting = false
        }
    }
}

// MARK: - Legacy alias
/// 後方互換性のためにSharePreviewViewを維持
typealias SharePreviewView = ExportSheetView
