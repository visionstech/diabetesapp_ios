//
//  HistoryMainViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 30/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit

class HistoryMainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var chartBtn: UIButton!
    @IBOutlet weak var listViewContainer: UIView!
    @IBOutlet weak var chartViewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setNavBarUI()
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        self.title = "\("READING_HISTORY".localized)"
        self.tabBarController?.title = "\("READING_HISTORY".localized)"
        self.tabBarController?.navigationItem.title = "\("READING_HISTORY".localized)"
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
    }
    
    func getSelectedNoOfDays() -> NSString {
        
        switch segmentControl.selectedSegmentIndex {
        case HistoryDays.days_today:
            return "1"
        case HistoryDays.days_7:
            return "7"
        case HistoryDays.days_14:
            return "14"
        case HistoryDays.days_30:
            return "30"
        default:
            return ""
        }
        
    }
    
     //MARK: - SegmentControl Methods
    @IBAction func SegmentControl_ValueChange(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.noOfDays), object: getSelectedNoOfDays())
    }
    
    // MARK: - IBAction Methods
    @IBAction func ViewModeButtons_Click(_ sender: UIButton) {
        
        if sender.backgroundColor == Colors.historyHeaderColor {
            return
        }
        else {
            
            if sender == listBtn {
                listBtn.setTitleColor(UIColor.white, for: .normal)
                chartBtn.setTitleColor(UIColor.gray, for: .normal)
                
                listBtn.backgroundColor = Colors.historyHeaderColor
                chartBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = false
                chartViewContainer.isHidden = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: nil)
                
            }
            else {
                
                chartBtn.setTitleColor(UIColor.white, for: .normal)
                listBtn.setTitleColor(UIColor.gray, for: .normal)
                
                chartBtn.backgroundColor = Colors.historyHeaderColor
                listBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = true
                chartViewContainer.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: nil)
                
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