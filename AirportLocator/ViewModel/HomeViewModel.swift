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
    var currentLocation: Observable<CLLocation?> = Observable(nil)
    var annotations: Observable<(annotations: [AirportAnnotation], isAdded: Bool)> = Observable(([], false))
    func startLocationUpdate() {
        LocationMaster.shared.startUpdatingLocation()
        LocationMaster.shared.delegate = self
    }
    func loadAirportAnnotations(airports: [Airport]) {
        for airport in airports {
            let airPortAnnotation = AirportAnnotation()
            airPortAnnotation.pinCustomImageName = "airport"
            airPortAnnotation.coordinate = airport.location!.coordinate
            airPortAnnotation.title = airport.title
            airPortAnnotation.subtitle = airport.subTitle
            annotations.value.annotations.append(airPortAnnotation)
            annotations.value.isAdded = true
        }
    }
    func fetchNearByAirPorts() {
        var request = URLRequest(url: URL(string: GoogleApi.getApi(location: currentLocation.value!.coordinate, searchKey: "airport"))!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            print(response)
            do {
                let jsonDecoder = JSONDecoder()
//                let responseModel = try jsonDecoder.decode(Airport.self, from: data!)
//                print(responseModel)
            } catch {
                print("JSON Serialization error")
            }
        }).resume()
    }
}
extension HomeViewModel: LocationUpdateDelegate {
    func locationUpdate(didUpdate location: CLLocation) {
        print(location)
        currentLocation.value = location
        self.fetchNearByAirPorts()
    }
    func locationUpdate(didFail error: Error) {
        print(error.localizedDescription)
    }
}
