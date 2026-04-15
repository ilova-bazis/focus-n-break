import AppKit
import SwiftUI

@MainActor
final class AppWindowController {
    static let shared = AppWindowController()

    private var windowController: NSWindowController?

    private init() {}

    func showTransitionWindow(mode: SessionMode, focusPosture: Posture?, breakActivity: BreakActivity?) {
        showAlert(view: TransitionAlertView(mode: mode, focusPosture: focusPosture, breakActivity: breakActivity))
    }

    func showPostureSwitchWindow(nextPosture: Posture) {
        showAlert(view: PostureSwitchAlertView(posture: nextPosture))
    }

    private func showAlert<Content: View>(view: Content) {
        let hostingView = NSHostingView(rootView: view)

        let window: NSWindow
        if let existingWindow = windowController?.window {
            window = existingWindow
        } else {
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.isReleasedWhenClosed = false
            windowController = NSWindowController(window: window)
        }

        window.contentView = hostingView
        window.title = "Focus & Break"
        window.center()
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}

