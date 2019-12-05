//
//  HomeScreenView.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import UIKit
import MapKit


class HomeScreenView: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var annotation = MKPointAnnotation()
    var viewModel: HomeViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        viewModel = HomeViewModel()
        updateCurrentLocation()
        viewModel.startLocationUpdate()
    }
    func setUpMap() {
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    func updateCurrentLocation() {
        _ = viewModel.currentLocation.observeNext { (updatedLocation) in
            DispatchQueue.main.async {
                self.updateMapWithNewLocation(updatedLocation: updatedLocation)
            }
        }
        _ = viewModel.annotations.observeNext(with: { (annotation, added) in
            if added {
                if let lastAdded = annotation.last {
                    let pinAnnotationView = MKPinAnnotationView(annotation: lastAdded, reuseIdentifier: "pin")
                    pinAnnotationView.image = UIImage(named: lastAdded.pinCustomImageName)
                    self.mapView.addAnnotation(pinAnnotationView.annotation!)
                }
            } else {
                // Update
            }
        })
    }
    func updateMapWithNewLocation(updatedLocation: CLLocation?) {
        guard let newLocation = updatedLocation else {
            return
        }
        let center = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        annotation.coordinate = newLocation.coordinate
        annotation.title = "Me Here"
        annotation.subtitle = "current location"
        mapView.addAnnotation(annotation)
    }
}
extension HomeScreenView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        guard !annotation.isKindOfClass(MKUserLocation) else {
//            return nil
//        }
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("annotation tapped")
    }
}
