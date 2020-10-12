//
//  MockLocationService.swift
//  djendureTests
//
//  Created by Michaela Barcia on 9/29/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

@testable import djendure
import Foundation
import CoreLocation

public class MockLocationService: LocationServiceProtocol {
    
    public var delegate: LocationServiceDelegate?
    public var locationManager: LocationManager = MockLocationManager()

    public func stopLocationUpdates() { }
    
    public func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    public func readLocations(locations: [CLLocation]) { }
        
}
