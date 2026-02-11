import SwiftUI

struct MonospacedLabel: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(.body, design: .monospaced))
    }
}
