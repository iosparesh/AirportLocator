//
//  Constants.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

enum AppStoryBoard: String {
    case main = "Main"
    var storyboard: UIStoryboard {
        switch self {
        case .main: return UIStoryboard(name: "Main", bundle: nil)
        }
    }
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T? {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        return self.instance.instantiateViewController(withIdentifier: storyboardID) as? T
    }
}
enum GoogleSearch: String {
    case customSearchApiKey = "AIzaSyAopXBD1YFznzT11jGMJfpuPGgcz8ZTfEg"
}
class GoogleApi {
    class func getApi(location: CLLocationCoordinate2D, searchKey: String) -> String {
        return "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location.latitude),\(location.longitude)&radius=5000&keyword=\(searchKey)&key=\(GoogleSearch.customSearchApiKey.rawValue)"
    }
}
