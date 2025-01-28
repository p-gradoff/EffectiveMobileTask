//
//  LaunchManager.swift
//  EffectiveMobileTaskTests
//
//  Created by Павел Градов on 24.01.2025.
//

import XCTest
@testable import EffectiveMobileTask

final class LaunchManagerUnit: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: LaunchManager.initialLaunchKey)
    }

    func testLaunch_Initial() throws {
        let isInitialLaunch = LaunchManager.isInitialLaunch()
        XCTAssertTrue(isInitialLaunch, "Initial Launch")
    }

    func testLaunch_Subsequent() throws {
        let _ = LaunchManager.isInitialLaunch()
        let isInitialLaunch = LaunchManager.isInitialLaunch()
        XCTAssertFalse(isInitialLaunch, "Subsequent Launch")
    }
    
    func testLaunch_InitialSavesUserDefaultsFlag() throws {
        let _ = LaunchManager.isInitialLaunch()
        let savedValue = UserDefaults.standard.object(forKey: LaunchManager.initialLaunchKey)
        XCTAssertNotNil(savedValue, "Saved UserDefaults flag")
    }
}
