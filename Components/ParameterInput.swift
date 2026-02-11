//
//  ParameterInput.swift
//  MathGraph Lab
//
//  Reusable text field component for parameter entry
//  Part of Components layer
//

import SwiftUI

// MARK: - Parameter Input Component
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
                .onSubmit {
                    commitValue()
                }
                .onChange(of: text) { _, newValue in
                    if Double(newValue) != nil {
                        commitValue()
                    }
                }
        }
    }
    
    private func commitValue() {
        if let value = Double(text) {
            let clamped = min(max(value, range.lowerBound), range.upperBound)
            onCommit(clamped)
            text = String(format: "%.2f", clamped)
        }
    }
}
