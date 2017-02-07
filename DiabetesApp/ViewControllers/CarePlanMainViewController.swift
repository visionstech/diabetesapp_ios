//
//  CarePlanMainViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class CarePlanMainViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var medicationBtn: UIButton!
    @IBOutlet weak var readingBtn: UIButton!
    @IBOutlet weak var medicationContainer: UIView!
    @IBOutlet weak var readingContainer: UIView!
    
    @IBOutlet weak var carePlanSegmentControl: UISegmentedControl!
    var addBtn = UIBarButtonItem()
    var topBackView:UIView = UIView()
    
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    let recipientTypes = UserDefaults.standard.stringArray(forKey: userDefaults.recipientTypesArray)
    let recipientIDs = UserDefaults.standard.stringArray(forKey: userDefaults.recipientIDArray)
    
    // MARK: - View Load Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtn = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(AddBtn_Click))
       // medicationBtn.setTitle("MEDICATION".localized, for: .normal)
        //readingBtn.setTitle("READINGS".localized, for: .normal)
        
        carePlanSegmentControl.setTitle("Medications".localized, forSegmentAt: 0)
        carePlanSegmentControl.setTitle("Readings".localized, forSegmentAt: 1)
        carePlanSegmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:Colors.PrimaryColor], for: .normal)
        carePlanSegmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        carePlanSegmentControl.layer.cornerRadius = kButtonRadius
        carePlanSegmentControl.layer.borderColor = Colors.PrimaryColor.cgColor
        carePlanSegmentControl.layer.borderWidth = 1
        carePlanSegmentControl.layer.masksToBounds = true
        
//        let pushMessage =  QBMPushMessage()
//        pushMessage.alertBody =  "qeqds"
//        //pushMessage.badge = 1
//        
//        QBRequest .sendPush(pushMessage, toUsers: String("22152133"), successBlock: { (response, event) in
//            
//        }, errorBlock: { (error) in
//            
//        })
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
       setNavBarUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        //self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        //self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.tabBarController?.navigationItem.title = "\("CARE_PLAN".localized)"
        self.title = "\("CARE_PLAN".localized)"
        self.navigationItem.leftBarButtonItem = nil
                
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        
        
        
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            if selectedUserType == userType.doctor {
               // self.navigationItem.leftBarButtonItem = addBtn
                self.navigationItem.leftBarButtonItem = nil
            }
            else{
                self.navigationItem.leftBarButtonItem = nil
            }
        }
        else {
            if selectedUserType == userType.doctor {
               self.navigationItem.rightBarButtonItem = nil
            }
            else{
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        createCustomTopView()
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
            topBackView = UIView(frame: CGRect(x: self.view.frame.size.width - 80, y: 0, width: 75, height: 40))
            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topbackArbic")!)
           // let userImgView: UIImageView = UIImageView(frame: CGRect(x: 5 , y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
            //topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
            
            
        }
        else {
            
            topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
          //  let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
           // userImgView.image = UIImage(named: "user.png")
           // topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
        }
        
        topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
        topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
        //        let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
        //        userImgView.image = UIImage(named: "user.png")
        //        topBackView.addSubview(userImgView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
        topBackView.addGestureRecognizer(tapGesture)
        topBackView.isUserInteractionEnabled = true
        
        self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
        self.navigationController?.navigationBar.addSubview(topBackView)
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
                                                // do something with image
                                                //                                                self?.imgLookView.image=image
                                                //                                                self?.topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
                                                //                                                self?.topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
                                                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                                                    
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 5 , y: 3, width: 34, height: 34))
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = image
                                                    self?.topBackView.addSubview(userImgView)
                                                    
                                                    
                                                }
                                                else {
                                                    
                                                    
                                                    let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
                                                   
                                                    userImgView.layer.cornerRadius = userImgView.frame.size.width / 2;
                                                    userImgView.clipsToBounds = true;
                                                    
                                                    userImgView.image = image
                                                    self?.topBackView.addSubview(userImgView)
                                                }
                                              
                                                
                                                //                                                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self?.BackBtn_Click))
                                                //                                                self?.topBackView.addGestureRecognizer(tapGesture)
                                                //                                                self?.topBackView.isUserInteractionEnabled = true
                                                //
                                                //                                                self?.navigationController?.navigationBar.addSubview((self?.topBackView)!)
                                                //                                                self?.tabBarController?.navigationController?.navigationBar.addSubview((self?.topBackView)!)
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

    
    // MARK: - IBAction Methods
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func AddBtn_Click(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
    }
    
    @IBAction func ViewModeButtons_Click(_ sender: UISegmentedControl) {
    
        if sender.backgroundColor == Colors.DHTabBarGreen {
            return
        }
        else {
            
            if sender.selectedSegmentIndex == 0 {
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Medication View Clicked" , label:"Medication View Clicked")
                
               // medicationBtn.setTitleColor(UIColor.white, for: .normal)
               // readingBtn.setTitleColor(UIColor.gray, for: .normal)
                
               // medicationBtn.backgroundColor = Colors.historyHeaderColor
               // readingBtn.backgroundColor = UIColor.white
                
                medicationContainer.isHidden = false
                readingContainer.isHidden = true
                
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    if selectedUserType == userType.doctor {
                       // self.navigationItem.leftBarButtonItem = addBtn
                        self.navigationItem.leftBarButtonItem = nil
                    }
                    else{
                        self.navigationItem.leftBarButtonItem = nil
                    }
                }
                else {
                    if selectedUserType == userType.doctor {
                        self.navigationItem.rightBarButtonItem = nil
                    }
                    else{
                        self.navigationItem.rightBarButtonItem = nil
                    }
                }
                
                //                if selectedUserType == userType.doctor {
                //                    self.navigationItem.rightBarButtonItem = addBtn
                //                }
                //                else{
                //                    self.navigationItem.rightBarButtonItem = nil
                //                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
                
            }
            else {
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Reading View Clicked" , label:"Reading View Clicked")
               // readingBtn.setTitleColor(UIColor.white, for: .normal)
               // medicationBtn.setTitleColor(UIColor.gray, for: .normal)
                
              //  readingBtn.backgroundColor = Colors.historyHeaderColor
               // medicationBtn.backgroundColor = UIColor.white
                
                medicationContainer.isHidden = true
                readingContainer.isHidden = false
                
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    self.navigationItem.leftBarButtonItem = nil
                }
                else {
                    self.navigationItem.rightBarButtonItem = nil
                }
                
                
                
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
