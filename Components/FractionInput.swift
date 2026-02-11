//
//  FractionInput.swift
//  MathGraph Lab
//
//  Custom fraction input (numerator/denominator)
//  Part of Components layer
//

import SwiftUI

// MARK: - Fraction Input Component
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
                    .onChange(of: numerator) { oldValue, newValue in
                        commitFraction()
                    }
                
                Text("/")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                
                TextField("1", text: $denominator)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .onChange(of: denominator) { oldValue, newValue in
                        commitFraction()
                    }
            }
        }
    }
    
    private func commitFraction() {
        guard let num = Double(numerator),
              let den = Double(denominator),
              den != 0 else { return }
        
        let value = num / den
        onCommit(value)
    }
}
