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
    var userAnnotation = AirportAnnotation()
    var viewModel: HomeViewModel!
// MARK :- ViewController's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        viewModel = HomeViewModel()
        updateCurrentLocation()
        viewModel.startLocationUpdate()
    }
    func setUpMap() {
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        if let coor = mapView.userLocation.location?.coordinate {
            mapView.setCenter(coor, animated: true)
        }
    }
    func updateCurrentLocation() {
        _ = viewModel.currentLocation.observeNext { [weak self] (updatedLocation) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.updateMapWithNewLocation(updatedLocation: updatedLocation)
            }
        }
        _ = viewModel.annotations.observeNext(with: { [weak self] (annotation, added) in
            guard let strongSelf = self else { return }
            if added {
                if let lastAdded = annotation.last {
                    strongSelf.updateMapWithAirPort(lastAdded: lastAdded)
                }
            } else {
                // Update
            }
        })
    }
    func updateMapWithAirPort(lastAdded: AirportAnnotation) {
        DispatchQueue.main.async {
            let center = CLLocationCoordinate2D(latitude: lastAdded.coordinate.latitude, longitude: lastAdded.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            let pinAnnotationView = MKPinAnnotationView(annotation: lastAdded, reuseIdentifier: "pin")
            self.mapView.addAnnotation(pinAnnotationView.annotation!)
            //self.zoomToFit()
            self.setCenterForMap()
        }
    }
    func updateMapWithNewLocation(updatedLocation: CLLocation?) {
        guard let newLocation = updatedLocation else {
            return
        }
        mapView.removeAnnotations(self.viewModel.annotations.value.annotations)
        self.viewModel.airPorts.removeAll()
        self.viewModel.annotations.value.annotations.removeAll()
        userAnnotation.coordinate = newLocation.coordinate
        userAnnotation.title = "Paresh is here"
        userAnnotation.pinCustomImageName = "user"
        userAnnotation.subtitle = "Looking for airport"
        let pinAnnotationView = MKPinAnnotationView(annotation: userAnnotation, reuseIdentifier: "pin")
        self.mapView.addAnnotation(pinAnnotationView.annotation!)
    }
    func setCenterForMap() {
        var mapRect: MKMapRect = MKMapRect.null
        for loc in mapView.annotations {
            let point: MKMapPoint = MKMapPoint(loc.coordinate)
            print( "location is : \(loc.coordinate)");
            mapRect = mapRect.union(MKMapRect(x: point.x,y: point.y,width: 0,height: 0))
        }
        if let userLocation = viewModel.currentLocation.value {
            let point: MKMapPoint = MKMapPoint(userLocation.coordinate)
            mapRect = mapRect.union(MKMapRect(x: point.x,y: point.y,width: 0,height: 0))
        }
        mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 40.0, left: 40.0, bottom: 40.0, right: 40.0), animated: true)
    }
}
// MARK :- MKMapViewDelegate
extension HomeScreenView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("annotation tapped")
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            if let userAnnotation = annotation as? MKUserLocation {
                userAnnotation.title = "Paresh is here"
            }
            return nil
        }
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        if let customPointAnnotation = annotation as? AirportAnnotation {
            annotationView?.image = UIImage(named: customPointAnnotation.pinCustomImageName)
        }
        return annotationView
    }
}
