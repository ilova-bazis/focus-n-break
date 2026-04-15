import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController {
    static let shared = SettingsWindowController()

    private var windowController: NSWindowController?

    private init() {}

    func showWindow(timerService: TimerService) {
        let view = SettingsWindowView()
            .environmentObject(timerService)
        let hostingView = NSHostingView(rootView: view)

        let window: NSWindow
        if let existingWindow = windowController?.window {
            window = existingWindow
        } else {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 620),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            windowController = NSWindowController(window: window)
        }

        window.contentView = hostingView
        window.title = "Settings"
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
