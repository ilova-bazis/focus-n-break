import SwiftUI
import AppKit

struct MenuPopoverView: View {
    let showCloseButton: Bool

    @EnvironmentObject private var timerService: TimerService

    init(showCloseButton: Bool = true) {
        self.showCloseButton = showCloseButton
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            timerDisplay
            postureTimerRow
            selectionRow
            controls
            settingsButton
            footer
        }
        .padding(16)
        .frame(width: 300)
        .background(Color.background)
        .onAppear {
            timerService.refreshTodayCount()
        }
    }

    private var header: some View {
        HStack {
            Text(timerService.modeTitle)
                .font(.headline)
                .foregroundColor(timerService.modeAccentColor)
            Spacer()
            Image(systemName: headerIconName)
                .foregroundColor(timerService.modeAccentColor)
        }
    }

    private var headerIconName: String {
        timerService.mode == .focus
            ? timerService.selectedPosture.symbolName
            : timerService.selectedBreakActivity.symbolName
    }

    private var timerDisplay: some View {
        Text(timerService.formattedTime)
            .font(.system(size: 44, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .foregroundColor(.textPrimary)
    }

    private var postureTimerRow: some View {
        Group {
            if let postureRemaining = timerService.postureRemainingLabel {
                Text("Posture time left: \(postureRemaining)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var selectionRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            if timerService.mode == .focus {
                focusPostureRow
            } else {
                breakActivityRow
                if !timerService.secondaryBreakActivities.isEmpty {
                    secondaryActivitiesRow
                }
            }
        }
    }

    private var focusPostureRow: some View {
        HStack(spacing: 12) {
            ForEach(Posture.allCases) { posture in
                SelectionIconButton(
                    symbolName: posture.symbolName,
                    isSelected: timerService.selectedPosture == posture,
                    isEnabled: timerService.enabledPostures.contains(posture),
                    accentColor: timerService.modeAccentColor
                ) {
                    timerService.setPosture(posture)
                }
            }
        }
    }

    private var breakActivityRow: some View {
        HStack(spacing: 12) {
            ForEach(BreakActivity.allCases) { activity in
                SelectionIconButton(
                    symbolName: activity.symbolName,
                    isSelected: timerService.selectedBreakActivity == activity,
                    isEnabled: timerService.enabledBreakActivities.contains(activity),
                    accentColor: timerService.modeAccentColor
                ) {
                    timerService.setBreakActivity(activity)
                }
            }
        }
    }

    private var secondaryActivitiesRow: some View {
        Text("Also: \(secondaryActivitiesLabel)")
            .font(.caption)
            .foregroundColor(.textSecondary)
    }

    private var secondaryActivitiesLabel: String {
        timerService.secondaryBreakActivities
            .map { $0.displayName }
            .joined(separator: ", ")
    }

    private var controls: some View {
        HStack(spacing: 12) {
            Button(timerService.isRunning ? "Pause" : "Start") {
                timerService.isRunning ? timerService.pause() : timerService.start()
            }
            .buttonStyle(.borderedProminent)
            .tint(timerService.modeAccentColor)

            Button("Reset") {
                timerService.reset()
            }
            .buttonStyle(.bordered)

            if showCloseButton {
                Button("Close") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var settingsButton: some View {
        Button {
            Task { @MainActor in
                SettingsWindowController.shared.showWindow(timerService: timerService)
            }
        } label: {
            Label("Open Settings", systemImage: "gearshape")
                .font(.caption)
        }
        .buttonStyle(.bordered)
        .tint(.surfaceElevated)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timerService.nextTransitionLabel)
            if timerService.mode == .focus {
                Text("Next activity: \(timerService.nextBreakActivityLabel)")
            } else {
                Text("Next posture: \(timerService.nextFocusPostureLabel)")
            }
            Text("Blocks today: \(timerService.todayCount)")
        }
        .font(.caption)
        .foregroundColor(.textSecondary)
    }

}

struct SelectionIconButton: View {
    let symbolName: String
    let isSelected: Bool
    let isEnabled: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbolName)
                .font(.title3)
                .foregroundColor(iconColor)
                .padding(8)
                .background(background)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }

    private var iconColor: Color {
        if !isEnabled {
            return .textSecondary.opacity(0.3)
        }
        return isSelected ? accentColor : .textSecondary
    }

    private var background: Color {
        isSelected ? accentColor.opacity(0.2) : .surface
    }
}
