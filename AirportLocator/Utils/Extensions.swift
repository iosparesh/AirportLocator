//
//  Extensions.swift
//  AirportLocator
//
//  Created by Paresh Prajapati on 05/12/19.
//  Copyright © 2019 Paresh Prajapati. All rights reserved.
//

import UIKit

extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    static func instantiateFromAppStoryboard(appStoryboard: AppStoryBoard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)!
    }
}
