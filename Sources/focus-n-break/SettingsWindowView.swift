import SwiftUI
import UserNotifications

struct SettingsWindowView: View {
    @EnvironmentObject private var timerService: TimerService
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(title: "Timer")
                durationRow(title: "Focus duration", minutes: $timerService.focusDurationMinutes)
                durationRow(title: "Break duration", minutes: $timerService.breakDurationMinutes)

                SectionHeader(title: "Posture Limits")
                durationRow(title: "Stand max", minutes: $timerService.maxStandMinutes)
                durationRow(title: "Perch max", minutes: $timerService.maxPerchMinutes)
                durationRow(title: "Sit max", minutes: $timerService.maxSitMinutes)

                SectionHeader(title: "Automation")
                Toggle("Auto-start next block", isOn: $timerService.autoStartNext)
                Toggle("Play sound on transitions", isOn: $timerService.playSoundOnTransition)
                Toggle("Auto-open on transition", isOn: $timerService.autoOpenOnTransition)

                SectionHeader(title: "Notifications")
                notificationStatusRow
                Button("Request Notifications") {
                    NotificationManager.shared.requestAuthorization {
                        DispatchQueue.main.async {
                            refreshNotificationStatus()
                        }
                    }
                }
                .buttonStyle(.bordered)

                SectionHeader(title: "Focus Postures")
                ForEach(Posture.allCases) { posture in
                    Toggle(posture.displayName, isOn: postureToggleBinding(for: posture))
                }

                SectionHeader(title: "Break Activities")
                ForEach(BreakActivity.allCases) { activity in
                    Toggle(activity.displayName, isOn: activityToggleBinding(for: activity))
                }
            }
            .padding(24)
        }
        .frame(minWidth: 380, minHeight: 560)
        .background(Color.background)
        .onAppear {
            refreshNotificationStatus()
        }
    }

    private var notificationStatusRow: some View {
        HStack {
            Text("Status")
                .foregroundColor(.textSecondary)
            Spacer()
            Text(notificationStatusLabel)
                .foregroundColor(.textPrimary)
        }
        .font(.caption)
    }

    private var notificationStatusLabel: String {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Enabled"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not set"
        @unknown default:
            return "Unknown"
        }
    }

    private func refreshNotificationStatus() {
        NotificationManager.shared.fetchAuthorizationStatus { status in
            DispatchQueue.main.async {
                notificationStatus = status
            }
        }
    }

    private func durationRow(title: String, minutes: Binding<Int>) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.textSecondary)
            Spacer()
            Stepper(value: minutes, in: 1...180, step: 1) {
                Text("\(minutes.wrappedValue)m")
                    .foregroundColor(.textPrimary)
            }
        }
    }

    private func postureToggleBinding(for posture: Posture) -> Binding<Bool> {
        Binding(
            get: { timerService.enabledPostures.contains(posture) },
            set: { timerService.setPostureEnabled(posture, enabled: $0) }
        )
    }

    private func activityToggleBinding(for activity: BreakActivity) -> Binding<Bool> {
        Binding(
            get: { timerService.enabledBreakActivities.contains(activity) },
            set: { timerService.setBreakActivityEnabled(activity, enabled: $0) }
        )
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.textPrimary)
    }
}
