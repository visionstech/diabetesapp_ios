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
    var dosageNew = [Bool]()
    var medNew = Bool()
    var deletedCondition = [String]()
    var deletedDosage = [Int]()
    var timingID = [String]()
    
//    init(id: String, dosage: [Int], condition: [String],name: String,nameAr: String,isNew: Bool,carePlanImageURL: UIImage,isEdit: Bool,strImageURL: String,type: String,updatedBy: String,tempIndex: Int,wasUpdated: Bool,updatedDate: String,dosageNew: [Bool],medNew: Bool,deletedCondition: [String],deletedDosage: [Int],timingID: [String]) {
//        self.id = id
//        self.dosage = dosage
//        self.condition = condition
//         self.name = name
//         self.nameAr = nameAr
//         self.isNew = isNew
//         self.carePlanImageURL = carePlanImageURL
//         self.isEdit = isEdit
//         self.strImageURL = strImageURL
//         self.type = type
//         self.updatedBy = updatedBy
//         self.tempIndex = tempIndex
//         self.wasUpdated = wasUpdated
//         self.updatedDate = updatedDate
//        self.dosageNew = dosageNew
//        self.medNew = medNew
//        self.deletedCondition = deletedCondition
//        self.deletedDosage = deletedDosage
//          self.timingID = timingID
//    }
    
//    func copy(with zone: NSZone? = nil) -> Any {
//        let copy = CarePlanObj(id: self.id, dosage: self.dosage, condition: self.condition , name: self.name, nameAr: self.nameAr, isNew: self.isNew, carePlanImageURL: self.carePlanImageURL, isEdit: self.isEdit, strImageURL: self.strImageURL, type:  self.type , updatedBy: self.updatedBy, tempIndex: self.tempIndex, wasUpdated: self.wasUpdated , updatedDate: self.updatedDate, dosageNew: self.dosageNew, medNew: self.medNew , deletedCondition: self.deletedCondition, deletedDosage: self.deletedDosage, timingID:  self.timingID)
//        return copy
//    }
    
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
