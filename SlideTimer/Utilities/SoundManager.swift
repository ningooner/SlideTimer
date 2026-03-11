import AppKit

@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private init() {}

    func playFinishedSound() {
        if let sound = NSSound(named: NSSound.Name("Purr")) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}
