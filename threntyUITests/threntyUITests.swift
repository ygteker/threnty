
import XCTest

@MainActor
final class ThrentyUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() async throws {
        app.terminate()
    }

    // MARK: - Launch

    func testAppIsRunningAfterLaunch() async {
        XCTAssertEqual(app.state, .runningForeground)
    }

    func testNoRegularWindowsOnLaunch() async {
        XCTAssertEqual(app.windows.count, 0)
    }

    // MARK: - Menu bar item

    func testMenuBarItemExistsAfterLaunch() async {
        XCTAssertTrue(app.buttons["◎"].waitForExistence(timeout: 2))
    }

    // MARK: - Popover content

    private func openPopover() {
        app.buttons["◎"].click()
    }

    func testClickingMenuBarItemOpensPopover() async {
        openPopover()
        XCTAssertTrue(app.staticTexts["Idle"].waitForExistence(timeout: 2))
    }

    func testPopoverHasStartButton() async {
        openPopover()
        XCTAssertTrue(app.buttons["Start"].waitForExistence(timeout: 2))
    }

    func testPopoverHasQuitButton() async {
        openPopover()
        XCTAssertTrue(app.buttons["Quit Threnty"].waitForExistence(timeout: 2))
    }

    // MARK: - Start / Stop flow

    func testStartButtonChangesToStop() async {
        openPopover()
        app.buttons["Start"].click()
        XCTAssertTrue(app.buttons["Stop"].waitForExistence(timeout: 2))
    }

    func testStopButtonChangesToStart() async {
        openPopover()
        app.buttons["Start"].click()
        _ = app.buttons["Stop"].waitForExistence(timeout: 2)
        app.buttons["Stop"].click()
        XCTAssertTrue(app.buttons["Start"].waitForExistence(timeout: 2))
    }

    func testPhaseLabelChangesToWorkAfterStart() async {
        openPopover()
        app.buttons["Start"].click()
        XCTAssertTrue(app.staticTexts["Work"].waitForExistence(timeout: 2))
    }

    func testPhaseLabelReturnsToIdleAfterStop() async {
        openPopover()
        app.buttons["Start"].click()
        _ = app.buttons["Stop"].waitForExistence(timeout: 2)
        app.buttons["Stop"].click()
        XCTAssertTrue(app.staticTexts["Idle"].waitForExistence(timeout: 2))
    }

    func testMenuBarLabelChangesAfterStart() async {
        openPopover()
        app.buttons["Start"].click()
        XCTAssertFalse(app.buttons["◎"].waitForExistence(timeout: 2))
    }
}
