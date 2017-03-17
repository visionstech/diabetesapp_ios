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
    var updatedBy = String()
    var tempIndex = Int()
    var wasUpdated = Bool()
    var updatedDate = String()
    
    
//    func encodeWithCoder(encoder: NSCoder) {
//        encoder.encode(id, forKey: "id")
//        encoder.encode(dosage, forKey: "dosage")
//        encoder.encode(condition, forKey: "condition")
//        encoder.encode(name, forKey: "name")
//        encoder.encode(nameAr, forKey: "nameAr")
//        encoder.encode(isNew, forKey: "isNew")
//        encoder.encode(carePlanImageURL, forKey: "carePlanImageURL")
//        encoder.encode(isEdit, forKey: "isEdit")
//        encoder.encode(strImageURL, forKey: "strImageURL")
//        encoder.encode(type, forKey: "type")
//    }
//    
//    required init(coder aDecoder: NSCoder) {
//        self.id = aDecoder.decodeObject(forKey: "id")! as! String
//        self.dosage = aDecoder.decodeObject(forKey: "dosage")! as! [Int]
//        self.condition = aDecoder.decodeObject(forKey: "condition")! as! [String]
//        self.name = aDecoder.decodeObject(forKey: "name")! as! String
//        self.nameAr = aDecoder.decodeObject(forKey: "nameAr")! as! String
//        self.isNew = aDecoder.decodeObject(forKey: "isNew")! as! Bool
//        self.carePlanImageURL = aDecoder.decodeObject(forKey: "carePlanImageURL")! as! UIImage
//        self.isEdit = aDecoder.decodeObject(forKey: "isEdit")! as! Bool
//        self.strImageURL = aDecoder.decodeObject(forKey: "strImageURL")! as! String
//        self.type = aDecoder.decodeObject(forKey: "type")! as! String
//    }
    
}
