//
//  MockLocationManager.swift
//  djendureTests
//
//  Created by Michaela Barcia on 9/30/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

@testable import djendure
import Foundation
import CoreLocation

class MockLocationManager: LocationManager {
    
    var desiredAccuracy: CLLocationAccuracy = 0.0
    var activityType: CLActivityType = .fitness
    var locations: [CLLocation] = [
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 50),
            altitude: CLLocationDistance(),
            horizontalAccuracy: CLLocationAccuracy(5),
            verticalAccuracy: CLLocationAccuracy(),
            timestamp: Date()
        ),
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 50.00003, longitude: 50),
            altitude: CLLocationDistance(),
            horizontalAccuracy: CLLocationAccuracy(5),
            verticalAccuracy: CLLocationAccuracy(),
            timestamp: Calendar.current.date(byAdding: .second, value: 1, to: Date())!
        ),
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 50.00006, longitude: 50),
            altitude: CLLocationDistance(),
            horizontalAccuracy: CLLocationAccuracy(5),
            verticalAccuracy: CLLocationAccuracy(),
            timestamp: Calendar.current.date(byAdding: .second, value: 2, to: Date())!
        )
    ]
    var locationFetcherDelegate: LocationFetcherDelegate?
    var distanceFilter: CLLocationDistance = 10
    var pausesLocationUpdatesAutomatically = false
    var allowsBackgroundLocationUpdates = true

    func requestWhenInUseAuthorization() { }
    
    func startUpdatingLocation() {
        locationFetcherDelegate?.locationFetcher(self, didUpdateLocations: locations)
    }
    
    func stopUpdatingLocation() { }
    
    func requestLocation() { }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return .authorizedWhenInUse
    }

    func isLocationServicesEnabled() -> Bool {
        return true
    }
    
}
