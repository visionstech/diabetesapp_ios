//
//  DoctorTabBarViewController.swift
//  DiabetesApp
//
//  Created by User on 1/21/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class DoctorTabBarViewController: UITabBarController {

    var currentLocale : String = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        
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
        tabBar.alpha = 0.7
        
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

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
