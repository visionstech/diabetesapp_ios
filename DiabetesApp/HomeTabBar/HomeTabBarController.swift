//
//  HomeTabBarController.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class HomeTabBarController: UITabBarController {

    var currentLocale : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        
        currentLocale = NSLocale.current.languageCode!
        setupTabbar()
       
        // Do any additional setup after loading the view.
    }
    
    private func setupTabbar() {
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
