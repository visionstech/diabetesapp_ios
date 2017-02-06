//
//  UIActivityIndicator+Helpers.swift
//  DiabetesApp
//
//  Created by User on 1/7/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    func mySetActive(_ active: Bool) {
        if active {
            self.isHidden = false
            self.startAnimating()
        }
        else {
            self.isHidden = true
            self.stopAnimating()
        }
    }
}
