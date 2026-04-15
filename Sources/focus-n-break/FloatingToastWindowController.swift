import AppKit
import SwiftUI

@MainActor
final class FloatingToastWindowController {
    static let shared = FloatingToastWindowController()

    private var window: NSPanel?
    private var dismissTask: Task<Void, Never>?

    private init() {}

    func showToast(message: String, symbolName: String) {
        let hostingView = NSHostingView(rootView: FloatingToastView(message: message, symbolName: symbolName))

        if window == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 320, height: 90),
                styleMask: [.borderless, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .statusBar
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = false
            panel.hidesOnDeactivate = false
            panel.ignoresMouseEvents = true
            window = panel
        }

        guard let window else { return }
        window.contentView = hostingView
        position(window: window)
        window.alphaValue = 0
        window.orderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1
        }

        dismissTask?.cancel()
        dismissTask = Task { [weak window] in
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            await MainActor.run {
                guard let window else { return }
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.2
                    window.animator().alphaValue = 0
                } completionHandler: {
                    Task { @MainActor in
                        window.orderOut(nil)
                    }
                }
            }
        }
    }

    private func position(window: NSWindow) {
        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let size = window.frame.size
        let x = frame.maxX - size.width - 20
        let y = frame.maxY - size.height - 12
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
