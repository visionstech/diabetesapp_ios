//
//  DoctorTabBarViewController.swift
//  DiabetesApp
//
//  Created by User on 1/21/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class DoctorTabBarViewController: UITabBarController {

    var currentLocale : String = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
           self .getReadCount()
        setupTabBar()
        self.tabBar.items?.first?.badgeValue = tabCounter
        if(Int(tabCounter)==0)
        {
            self.tabBar.items?.first?.badgeValue = nil
        }
          currentLocale = NSLocale.current.languageCode!
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setupTabBar() {
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
            
            
            //if let selectedImage = getTabBarSelectedImage(ForIndex: index) {
             //   tabBarItem.selectedImage = selectedImage.withRenderingMode(.alwaysOriginal)
            //}
            
        }
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
                        
                        self.tabBar.items?.first?.badgeValue = result_string
                        if(Int(tabCounter)==0)
                        {
                            self.tabBar.items?.first?.badgeValue = nil
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
