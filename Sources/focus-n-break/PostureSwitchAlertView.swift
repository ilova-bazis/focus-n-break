import SwiftUI
import AppKit

struct PostureSwitchAlertView: View {
    let posture: Posture

    var body: some View {
        VStack(spacing: 16) {
            Text("Time to switch posture")
                .font(.title2.weight(.semibold))
                .foregroundColor(.textPrimary)

            Text("Suggested: \(posture.displayName)")
                .font(.callout.weight(.semibold))
                .foregroundColor(.focusAccent)

            Button("OK") {
                NSApp.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
            .tint(.focusAccent)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}
