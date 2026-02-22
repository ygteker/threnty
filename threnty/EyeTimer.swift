
import AppKit
import Observation

@Observable final class EyeTimer {

    enum Phase {
        case idle, working, breaking
    }

    static var workDuration  = 20 * 60
    static var breakDuration = 20

    private(set) var phase: Phase = .idle
    private(set) var secondsRemaining: Int = 0

    var onBreakStart: (() -> Void)?
    var onBreakEnd:   (() -> Void)?

    private var timer: Timer?
    private var targetDate: Date = .distantFuture

    // MARK: - Derived display values

    var menuBarLabel: String {
        switch phase {
        case .idle:
            return "◎"
        case .working:
            let m = secondsRemaining / 60
            let s = secondsRemaining % 60
            return String(format: "%d:%02d", m, s)
        case .breaking:
            return "\(secondsRemaining)s"
        }
    }

    var phaseLabel: String {
        switch phase {
        case .idle:     return "Idle"
        case .working:  return "Work"
        case .breaking: return "Break"
        }
    }

    var breakProgress: Double {
        guard phase == .breaking else { return 0 }
        let total   = Double(EyeTimer.breakDuration)
        let elapsed = total - Double(secondsRemaining)
        return elapsed / total
    }

    // MARK: - Public controls

    func start() {
        guard phase == .idle else { return }
        targetDate = Date().addingTimeInterval(Double(EyeTimer.workDuration))
        secondsRemaining = EyeTimer.workDuration
        phase = .working
        scheduleTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if phase == .breaking {
            onBreakEnd?()
        }
        phase = .idle
        secondsRemaining = 0
    }

    func skipBreak() {
        guard phase == .breaking else { return }
        NSSound(named: "Glass")?.play()
        targetDate = Date().addingTimeInterval(Double(EyeTimer.workDuration))
        secondsRemaining = EyeTimer.workDuration
        phase = .working
        onBreakEnd?()
    }

    func toggle() {
        if phase == .idle { start() } else { stop() }
    }

    // MARK: - Private timer machinery

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        let remaining = targetDate.timeIntervalSinceNow
        secondsRemaining = max(0, Int(ceil(remaining)))

        guard remaining <= 0 else { return }

        switch phase {
        case .working:
            NSSound(named: "Blow")?.play()
            targetDate = Date().addingTimeInterval(Double(EyeTimer.breakDuration))
            secondsRemaining = EyeTimer.breakDuration
            phase = .breaking
            onBreakStart?()

        case .breaking:
            NSSound(named: "Glass")?.play()
            targetDate = Date().addingTimeInterval(Double(EyeTimer.workDuration))
            secondsRemaining = EyeTimer.workDuration
            phase = .working
            onBreakEnd?()

        case .idle:
            break
        }
    }
}
