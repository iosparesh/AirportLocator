//
//  HomeViewModel.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import UIKit
import CoreLocation
import Bond

class HomeViewModel: NSObject {
    var airPorts: [Airport] = []
    var currentLocation: Observable<CLLocation?> = Observable(nil)
    var annotations: Observable<(annotations: [AirportAnnotation], isAdded: Bool)> = Observable(([], false))
    func startLocationUpdate() {
        LocationMaster.shared.startUpdatingLocation()
        LocationMaster.shared.delegate = self
    }
    func loadAirportAnnotations() {
        for airport in airPorts {
            let airPortAnnotation = AirportAnnotation()
            airPortAnnotation.pinCustomImageName = "airport"
            airPortAnnotation.coordinate = airport.location!.coordinate
            airPortAnnotation.title = "\(airport.name ?? "")\n\(airport.vicinity ?? "")"
            airPortAnnotation.subtitle = String(format: "%.1f", airport.distance) + "Km"
            annotations.value.annotations.append(airPortAnnotation)
            annotations.value.isAdded = true
        }
    }
    func fetchNearByAirPorts(completion: ((_ success: Bool,_ error: Error?) -> Void)?) {
        let api = GoogleApi.getApi(location: currentLocation.value!.coordinate, searchKey: "airport")
        var request = URLRequest(url: URL(string: api)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let data = data {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let dict = jsonData as? [String: AnyObject] {
                        if let results = dict["results"] as? [AnyObject] {
                            for object in results {
                                var airport = Airport()
                                if let geometry = object.value(forKey: "geometry") as? [String: AnyObject] {
                                    let lat = geometry["location"]?.value(forKey: "lat") as? Double ?? 0.000000
                                    let lng = geometry["location"]?.value(forKey: "lng") as? Double ?? 0.000000
                                    if let latitude = CLLocationDegrees(exactly: lat), let longitude = CLLocationDegrees(exactly: lng) {
                                        let airportLocation = CLLocation(latitude: latitude, longitude: longitude)
                                        let distance = self.currentLocation.value!.distance(from: airportLocation) / 1000
                                        airport.location = airportLocation
                                        airport.distance = distance
                                    }
                                }
                                airport.place_id = object.value(forKey: "place_id") as? String
                                airport.icon = object.value(forKey: "icon") as? String
                                airport.id = object.value(forKey: "id") as? String
                                airport.name = object.value(forKey: "name") as? String
                                airport.vicinity = object.value(forKey: "vicinity") as? String
                                self.airPorts.append(airport)
                            }
                        }
                    }
                    completion?(true, nil)
                } catch {
                    completion?(false, error)
                }
            }
        }).resume()
    }
    func getAllLocations() -> [CLLocationCoordinate2D] {
        var airportLocations = [CLLocationCoordinate2D]()
        airPorts.forEach { (airportLocation) in
            if let location = airportLocation.location {
                airportLocations.append(location.coordinate)
            }
        }
        return airportLocations
    }
}
// MARK :- LocationUpdateDelegate
extension HomeViewModel: LocationUpdateDelegate {
    func locationUpdate(didUpdate location: CLLocation) {
        currentLocation.value = location
        self.fetchNearByAirPorts { (isSucces, error) in
            if error != nil {
                //Show Error
            } else {
                self.loadAirportAnnotations()
            }
        }
    }
    func locationUpdate(didFail error: Error) {
        print(error.localizedDescription)
    }
}
