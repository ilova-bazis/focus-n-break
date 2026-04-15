import Foundation
import SwiftUI

@MainActor
final class TimerService: ObservableObject {
    @Published var mode: SessionMode
    @Published var remainingTime: TimeInterval
    @Published var isRunning: Bool
    @Published var selectedPosture: Posture
    @Published var selectedBreakActivity: BreakActivity
    @Published var enabledPostures: [Posture]
    @Published var enabledBreakActivities: [BreakActivity]
    @Published var focusDuration: TimeInterval
    @Published var breakDuration: TimeInterval
    @Published var maxStandDuration: TimeInterval
    @Published var maxPerchDuration: TimeInterval
    @Published var maxSitDuration: TimeInterval
    @Published var autoStartNext: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var playSoundOnTransition: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var autoOpenOnTransition: Bool {
        didSet {
            saveSettings()
        }
    }
    @Published var todayCount: Int = 0
    @Published var menuBarCue: String?

    private let sessionStore: SessionStore
    private var timer: Timer?
    private var postureStartTime: Date?
    private var sessionStartTime: Date?
    private var lastUpdated: Date?

    init(sessionStore: SessionStore) {
        self.sessionStore = sessionStore
        let settings = TimerSettings.load()
        self.mode = settings.mode
        self.remainingTime = settings.remainingTime
        self.isRunning = settings.isRunning
        self.selectedPosture = settings.selectedPosture
        self.selectedBreakActivity = settings.selectedBreakActivity
        self.enabledPostures = settings.enabledPostures
        self.enabledBreakActivities = settings.enabledBreakActivities
        self.focusDuration = settings.focusDuration
        self.breakDuration = settings.breakDuration
        self.maxStandDuration = settings.maxStandDuration
        self.maxPerchDuration = settings.maxPerchDuration
        self.maxSitDuration = settings.maxSitDuration
        self.autoStartNext = settings.autoStartNext
        self.playSoundOnTransition = settings.playSoundOnTransition
        self.autoOpenOnTransition = settings.autoOpenOnTransition
        self.postureStartTime = settings.postureStartTime
        self.sessionStartTime = settings.sessionStartTime
        self.lastUpdated = settings.lastUpdated

        normalizeSelections()
        if mode == .focus, postureStartTime == nil {
            postureStartTime = Date()
        }
        if mode == .breakTime {
            postureStartTime = nil
        }
        adjustRemainingForElapsedTime()
        refreshTodayCount()

        if isRunning {
            startTimer()
        } else if remainingTime <= 0 {
            remainingTime = durationForCurrentMode()
        }
    }

    var menuBarTitle: String {
        let base = "⏱ \(formattedTime)"
        if let cue = menuBarCue {
            return "\(base) • \(cue)"
        }
        return base
    }

    var formattedTime: String {
        Self.formatDuration(remainingTime)
    }

    var postureRemainingLabel: String? {
        guard mode == .focus else { return nil }
        let maxDuration = maxDurationForSelectedPosture()
        guard maxDuration > 0 else { return nil }
        let elapsed = postureStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let remaining = max(0, maxDuration - elapsed)
        let cappedRemaining = min(remaining, remainingTime)
        return Self.formatDuration(cappedRemaining)
    }

    var modeTitle: String {
        mode.displayName
    }

    var modeAccentColor: Color {
        mode == .focus ? .focusAccent : .breakAccent
    }

    var nextFocusPosture: Posture? {
        nextEnabledPosture(after: selectedPosture)
    }

    var nextFocusPostureLabel: String {
        nextFocusPosture?.displayName ?? selectedPosture.displayName
    }

    var nextBreakActivity: BreakActivity? {
        nextEnabledActivity(after: selectedBreakActivity)
    }

    var nextBreakActivityLabel: String {
        nextBreakActivity?.displayName ?? selectedBreakActivity.displayName
    }

    var secondaryBreakActivities: [BreakActivity] {
        enabledBreakActivities.filter { $0 != selectedBreakActivity }
    }

    var nextTransitionLabel: String {
        guard isRunning else {
            return "Ready to start"
        }
        let nextMode = mode == .focus ? "break" : "focus"
        let timeString = Self.timeFormatter.string(from: Date().addingTimeInterval(remainingTime))
        return "Next \(nextMode) at \(timeString)"
    }

    var focusDurationMinutes: Int {
        get { Int(focusDuration / 60) }
        set {
            focusDuration = TimeInterval(newValue * 60)
            if mode == .focus, !isRunning {
                remainingTime = focusDuration
            }
            saveSettings()
        }
    }

    var breakDurationMinutes: Int {
        get { Int(breakDuration / 60) }
        set {
            breakDuration = TimeInterval(newValue * 60)
            if mode == .breakTime, !isRunning {
                remainingTime = breakDuration
            }
            saveSettings()
        }
    }

    var maxStandMinutes: Int {
        get { Int(maxStandDuration / 60) }
        set {
            maxStandDuration = TimeInterval(newValue * 60)
            saveSettings()
        }
    }

    var maxPerchMinutes: Int {
        get { Int(maxPerchDuration / 60) }
        set {
            maxPerchDuration = TimeInterval(newValue * 60)
            saveSettings()
        }
    }

    var maxSitMinutes: Int {
        get { Int(maxSitDuration / 60) }
        set {
            maxSitDuration = TimeInterval(newValue * 60)
            saveSettings()
        }
    }

    func start() {
        guard !isRunning else { return }
        if remainingTime <= 0 {
            remainingTime = durationForCurrentMode()
        }
        isRunning = true
        if sessionStartTime == nil {
            sessionStartTime = Date()
        }
        if mode == .focus, postureStartTime == nil {
            postureStartTime = Date()
        }
        lastUpdated = Date()
        startTimer()
        saveSettings()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        stopTimer()
        saveSettings()
    }

    func reset() {
        isRunning = false
        stopTimer()
        remainingTime = durationForCurrentMode()
        sessionStartTime = nil
        saveSettings()
    }

    func setPosture(_ posture: Posture) {
        guard enabledPostures.contains(posture) else { return }
        selectedPosture = posture
        if mode == .focus {
            postureStartTime = Date()
        }
        saveSettings()
    }

    func setPostureEnabled(_ posture: Posture, enabled: Bool) {
        var updated = enabledPostures
        if enabled {
            if !updated.contains(posture) {
                updated.append(posture)
            }
        } else if updated.count > 1 {
            updated.removeAll { $0 == posture }
        }
        enabledPostures = Posture.allCases.filter { updated.contains($0) }
        if !enabledPostures.contains(selectedPosture) {
            selectedPosture = enabledPostures.first ?? selectedPosture
            if mode == .focus {
                postureStartTime = Date()
            }
        }
        saveSettings()
    }

    func setBreakActivity(_ activity: BreakActivity) {
        guard enabledBreakActivities.contains(activity) else { return }
        selectedBreakActivity = activity
        saveSettings()
    }

    func setBreakActivityEnabled(_ activity: BreakActivity, enabled: Bool) {
        var updated = enabledBreakActivities
        if enabled {
            if !updated.contains(activity) {
                updated.append(activity)
            }
        } else if updated.count > 1 {
            updated.removeAll { $0 == activity }
        }
        enabledBreakActivities = BreakActivity.allCases.filter { updated.contains($0) }
        if !enabledBreakActivities.contains(selectedBreakActivity) {
            selectedBreakActivity = enabledBreakActivities.first ?? selectedBreakActivity
        }
        saveSettings()
    }

    func refreshTodayCount() {
        todayCount = sessionStore.fetchTodayCount()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard isRunning else { return }
        remainingTime -= 1
        lastUpdated = Date()

        if mode == .focus {
            handlePostureLimitIfNeeded()
        }

        if remainingTime <= 0 {
            completeCurrentSession()
            transitionToNextMode()
        }
        saveSettings()
    }

    private func completeCurrentSession() {
        let endTime = Date()
        let startTime = sessionStartTime ?? endTime.addingTimeInterval(-durationForCurrentMode())
        let duration = max(endTime.timeIntervalSince(startTime), 0)
        sessionStore.saveEvent(
            startTime: startTime,
            endTime: endTime,
            mode: mode,
            focusPosture: mode == .focus ? selectedPosture : nil,
            breakActivity: mode == .breakTime ? selectedBreakActivity : nil,
            duration: duration
        )
        sessionStartTime = endTime
        refreshTodayCount()
    }

    private func transitionToNextMode() {
        mode = mode == .focus ? .breakTime : .focus
        remainingTime = durationForCurrentMode()
        if mode == .focus {
            advancePosture()
            postureStartTime = Date()
        } else {
            advanceBreakActivity()
            postureStartTime = nil
        }
        if autoStartNext {
            sessionStartTime = Date()
            if mode == .focus {
                postureStartTime = Date()
            }
        } else {
            sessionStartTime = nil
            pause()
        }

        if playSoundOnTransition {
            SoundPlayer.playTransition()
        }

        if autoOpenOnTransition {
            Task { @MainActor in
                AppWindowController.shared.showTransitionWindow(
                    mode: mode,
                    focusPosture: mode == .focus ? selectedPosture : nil,
                    breakActivity: mode == .breakTime ? selectedBreakActivity : nil
                )
            }
        }

        NotificationManager.shared.sendTransitionNotification(for: mode)
    }

    private func advancePosture() {
        if let next = nextEnabledPosture(after: selectedPosture) {
            selectedPosture = next
        }
    }

    private func advanceBreakActivity() {
        if let next = nextEnabledActivity(after: selectedBreakActivity) {
            selectedBreakActivity = next
        }
    }

    private func handlePostureLimitIfNeeded() {
        guard enabledPostures.count > 1 else { return }
        let maxDuration = maxDurationForSelectedPosture()
        guard maxDuration > 0 else { return }
        if postureStartTime == nil {
            postureStartTime = Date()
            return
        }
        guard let postureStartTime else { return }
        let elapsed = Date().timeIntervalSince(postureStartTime)
        if elapsed >= maxDuration {
            advancePosture()
            self.postureStartTime = Date()
            if playSoundOnTransition {
                SoundPlayer.playTransition()
            }
            showPostureSwitchToast(for: selectedPosture)
        }
    }

    private func showPostureSwitchToast(for posture: Posture) {
        menuBarCue = posture.displayName
        Task { @MainActor in
            FloatingToastWindowController.shared.showToast(
                message: "Switch posture: \(posture.displayName)",
                symbolName: posture.symbolName
            )
        }
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            clearPostureCue()
        }
    }

    func clearPostureCue() {
        menuBarCue = nil
    }

    private func maxDurationForSelectedPosture() -> TimeInterval {
        switch selectedPosture {
        case .sit:
            return maxSitDuration
        case .stand:
            return maxStandDuration
        case .perch:
            return maxPerchDuration
        }
    }

    private func nextEnabledPosture(after posture: Posture) -> Posture? {
        guard !enabledPostures.isEmpty else { return nil }
        let ordered = Posture.allCases.filter { enabledPostures.contains($0) }
        guard let currentIndex = ordered.firstIndex(of: posture) else {
            return ordered.first
        }
        let nextIndex = ordered.index(after: currentIndex)
        return nextIndex < ordered.endIndex ? ordered[nextIndex] : ordered.first
    }

    private func nextEnabledActivity(after activity: BreakActivity) -> BreakActivity? {
        guard !enabledBreakActivities.isEmpty else { return nil }
        let ordered = BreakActivity.allCases.filter { enabledBreakActivities.contains($0) }
        guard let currentIndex = ordered.firstIndex(of: activity) else {
            return ordered.first
        }
        let nextIndex = ordered.index(after: currentIndex)
        return nextIndex < ordered.endIndex ? ordered[nextIndex] : ordered.first
    }

    private func durationForCurrentMode() -> TimeInterval {
        mode == .focus ? focusDuration : breakDuration
    }

    private func normalizeSelections() {
        if enabledPostures.isEmpty {
            enabledPostures = Posture.allCases
        }
        if !enabledPostures.contains(selectedPosture) {
            selectedPosture = enabledPostures.first ?? .sit
        }
        enabledPostures = Posture.allCases.filter { enabledPostures.contains($0) }

        if enabledBreakActivities.isEmpty {
            enabledBreakActivities = BreakActivity.allCases
        }
        if !enabledBreakActivities.contains(selectedBreakActivity) {
            selectedBreakActivity = enabledBreakActivities.first ?? .walking
        }
        enabledBreakActivities = BreakActivity.allCases.filter { enabledBreakActivities.contains($0) }

        if postureStartTime == nil {
            postureStartTime = Date()
        }
    }

    private func adjustRemainingForElapsedTime() {
        guard isRunning, let lastUpdated else { return }
        let elapsed = Date().timeIntervalSince(lastUpdated)
        remainingTime -= elapsed
        if remainingTime <= 0 {
            remainingTime = 0
            isRunning = false
        }
    }

    private func saveSettings() {
        let settings = TimerSettings(
            mode: mode,
            remainingTime: remainingTime,
            isRunning: isRunning,
            selectedPosture: selectedPosture,
            selectedBreakActivity: selectedBreakActivity,
            enabledPostures: enabledPostures,
            enabledBreakActivities: enabledBreakActivities,
            focusDuration: focusDuration,
            breakDuration: breakDuration,
            maxStandDuration: maxStandDuration,
            maxPerchDuration: maxPerchDuration,
            maxSitDuration: maxSitDuration,
            autoStartNext: autoStartNext,
            playSoundOnTransition: playSoundOnTransition,
            autoOpenOnTransition: autoOpenOnTransition,
            postureStartTime: postureStartTime,
            sessionStartTime: sessionStartTime,
            lastUpdated: lastUpdated
        )
        settings.save()
    }

    private static func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(Int(duration.rounded()), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}
