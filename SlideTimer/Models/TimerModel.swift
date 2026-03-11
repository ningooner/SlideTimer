import Foundation
import Observation
import Combine

enum TimerState {
    case ready, running, paused, finished
}

@MainActor
@Observable
class TimerModel {
    // MARK: - Configuration
    var targetDuration: TimeInterval = 300  // default 5 minutes
    var isCountdown: Bool = true

    // MARK: - Running State
    private(set) var timerState: TimerState = .ready
    private(set) var accumulatedBeforePause: TimeInterval = 0
    // Incremented every tick so @Observable notifies views despite elapsedTime using Date()
    private(set) var lastTick: Date = Date()

    private var startDate: Date?
    private var tickCancellable: AnyCancellable?

    // MARK: - Computed: elapsed & remaining

    var elapsedTime: TimeInterval {
        guard let startDate else { return accumulatedBeforePause }
        return accumulatedBeforePause + Date().timeIntervalSince(startDate)
    }

    var remainingTime: TimeInterval {
        max(0, targetDuration - elapsedTime)
    }

    // MARK: - Convenience flags (mirrors timerState for bindings)

    var isRunning: Bool { timerState == .running }
    var isPaused: Bool  { timerState == .paused  }
    var isFinished: Bool { timerState == .finished }

    // MARK: - Computed display properties

    var displayTime: String {
        _ = lastTick  // establishes @Observable dependency so views re-render each tick
        let seconds = isCountdown ? remainingTime : elapsedTime
        let total = Int(seconds)
        let mm = total / 60
        let ss = total % 60
        return String(format: "%02d:%02d", mm, ss)
    }

    var progress: Double {
        _ = lastTick
        guard targetDuration > 0 else { return 0 }
        return min(1.0, elapsedTime / targetDuration)
    }

    var isInWarningZone: Bool {
        isCountdown && remainingTime <= 30 && timerState != .ready
    }

    var isInDangerZone: Bool {
        isCountdown && remainingTime <= 10 && timerState != .ready
    }

    // MARK: - Methods

    func start() {
        guard timerState != .running else { return }

        if timerState == .finished { reset() }

        startDate = Date()
        timerState = .running
        startTick()
    }

    func pause() {
        guard timerState == .running else { return }
        accumulatedBeforePause = elapsedTime
        startDate = nil
        timerState = .paused
        stopTick()
    }

    func reset() {
        stopTick()
        startDate = nil
        accumulatedBeforePause = 0
        timerState = .ready
    }

    func setDuration(minutes: Int, seconds: Int) {
        targetDuration = TimeInterval(minutes * 60 + seconds)
        reset()
    }

    func setPreset(minutes: Int) {
        setDuration(minutes: minutes, seconds: 0)
    }

    func toggleMode() {
        isCountdown.toggle()
        reset()
    }

    // MARK: - Tick engine

    private func startTick() {
        tickCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTick() {
        tickCancellable?.cancel()
        tickCancellable = nil
    }

    private func tick() {
        lastTick = Date()  // triggers @Observable → SwiftUI re-renders displayTime/progress
        // Check for countdown completion
        if isCountdown && timerState == .running && remainingTime <= 0 {
            accumulatedBeforePause = targetDuration
            startDate = nil
            timerState = .finished
            stopTick()
            SoundManager.shared.playFinishedSound()
        }
    }
}
