import SwiftUI

struct FloatingToastView: View {
    let message: String
    let symbolName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: symbolName)
                .font(.title2.weight(.semibold))
                .foregroundColor(.focusAccent)

            Text(message)
                .font(.title3.weight(.semibold))
                .foregroundColor(.textPrimary)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.4), radius: 12, x: 0, y: 6)
    }
}
