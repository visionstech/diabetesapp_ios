//
//  CarePlanObj.swift
//  DiabetesApp
//
//  Created by IOS4 on 29/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class CarePlanObj: NSObject {
    
    var id         = String()
    var dosage     = [Int]()
    var condition  = [String]()
    var name       = String()
    var nameAr      = String()
    var isNew       = Bool()
    var carePlanImageURL  = UIImage()
    var isEdit       = Bool()
    var strImageURL      = String()
    var type = String()
}
