//
//  Airport.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import Foundation
import CoreLocation

struct Airport {
    var id: String? = ""
    var icon: String? = ""
    var location: CLLocation?
    var name: String? = ""
    var subTitle: String? = ""
    var place_id: String? = ""
    var distance: Double = 0.0
    var vicinity: String? = ""
}
