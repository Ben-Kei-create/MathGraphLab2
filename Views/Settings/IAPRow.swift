import SwiftUI

struct IAPRow: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let price: String
    @Binding var isPurchased: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    // Simulate Purchase
                    isPurchased = true
                }
            }) {
                Text(isPurchased ? "OWNED" : price)
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isPurchased ? Color.gray.opacity(0.2) : color.opacity(0.1))
                    .foregroundColor(isPurchased ? .gray : color)
                    .cornerRadius(20)
            }
            .disabled(isPurchased)
        }
        .padding(.vertical, 4)
    }
}
