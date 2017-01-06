//
//  UtilityClass.swift
//  DiabetesApp
//
//  Created by IOS4 on 22/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class UtilityClass: NSObject {
    
    class func displayAlertMessage(message:String , title:String)->UIAlertController
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
 

}
