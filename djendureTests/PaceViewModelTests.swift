//
//  PaceViewModelTests.swift
//  djendureTests
//
//  Created by Michaela Barcia on 9/30/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import XCTest
@testable import djendure

class PaceViewModelTests: XCTestCase {
    
    let paceVM = PaceViewModel(spotifyService: MockSpotifyService(), locationService: MockLocationService())

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        paceVM.reset()
    }

    func testStartRun() throws {
        let expectation = XCTestExpectation(description: "startRun")
        paceVM.startRun() {
           expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        XCTAssertTrue(paceVM.runInProgress)
        XCTAssertNotNil(paceVM.timer)
    }
    
    func testReset() throws {
        paceVM.reset()
        XCTAssertFalse(paceVM.runInProgress)
        XCTAssertNil(paceVM.timer)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
