
import XCTest
@testable import Threnty

@MainActor
final class EyeTimerTests: XCTestCase {

    override func setUp() async throws {
        EyeTimer.workDuration  = 1
        EyeTimer.breakDuration = 1
    }

    override func tearDown() async throws {
        EyeTimer.workDuration  = 20 * 60
        EyeTimer.breakDuration = 20
    }

    // MARK: - Initial state

    func testInitialPhaseIsIdle() async {
        let timer = EyeTimer()
        XCTAssertEqual(timer.phase, .idle)
    }

    func testInitialSecondsRemainingIsZero() async {
        let timer = EyeTimer()
        XCTAssertEqual(timer.secondsRemaining, 0)
    }

    // MARK: - start()

    func testStartTransitionsToWorking() async {
        let timer = EyeTimer()
        timer.start()
        defer { timer.stop() }
        XCTAssertEqual(timer.phase, .working)
    }

    func testStartSetsSecondsRemainingToWorkDuration() async {
        let timer = EyeTimer()
        timer.start()
        defer { timer.stop() }
        XCTAssertEqual(timer.secondsRemaining, EyeTimer.workDuration)
    }

    func testStartIsNoOpWhenAlreadyWorking() async {
        let timer = EyeTimer()
        timer.start()
        defer { timer.stop() }
        let remaining = timer.secondsRemaining
        timer.start()
        XCTAssertEqual(timer.phase, .working)
        XCTAssertEqual(timer.secondsRemaining, remaining)
    }

    // MARK: - stop()

    func testStopFromWorkingTransitionsToIdle() async {
        let timer = EyeTimer()
        timer.start()
        timer.stop()
        XCTAssertEqual(timer.phase, .idle)
        XCTAssertEqual(timer.secondsRemaining, 0)
    }

    func testStopFromIdleIsNoOp() async {
        let timer = EyeTimer()
        timer.stop()
        XCTAssertEqual(timer.phase, .idle)
    }

    func testStopDuringWorkDoesNotCallOnBreakEnd() async {
        let timer = EyeTimer()
        var called = false
        timer.onBreakEnd = { called = true }
        timer.start()
        timer.stop()
        XCTAssertFalse(called)
    }

    func testStopDuringBreakCallsOnBreakEnd() async {
        let timer = EyeTimer()
        var breakEndCalled = false
        timer.onBreakEnd = { breakEndCalled = true }

        let breakStarted = expectation(description: "break started")
        timer.onBreakStart = { breakStarted.fulfill() }
        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        timer.stop()
        XCTAssertTrue(breakEndCalled)
        XCTAssertEqual(timer.phase, .idle)
    }

    // MARK: - toggle()

    func testToggleStartsFromIdle() async {
        let timer = EyeTimer()
        timer.toggle()
        defer { timer.stop() }
        XCTAssertEqual(timer.phase, .working)
    }

    func testToggleStopsFromWorking() async {
        let timer = EyeTimer()
        timer.start()
        timer.toggle()
        XCTAssertEqual(timer.phase, .idle)
    }

    // MARK: - skipBreak()

    func testSkipBreakIsNoOpWhenIdle() async {
        let timer = EyeTimer()
        timer.skipBreak()
        XCTAssertEqual(timer.phase, .idle)
    }

    func testSkipBreakIsNoOpWhenWorking() async {
        let timer = EyeTimer()
        timer.start()
        defer { timer.stop() }
        timer.skipBreak()
        XCTAssertEqual(timer.phase, .working)
    }

    func testSkipBreakTransitionsToWorking() async {
        let timer = EyeTimer()
        var breakEndCalled = false
        timer.onBreakEnd = { breakEndCalled = true }

        let breakStarted = expectation(description: "break started")
        timer.onBreakStart = { breakStarted.fulfill() }
        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        timer.skipBreak()

        XCTAssertEqual(timer.phase, .working)
        XCTAssertEqual(timer.secondsRemaining, EyeTimer.workDuration)
        XCTAssertTrue(breakEndCalled)
        timer.stop()
    }

    // MARK: - Phase transitions via the timer

    func testWorkPhaseTransitionsToBreakOnExpiry() async {
        let timer = EyeTimer()
        let breakStarted = expectation(description: "onBreakStart called")
        timer.onBreakStart = { breakStarted.fulfill() }

        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        XCTAssertEqual(timer.phase, .breaking)
        XCTAssertEqual(timer.secondsRemaining, EyeTimer.breakDuration)
        timer.stop()
    }

    func testBreakPhaseTransitionsBackToWorkOnExpiry() async {
        let timer = EyeTimer()
        let breakEnded = expectation(description: "onBreakEnd called")
        timer.onBreakEnd = { breakEnded.fulfill() }

        timer.start()
        await fulfillment(of: [breakEnded], timeout: 5)

        XCTAssertEqual(timer.phase, .working)
        timer.stop()
    }

    func testOnBreakStartIsCalledOnTransition() async {
        let timer = EyeTimer()
        var callCount = 0
        let breakStarted = expectation(description: "onBreakStart called once")
        timer.onBreakStart = {
            callCount += 1
            breakStarted.fulfill()
        }

        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        XCTAssertEqual(callCount, 1)
        timer.stop()
    }

    // MARK: - Computed properties

    func testMenuBarLabelWhenIdle() async {
        let timer = EyeTimer()
        XCTAssertEqual(timer.menuBarLabel, "◎")
    }

    func testMenuBarLabelWhenWorkingFormatsAsMinutesAndSeconds() async {
        EyeTimer.workDuration = 5 * 60
        let timer = EyeTimer()
        timer.start()
        defer { timer.stop() }
        XCTAssertEqual(timer.menuBarLabel, "5:00")
    }

    func testMenuBarLabelWhenBreakingShowsSeconds() async {
        EyeTimer.breakDuration = 20
        let timer = EyeTimer()

        let breakStarted = expectation(description: "break started")
        timer.onBreakStart = { breakStarted.fulfill() }
        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        XCTAssertTrue(timer.menuBarLabel.hasSuffix("s"), "Expected '\(timer.menuBarLabel)' to end with 's'")
        timer.stop()
    }

    func testPhaseLabelValues() async {
        let timer = EyeTimer()
        XCTAssertEqual(timer.phaseLabel, "Idle")
        timer.start()
        XCTAssertEqual(timer.phaseLabel, "Work")
        timer.stop()
    }

    func testBreakProgressIsZeroWhenNotBreaking() async {
        let timer = EyeTimer()
        XCTAssertEqual(timer.breakProgress, 0.0)
        timer.start()
        XCTAssertEqual(timer.breakProgress, 0.0)
        timer.stop()
    }

    func testBreakProgressIsBetweenZeroAndOneWhenBreaking() async {
        EyeTimer.breakDuration = 10
        let timer = EyeTimer()

        let breakStarted = expectation(description: "break started")
        timer.onBreakStart = { breakStarted.fulfill() }
        timer.start()
        await fulfillment(of: [breakStarted], timeout: 3)

        XCTAssertGreaterThanOrEqual(timer.breakProgress, 0.0)
        XCTAssertLessThanOrEqual(timer.breakProgress, 1.0)
        timer.stop()
    }
}
