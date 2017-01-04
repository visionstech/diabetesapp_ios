//
//  CarePlanMainViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit

class CarePlanMainViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var medicationBtn: UIButton!
    @IBOutlet weak var readingBtn: UIButton!
    @IBOutlet weak var medicationContainer: UIView!
    @IBOutlet weak var readingContainer: UIView!
    
    var addBtn = UIBarButtonItem()
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    // MARK: - View Load Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtn = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(AddBtn_Click))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       setNavBarUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        UserDefaults.standard.setValue("583d82f2d0e391263667c8d8", forKey: userDefaults.selectedPatientID)
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        //self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tabBarController?.navigationItem.title = "\("CARE_PLAN".localized)"
        self.title = "\("CARE_PLAN".localized)"
        self.navigationItem.leftBarButtonItem = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
       
        
        if selectedUserType == userType.doctor {
            self.navigationItem.rightBarButtonItem = addBtn
        }
        else{
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - IBAction Methods
    func AddBtn_Click(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
    }
    
    @IBAction func ViewModeButtons_Click(_ sender: UIButton) {
        
        if sender.backgroundColor == Colors.historyHeaderColor {
            return
        }
        else {
            
            if sender == medicationBtn {
                medicationBtn.setTitleColor(UIColor.white, for: .normal)
                readingBtn.setTitleColor(UIColor.gray, for: .normal)
                
                medicationBtn.backgroundColor = Colors.historyHeaderColor
                readingBtn.backgroundColor = UIColor.white
                
                medicationContainer.isHidden = false
                readingContainer.isHidden = true
                
                if selectedUserType == userType.doctor {
                    self.navigationItem.rightBarButtonItem = addBtn
                }
                else{
                    self.navigationItem.rightBarButtonItem = nil
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
                
            }
            else {
                
                readingBtn.setTitleColor(UIColor.white, for: .normal)
                medicationBtn.setTitleColor(UIColor.gray, for: .normal)
                
                readingBtn.backgroundColor = Colors.historyHeaderColor
                medicationBtn.backgroundColor = UIColor.white
                
                medicationContainer.isHidden = true
                readingContainer.isHidden = false
                
                self.navigationItem.rightBarButtonItem = nil
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
                
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