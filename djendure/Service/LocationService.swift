//
//  LocationService.swift
//  djendure
//
//  Created by Michaela Barcia on 8/20/20.
//  Copyright © 2020 cascade.ai. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationServiceDelegate {
    func locationChanged(locations: [CLLocation])
    func locationError(error: Error)
}

protocol LocationFetcherDelegate: class {
    func locationFetcher(_ fetcher: LocationManager, didUpdateLocations locations: [CLLocation])
    func locationFetcher(_ fetcher: LocationManager, didFailWithError error: Error)
}

protocol LocationManager {

    var locationFetcherDelegate: LocationFetcherDelegate? {get set}
    var distanceFilter: CLLocationDistance { get set }
    var pausesLocationUpdatesAutomatically: Bool { get set }
    var allowsBackgroundLocationUpdates: Bool { get set }
    var desiredAccuracy: CLLocationAccuracy { get set }
    var activityType: CLActivityType { get set }
    
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
    func requestLocation()
    
    func getAuthorizationStatus() -> CLAuthorizationStatus
    func isLocationServicesEnabled() -> Bool
    
}

extension CLLocationManager: LocationManager {
    
    var locationFetcherDelegate: LocationFetcherDelegate? {
        get {
            return delegate as! LocationFetcherDelegate?
        }
        set {
            delegate = newValue as! CLLocationManagerDelegate?
        }
    }
    
    func getAuthorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    func isLocationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
}

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    func stopLocationUpdates()
    func startLocationUpdates()
}

class LocationService: NSObject, LocationServiceProtocol {
    
    var delegate: LocationServiceDelegate?
    internal var locationManager: LocationManager
                
    init(locationManager: LocationManager=CLLocationManager()) {
        self.locationManager = locationManager
        super.init()
        self.locationManager.locationFetcherDelegate = self
        self.locationManager.activityType = .fitness
        self.locationManager.distanceFilter = 5
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startLocationUpdates() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
}

extension LocationService: LocationFetcherDelegate {
    
    func locationFetcher(_ fetcher: LocationManager, didUpdateLocations locations: [CLLocation]) {
        if delegate != nil {
            delegate!.locationChanged(locations: locations)
        }
    }
    
    func locationFetcher(_ fetcher: LocationManager, didFailWithError error: Error) {
        debugPrint("error loading location: \(error.localizedDescription)")
        if delegate != nil {
            delegate!.locationError(error: error)
        }
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationFetcher(manager, didUpdateLocations: locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationFetcher(manager, didFailWithError: error)
    }
    
}
