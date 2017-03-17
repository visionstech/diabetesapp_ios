//
//  HistoryMainViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 30/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class HistoryMainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var chartBtn: UIButton!
    @IBOutlet weak var listViewContainer: UIView!
    @IBOutlet weak var chartViewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var readingTypeSegmentControls: UISegmentedControl!
    
    let recipientTypes = UserDefaults.standard.stringArray(forKey: userDefaults.recipientTypesArray)
    let recipientIDs = UserDefaults.standard.stringArray(forKey: userDefaults.recipientIDArray)
    var resetSegment : Bool = false
    var topBackView:UIView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:Colors.PrimaryColor], for: .normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        segmentControl.setTitle("TODAY".localized, forSegmentAt: 0)
        segmentControl.setTitle("SEVEN_DAYS".localized, forSegmentAt: 1)
        segmentControl.setTitle("FOURTEEN_DAYS".localized, forSegmentAt: 2)
        segmentControl.setTitle("THIRTY_DAYS".localized, forSegmentAt: 3)
        segmentControl.layer.cornerRadius = kButtonRadius
        segmentControl.layer.borderColor = Colors.PrimaryColor.cgColor
        segmentControl.layer.borderWidth = 1
        segmentControl.layer.masksToBounds = true
        
        
        readingTypeSegmentControls.setTitle("List View".localized, forSegmentAt: 0)
        readingTypeSegmentControls.setTitle("Chart View".localized, forSegmentAt: 1)
        
        readingTypeSegmentControls.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:Colors.PrimaryColor], for: .normal)
        readingTypeSegmentControls.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        readingTypeSegmentControls.layer.cornerRadius = kButtonRadius
        readingTypeSegmentControls.layer.borderColor = Colors.PrimaryColor.cgColor
        readingTypeSegmentControls.layer.borderWidth = 1
        readingTypeSegmentControls.layer.masksToBounds = true
        
        UserDefaults.standard.setValue("All conditions", forKey: "currentHistoryCondition")
        UserDefaults.standard.synchronize()
        //listBtn.layer.cornerRadius = 13.61
        // listBtn.setTitle("List View".localized, for: .normal)
        // chartBtn.setTitle("Chart View".localized, for: .normal)
        // chartBtn.layer.cornerRadius = 13.61
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setNavBarUI()
        if(resetSegment)
        {
            resetSegment = false
            segmentControl.selectedSegmentIndex = 0
            readingTypeSegmentControls.selectedSegmentIndex = 0
            listViewContainer.isHidden = false
            chartViewContainer.isHidden = true
            UserDefaults.standard.setValue(String(0), forKey: userDefaults.selectedNoOfDays)
            UserDefaults.standard.synchronize()
        }
        else
        {
            segmentControl.selectedSegmentIndex = segmentControl.selectedSegmentIndex
            readingTypeSegmentControls.selectedSegmentIndex = readingTypeSegmentControls.selectedSegmentIndex
            UserDefaults.standard.setValue(getSelectedNoOfDays(), forKey: userDefaults.selectedNoOfDays)
            UserDefaults.standard.synchronize()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Top View
    func createCustomTopView() {
        
        
        var selectedPatientID : String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let typeUser : Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        
        var databaseToCheck = ""
        
        if(typeUser != userType.patient)
        {
            if(typeUser == userType.doctor){
                databaseToCheck = "Patient"
            }
            else if(typeUser == userType.educator && (recipientTypes?.contains("patient"))!)
            {
                databaseToCheck = "Patient"
            }
            else if(typeUser == userType.educator && (recipientTypes?.contains("doctor"))!)
            {
                databaseToCheck = "Doctor"
                selectedPatientID = (recipientIDs?[(recipientTypes?.index(of: "doctor"))!])!
                
            }
            
            getImage(userid: selectedPatientID, type: databaseToCheck) { (result) -> Void in
                if(result){
                }
                else
                {
                    //Add Alert code here
                    _ = AlertView(title: "Error", message: "No display image found for user",    cancelButtonTitle: "OK", otherButtonTitle: ["Cancel"], didClick: { (buttonIndex) in
                    })
                }
                
            }
        }
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            
            topBackView = UIView(frame: CGRect(x: self.view.frame.size.width - 90, y: 0, width: 85, height: 40))
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 45, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topbackArbic")
            topBackView.addSubview(backImg)
        
           // let userImgView: UIImageView = UIImageView(frame: CGRect(x: 0 , y: 3, width: 34, height: 34))
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
    
            
            
        }
        else
        {
            
            topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 40))
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 0, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topBackBtn")
            topBackView.addSubview(backImg)
    
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
        }
    }
    
    func getImage(userid: String, type: String, withCompletionHandler:@escaping (_ result:Bool) -> Void)  {
        
        Alamofire.request("http://54.212.229.198:3000/showImage?id="+userid+"&type="+type, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                print("Validation Successful")
                
                let finalresult = response.result.value as! NSDictionary
                if let JSON: NSDictionary = response.result.value as! NSDictionary?
                {
                    
                    
                    let imageName: String = JSON.value(forKey:"profileimage") as! String
                    
                    let imagePath = "http://54.212.229.198:3000/upload/" + imageName
                    let manager:SDWebImageManager = SDWebImageManager.shared()
                    
                    manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                          options: SDWebImageOptions.highPriority,
                                          progress: nil,
                                          completed: {[weak self] (image, error, cached, finished, url) in
                                            if (error == nil && (image != nil) && finished) {
                                              
                                                
                                                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 0 , y: 3, width: 34, height: 34))
                                                   
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = image
                                                    self?.topBackView.addSubview(userImgView)
                                                    
                                                    
                                                }
                                                else {
                                                    
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 50, y: 3, width: 34, height: 34))
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = image
                                                    self?.topBackView.addSubview(userImgView)
                                                    
                                                }
                                              
                                            }
                                            else{
                                                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 0 , y: 3, width: 34, height: 34))
                                                    
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = UIImage(named:"placeholder.png")
                                                    self?.topBackView.addSubview(userImgView)
                                                    
                                                    
                                                }
                                                else {
                                                    
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 50, y: 3, width: 34, height: 34))
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = UIImage(named:"placeholder.png")
                                                    self?.topBackView.addSubview(userImgView)
                                                    
                                                }
                                            }
                    })
                    print(imagePath)
                    withCompletionHandler(true)
                }
                
                break
            case .failure:
                withCompletionHandler(false)
                break
                
            }
            
        }
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
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        createCustomTopView()
        
        
    }
    
    func getSelectedNoOfDays() -> NSString {
        
        switch segmentControl.selectedSegmentIndex {
        case HistoryDays.days_today:
            return "0"
        case HistoryDays.days_7:
            return "6"
        case HistoryDays.days_14:
            return "13"
        case HistoryDays.days_30:
            return "29"
        default:
            return ""
        }
        
    }
    
    //MARK: - SegmentControl Methods
    @IBAction func SegmentControl_ValueChange(_ sender: Any) {
        UserDefaults.standard.setValue(getSelectedNoOfDays(), forKey: userDefaults.selectedNoOfDays)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.noOfDays), object: getSelectedNoOfDays())
    }
    
    @IBAction func ViewModeButtons_Click(_ sender: UISegmentedControl) {
        
        let currentCondition =  UserDefaults.standard.string(forKey: "currentHistoryCondition");
        let myDict = ["current": currentCondition]
        if sender.backgroundColor == Colors.DHTabBarGreen {
            return
        }
        else {
            
            if sender.selectedSegmentIndex == 0 {
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Histroy View", action:"list View Clicked" , label:"list View Clicked")
                
                // sender.selectedSegmentIndex.setTitleColor(UIColor.white, for: .normal)
                //chartBtn.setTitleColor(Colors.PrimaryColor, for: .normal)
                
                //listBtn.backgroundColor = Colors.DHTabBarGreen
                //chartBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = false
                chartViewContainer.isHidden = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: myDict)
                
            }
            else {
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Histroy View", action:"chart View Clicked" , label:"chart View Clicked")
                // chartBtn.setTitleColor(UIColor.white, for: .normal)
                // listBtn.setTitleColor(Colors.PrimaryColor, for: .normal)
                
                // chartBtn.backgroundColor = Colors.DHTabBarGreen
                // listBtn.backgroundColor = UIColor.white
                listViewContainer.isHidden = true
                chartViewContainer.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.chartHistoryView), object: myDict)
                
            }
        }
    }
    
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
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
