import XCTest

final class tvapp_iosUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Tests

    @MainActor
    func testShowListDisplaysNavigationBarTitle() throws {
        // Verify navigation title on the main show list
        let navBar = app.navigationBars["TV Shows"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5.0), "Navigation title 'TV Shows' should be displayed.")
    }

    @MainActor
    func testNavigateToShowDetailAndBack() throws {
        // 1. Wait for the list to load and verify navigation title
        let navBar = app.navigationBars["TV Shows"]
        XCTAssertTrue(navBar.waitForExistence(timeout: 5.0), "Main list navigation bar should appear.")

        // 2. Find and tap the first cell in the List
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5.0), "Show list should contain at least one item.")
        firstCell.tap()

        // 3. Verify detail screen loaded by checking Cast and Seasons section headers
        let castHeader = app.staticTexts["Cast"]
        XCTAssertTrue(castHeader.waitForExistence(timeout: 5.0), "Detail view should display 'Cast' section header.")

        let seasonsHeader = app.staticTexts["Seasons"]
        XCTAssertTrue(seasonsHeader.waitForExistence(timeout: 5.0), "Detail view should display 'Seasons' section header.")

        // 4. Navigate back to the main list
        let backButton = app.navigationBars.buttons.firstMatch
        XCTAssertTrue(backButton.exists, "Back button should exist in navigation bar.")
        backButton.tap()

        // 5. Verify we are back on the main list
        XCTAssertTrue(navBar.waitForExistence(timeout: 5.0), "Should navigate back to main 'TV Shows' list.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
