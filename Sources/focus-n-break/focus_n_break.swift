import SwiftUI

@main
struct FocusBreakApp: App {
    @StateObject private var timerService = TimerService(sessionStore: SessionStore())

    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra {
            MenuPopoverView()
                .environmentObject(timerService)
        } label: {
            Text(timerService.menuBarTitle)
        }
        .menuBarExtraStyle(.window)
    }
}
