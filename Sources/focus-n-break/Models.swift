import Foundation

enum SessionMode: String, Codable, CaseIterable {
    case focus
    case breakTime

    var displayName: String {
        switch self {
        case .focus:
            return "Focus"
        case .breakTime:
            return "Break"
        }
    }
}

enum Posture: String, Codable, CaseIterable, Identifiable {
    case sit
    case stand
    case perch

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sit:
            return "Sit"
        case .stand:
            return "Stand"
        case .perch:
            return "Perch"
        }
    }

    var symbolName: String {
        switch self {
        case .sit:
            return "chair.lounge.fill"
        case .stand:
            return "figure.stand"
        case .perch:
            return "chair"
        }
    }
}

enum BreakActivity: String, Codable, CaseIterable, Identifiable {
    case walking
    case stretching
    case mobility
    case passiveRecovery
    case eyesReset

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .walking:
            return "Walking"
        case .stretching:
            return "Stretching"
        case .mobility:
            return "Mobility"
        case .passiveRecovery:
            return "Passive"
        case .eyesReset:
            return "Eyes"
        }
    }

    var symbolName: String {
        switch self {
        case .walking:
            return "figure.walk"
        case .stretching:
            return "figure.cooldown"
        case .mobility:
            return "figure.core.training"
        case .passiveRecovery:
            return "figure.seated.side"
        case .eyesReset:
            return "eye"
        }
    }
}

struct TimerSettings: Codable {
    var mode: SessionMode
    var remainingTime: TimeInterval
    var isRunning: Bool
    var selectedPosture: Posture
    var selectedBreakActivity: BreakActivity
    var enabledPostures: [Posture]
    var enabledBreakActivities: [BreakActivity]
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    var maxStandDuration: TimeInterval
    var maxPerchDuration: TimeInterval
    var maxSitDuration: TimeInterval
    var autoStartNext: Bool
    var playSoundOnTransition: Bool
    var autoOpenOnTransition: Bool
    var postureStartTime: Date?
    var sessionStartTime: Date?
    var lastUpdated: Date?

    static let defaults = TimerSettings(
        mode: .focus,
        remainingTime: 50 * 60,
        isRunning: false,
        selectedPosture: .sit,
        selectedBreakActivity: .walking,
        enabledPostures: Posture.allCases,
        enabledBreakActivities: BreakActivity.allCases,
        focusDuration: 50 * 60,
        breakDuration: 5 * 60,
        maxStandDuration: 25 * 60,
        maxPerchDuration: 30 * 60,
        maxSitDuration: 50 * 60,
        autoStartNext: true,
        playSoundOnTransition: true,
        autoOpenOnTransition: true,
        postureStartTime: nil,
        sessionStartTime: nil,
        lastUpdated: nil
    )

    init(
        mode: SessionMode,
        remainingTime: TimeInterval,
        isRunning: Bool,
        selectedPosture: Posture,
        selectedBreakActivity: BreakActivity,
        enabledPostures: [Posture],
        enabledBreakActivities: [BreakActivity],
        focusDuration: TimeInterval,
        breakDuration: TimeInterval,
        maxStandDuration: TimeInterval,
        maxPerchDuration: TimeInterval,
        maxSitDuration: TimeInterval,
        autoStartNext: Bool,
        playSoundOnTransition: Bool,
        autoOpenOnTransition: Bool,
        postureStartTime: Date?,
        sessionStartTime: Date?,
        lastUpdated: Date?
    ) {
        self.mode = mode
        self.remainingTime = remainingTime
        self.isRunning = isRunning
        self.selectedPosture = selectedPosture
        self.selectedBreakActivity = selectedBreakActivity
        self.enabledPostures = enabledPostures
        self.enabledBreakActivities = enabledBreakActivities
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.maxStandDuration = maxStandDuration
        self.maxPerchDuration = maxPerchDuration
        self.maxSitDuration = maxSitDuration
        self.autoStartNext = autoStartNext
        self.playSoundOnTransition = playSoundOnTransition
        self.autoOpenOnTransition = autoOpenOnTransition
        self.postureStartTime = postureStartTime
        self.sessionStartTime = sessionStartTime
        self.lastUpdated = lastUpdated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        mode = try container.decodeIfPresent(SessionMode.self, forKey: .mode) ?? .focus
        remainingTime = try container.decodeIfPresent(TimeInterval.self, forKey: .remainingTime) ?? 50 * 60
        isRunning = try container.decodeIfPresent(Bool.self, forKey: .isRunning) ?? false
        selectedPosture = try container.decodeIfPresent(Posture.self, forKey: .selectedPosture) ?? .sit
        selectedBreakActivity = try container.decodeIfPresent(BreakActivity.self, forKey: .selectedBreakActivity) ?? .walking
        enabledPostures = try container.decodeIfPresent([Posture].self, forKey: .enabledPostures) ?? Posture.allCases
        enabledBreakActivities = try container.decodeIfPresent([BreakActivity].self, forKey: .enabledBreakActivities) ?? BreakActivity.allCases
        focusDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .focusDuration) ?? 50 * 60
        breakDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .breakDuration) ?? 5 * 60
        maxStandDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .maxStandDuration) ?? 25 * 60
        maxPerchDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .maxPerchDuration) ?? 30 * 60
        maxSitDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .maxSitDuration) ?? 50 * 60
        autoStartNext = try container.decodeIfPresent(Bool.self, forKey: .autoStartNext) ?? true
        playSoundOnTransition = try container.decodeIfPresent(Bool.self, forKey: .playSoundOnTransition) ?? true
        autoOpenOnTransition = try container.decodeIfPresent(Bool.self, forKey: .autoOpenOnTransition) ?? true
        postureStartTime = try container.decodeIfPresent(Date.self, forKey: .postureStartTime)
        sessionStartTime = try container.decodeIfPresent(Date.self, forKey: .sessionStartTime)
        lastUpdated = try container.decodeIfPresent(Date.self, forKey: .lastUpdated)
    }

    static func load() -> TimerSettings {
        guard let data = UserDefaults.standard.data(forKey: "TimerSettings") else {
            return defaults
        }
        return (try? JSONDecoder().decode(TimerSettings.self, from: data)) ?? defaults
    }

    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        UserDefaults.standard.set(data, forKey: "TimerSettings")
    }
}
