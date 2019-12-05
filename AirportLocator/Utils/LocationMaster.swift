//
//  LocationMaster.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import Foundation
import CoreLocation
protocol LocationUpdateDelegate: class {
    func locationUpdate(didUpdate location: CLLocation)
    func locationUpdate(didFail error: Error)
}
extension LocationUpdateDelegate {
    func locationUpdate(didUpdate location: CLLocation) {}
    func locationUpdate(didFail error: Error) {}
}

class LocationMaster: NSObject {
    public static let shared = LocationMaster()
    private var locationManager: CLLocationManager!
    weak var delegate: LocationUpdateDelegate?
    override init() {
        super.init()
        self.setUpLocationManager()
    }
    func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
    }
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}
extension LocationMaster: CLLocationManagerDelegate {
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            delegate?.locationUpdate(didUpdate: lastLocation)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationUpdate(didFail: error)
    }
}
