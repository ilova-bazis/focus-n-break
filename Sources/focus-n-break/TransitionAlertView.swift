import SwiftUI
import AppKit

struct TransitionAlertView: View {
    let mode: SessionMode
    let focusPosture: Posture?
    let breakActivity: BreakActivity?

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundColor(.textPrimary)

            Text(subtitle)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)

            if let detailText {
                Text(detailText)
                    .font(.callout.weight(.semibold))
                    .foregroundColor(accentColor)
            }

            Button("OK") {
                NSApp.keyWindow?.close()
            }
            .buttonStyle(.borderedProminent)
            .tint(accentColor)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }

    private var title: String {
        mode == .focus ? "Back to focus" : "Time to rest"
    }

    private var subtitle: String {
        mode == .focus ? "Start your next focus block." : "Take a short recovery break."
    }

    private var detailText: String? {
        switch mode {
        case .focus:
            if let focusPosture {
                return "Posture: \(focusPosture.displayName)"
            }
            return nil
        case .breakTime:
            if let breakActivity {
                return "Activity: \(breakActivity.displayName)"
            }
            return nil
        }
    }

    private var accentColor: Color {
        mode == .focus ? .focusAccent : .breakAccent
    }
}
