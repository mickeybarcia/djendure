//
//  LocationServiceTests.swift
//  djendureTests
//
//  Created by Michaela Barcia on 9/30/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import XCTest
@testable import djendure
import CoreLocation

class LocationServiceTests: XCTestCase {
    
    let locationService = LocationService(locationManager: MockLocationManager())

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func test() throws {
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

