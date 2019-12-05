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
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.showsUserLocation = true
        if let coor = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coor, animated: true)
        }
    }
    func updateCurrentLocation() {
        _ = viewModel.currentLocation.observeNext { [weak self] (updatedLocation) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                //strongSelf.updateMapWithNewLocation(updatedLocation: updatedLocation)
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
        }
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
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
