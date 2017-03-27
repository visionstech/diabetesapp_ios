//
//  HomeTabBarController.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class HomeTabBarController: UITabBarController {

    var currentLocale : String = ""
    var newMedarray : NSMutableArray = NSMutableArray()
    var newReadarray : NSMutableArray = NSMutableArray()
    var badgeIconCarePlanCount : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        badgeIconCarePlanCount = 0
        currentLocale = NSLocale.current.languageCode!
          // self .getReadCount()
        self.getUpdatedCarePlan()
        self.getUpdatedCarePlanReading()
        
        setupTabbar()
        self.tabBar.items?.last?.badgeValue = tabCounter
        if(Int(tabCounter)==0)
        {
            self.tabBar.items?.last?.badgeValue = nil
        }
        // Do any additional setup after loading the view.
    }
    
    private func setupTabbar() {
        guard let tabBarItems = tabBar.items else { return }
        tabBar.tintColor = Colors.DHTabBarGreen
        tabBar.barTintColor = Colors.DHTabBarWhiteTint
        tabBar.alpha = 1.0
        
        for (index, tabBarItem) in tabBarItems.enumerated() {
            
            if(currentLocale == "ar"){
                tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold), NSForegroundColorAttributeName:Colors.DHTabBarItemUnselected], for: .normal)
                tabBarItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 11, weight: UIFontWeightBold), NSForegroundColorAttributeName:Colors.DHTabBarGreen], for: .selected)
                
            }
            else{
                tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: Colors.DHTabBarGreen], for: .selected)
                tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: Colors.DHTabBarItemUnselected], for: .normal)
            }
            
           
            
           
            
            if let image = tabBarItem.image {
                tabBarItem.image = image.imageWithColor(color1: Colors.DHTabBarItemUnselected).withRenderingMode(.alwaysOriginal)
            }
             //tabBarItem.image = tabBarItem.image?.imageWithColor(UIColor.red).imageWithRenderingMode(.AlwaysOriginal)
            //tabBarItem.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .normal)
            
        
            if let selectedImage = getTabBarSelectedImage(ForIndex: index) {
                tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
            }
            
        }
     
    }
    
    private func getTabBarSelectedImage(ForIndex index: Int) -> UIImage? {
        switch index {
//        case 0:
//            return #imageLiteral(resourceName: "GIntake-Selected")
//        case 1:
//            return #imageLiteral(resourceName: "History-Selected")
        default:
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getReadCount() {
        let selectedUser = QBUUser()
        selectedUser.email = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
        selectedUser.password = UserDefaults.standard.value(forKey: userDefaults.loggedInUserPassword) as! String!
        
        Alamofire.request("http://54.244.176.114:3000/api/messages/unread?email="+selectedUser.email!+"&password="+selectedUser.password!, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    print (JSON)
                    if let result_number = JSON["total"] as? NSNumber
                    {
                        let result_string = "\(result_number)"
                        self.tabBar.items?.last?.badgeValue = result_string
                        if(Int(tabCounter)==0)
                        {
                            self.tabBar.items?.last?.badgeValue = nil
                        }
                    }
                }
                break
            case .failure:
                print("failure")
                SVProgressHUD.dismiss()
                break
            }
        }
    }
    
    func getUpdatedCarePlan() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "userid": patientsID,
            "loggedInUser": ""
        ]
        //SVProgressHUD.show(withStatus: "Loading Medications".localized)
               Alamofire.request("\(baseUrl)\(ApiMethods.getcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            SVProgressHUD.dismiss()
            switch response.result {
            case .success:
                
                print("Validation Successful")
                
                
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    if  let JSONNew :  NSArray = JSON.value(forKey: "medicineList") as? NSArray{
                        
                        self.newMedarray = NSMutableArray()
                        for data in JSONNew {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanObj()
                                                      //obj.type = dict.value(forKey: "medType") as! String
                            obj.wasUpdated = dict.value(forKey: "isNew") as! Bool
                            
                            self.newMedarray.add(obj)
                            
                        }
                    }
                }
                
               //badgeIconCarePlanCount = 0
                for indexNew in 0..<self.newMedarray.count{
                    var objNew = self.newMedarray[indexNew] as! CarePlanObj
                    if objNew.wasUpdated
                    {
                        self.badgeIconCarePlanCount = self.badgeIconCarePlanCount + 1
                    }
                    
                }
                
                if self.badgeIconCarePlanCount > 0
                {
                    careplanTabBarItem.badgeValue = String(self.badgeIconCarePlanCount)
                }
                else{
                    careplanTabBarItem.badgeValue = nil
                }
                //print("Object medication array")
                // print(self.newMedarray)
               // self.newtblView.reloadData()
               // self.newtblView.layoutIfNeeded()
                
                //var deleted
                
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
            
                SVProgressHUD.dismiss()
                break
                
            }
        
        
    
    
        }
    }
    
    func getUpdatedCarePlanReading() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "userid": patientsID,
            "loggedInUser": ""
        ]
        //SVProgressHUD.show(withStatus: "Loading Medications".localized)
        Alamofire.request("\(baseUrl)\(ApiMethods.getcareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            SVProgressHUD.dismiss()
            switch response.result {
            case .success:
                
                print("Validation Successful")
                
                
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    if  let JSONNew :  NSArray = JSON.value(forKey: "readingList") as? NSArray{
                        
                        self.newReadarray = NSMutableArray()
                        for data in JSONNew {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            //obj.type = dict.value(forKey: "medType") as! String
                            obj.wasUpdated = dict.value(forKey: "isNew") as! Bool
                            
                            self.newReadarray.add(obj)
                            
                        }
                    }
                }
                
               // badgeIconCarePlanCount : Int = 0
                for indexNew in 0..<self.newReadarray.count{
                    var objNew = self.newReadarray[indexNew] as! CarePlanFrequencyObj
                    if objNew.wasUpdated
                    {
                        self.badgeIconCarePlanCount = self.badgeIconCarePlanCount + 1
                    }
                    
                }
                
                if self.badgeIconCarePlanCount > 0
                {
                    careplanTabBarItem.badgeValue = String(self.badgeIconCarePlanCount)
                }
                else{
                    careplanTabBarItem.badgeValue = nil
                }
                //print("Object medication array")
                // print(self.newMedarray)
                // self.newtblView.reloadData()
                // self.newtblView.layoutIfNeeded()
                
                //var deleted
                
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                
                SVProgressHUD.dismiss()
                break
                
            }
            
            
            
            
        }
    }
    /*
         
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    func imageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0);
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        context.clip(to: rect, mask: self.cgImage!)
        color1.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
