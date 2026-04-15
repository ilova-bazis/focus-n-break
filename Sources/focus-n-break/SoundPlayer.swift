import AppKit

enum SoundPlayer {
    static func playTransition() {
        NSSound(named: "Submarine")?.play()
    }
}
