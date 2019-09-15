//
//  sharedealUITests.swift
//  sharedealUITests
//
//  Created by Eddie Long on 14/09/2019.
//  Copyright © 2019 Eddie Long. All rights reserved.
//

import XCTest

class SharedealUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSetupSaleViaDialog() {
        
        let app = XCUIApplication()
        let tableView = app.tables["sell_list_table_view"]
        XCTAssert(tableView.cells.count > 0) // swiftlint:disable:this empty_count
        // Ensure the dialog is not present
        XCTAssertFalse(app.buttons["sell_dialog_save_button"].exists)
        tableView.cells.staticTexts.element(boundBy: 0).tap()
        // Ensure the dialog is now present
        XCTAssertFalse(app.buttons["sell_dialog_save_button"].isEnabled)
        app.textFields["sell_dialog_textfield"].tap()
        app.textFields["sell_dialog_textfield"].typeText("100")
        XCTAssertTrue(app.buttons["sell_dialog_save_button"].isEnabled)
        app.buttons["Save"].tap()
        
        // Ensure the dialog is now gone
        XCTAssertFalse(app.buttons["sell_dialog_save_button"].exists)
    }
}
