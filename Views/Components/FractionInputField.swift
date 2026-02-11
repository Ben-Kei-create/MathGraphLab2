import SwiftUI

struct FractionInputField: View {
    @Binding var value: Double
    
    var body: some View {
        HStack {
            TextField("Value", value: $value, format: .number)
                .keyboardType(.decimalPad)
        }
    }
}
