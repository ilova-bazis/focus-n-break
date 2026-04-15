import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization(completion: (@Sendable () -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in
            completion?()
        }
    }

    func fetchAuthorizationStatus(completion: @escaping @Sendable (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    func sendTransitionNotification(for mode: SessionMode) {
        let content = UNMutableNotificationContent()
        switch mode {
        case .focus:
            content.title = "Back to focus"
            content.body = "Start your next focus block."
        case .breakTime:
            content.title = "Time to rest"
            content.body = "Take a short recovery break."
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
