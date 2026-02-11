import SwiftUI

struct ParameterSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(value, specifier: "%.1f")")
            Slider(value: $value, in: range)
        }
    }
}
