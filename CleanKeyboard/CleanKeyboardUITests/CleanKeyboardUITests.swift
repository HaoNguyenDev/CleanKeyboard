//
//  CleanKeyboardUITests.swift
//  CleanKeyboardUITests
//
//  Created by Hao Nguyen on 17/04/2026.
//

import XCTest

final class CleanKeyboardUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Reset to English so tests have deterministic labels.
        app.launchArguments = ["--reset-language"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Launch

    @MainActor
    func testAppLaunchesAndShowsWindow() throws {
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    // MARK: - Initial state

    @MainActor
    func testLockButtonExistsOnLaunch() throws {
        // The lock button should be visible before any interaction.
        let lockButton = app.buttons["Lock Keyboard"]
        XCTAssertTrue(lockButton.waitForExistence(timeout: 3))
    }

    @MainActor
    func testAppTitleIsVisible() throws {
        let title = app.staticTexts["Clean Keyboard"]
        XCTAssertTrue(title.waitForExistence(timeout: 3))
    }

    // MARK: - Language Picker

    @MainActor
    func testLanguagePickerExists() throws {
        // The picker is the menu button in the top-right corner (flag emoji).
        let picker = app.popUpButtons.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
    }

    @MainActor
    func testLanguagePickerOpens() throws {
        let picker = app.popUpButtons.firstMatch
        XCTAssertTrue(picker.waitForExistence(timeout: 3))
        picker.click()
        // After clicking, a menu item for one of the supported languages should appear.
        let germanItem = app.menuItems["🇩🇪 Deutsch"]
        XCTAssertTrue(germanItem.waitForExistence(timeout: 3))
        // Dismiss by pressing Escape.
        app.typeKey(.escape, modifierFlags: [])
    }
}
