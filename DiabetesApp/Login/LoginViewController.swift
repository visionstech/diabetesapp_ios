//
//  LoginViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire
import Quickblox
import SVProgressHUD

struct Account: KeychainGenericPasswordType {
    
    let accountName: String
    let token: String
    var data = [String: AnyObject]()
    let taskDate: String
    
    
    var dataToStore: [String: AnyObject] {
        
        return ["token": token as AnyObject, "taskDate": taskDate as AnyObject]
    }
    
    var accessToken: String? {
        
        return data["token"] as? String
    }
    
    var tDate: String? {
        
        return data["taskDate"] as? String
    }
    
    init(name: String, accessToken: String = "", tDate: String = "") {
        
        accountName = name
        token = accessToken
        taskDate = tDate
    }
}

class LoginViewController: UIViewController, QBCoreDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextFieldView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextFieldView: UIView!
    @IBOutlet weak var usernameTxtFld: UITextField!
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var passwordTxtFld: UITextField!

    //MARK: - var
    @IBOutlet weak var segmentUserType: UISegmentedControl!
    var selectedUserType: Int = 1
    var formInterval: GTInterval!
    //let token : String = ""
    
    //MARK: - View Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        usernameTxtFld.delegate = self
        passwordTxtFld.delegate = self
        
      //  let token = UserDefaults.standard.value(forKey: userDefaults.deviceToken) as! String!
       // print("Token in view did load")
        
        configureAppearance()
        checkLoginStatus()
        getMedicationArray()
        //saveToken()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kLoginScreenName)
        //--------Google Analytics Finish-----
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        usernameTxtFld.text = ""
        passwordTxtFld.text = ""
//        segmentUserType.selectedSegmentIndex = 0
        selectedUserType = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Methods
    
    private func configureAppearance() {
        navigationController?.isNavigationBarHidden = true
        showActivityIndicator(false)
        
        //Set title
        titleLabel.text = "Diabetes App"
        
        //Add gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        let color1 = Colors.DHBackgroundGreen.cgColor
        let color2 = Colors.DHBackgroundBlue.cgColor
        
        gradientLayer.colors = [color1, color2]
        
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        //Text Field
        usernameTxtFld.layer.cornerRadius = kButtonRadius
        passwordTxtFld.layer.cornerRadius = kButtonRadius
       /* usernameTxtFld.layer.borderWidth = 2.0
        usernameTxtFld.layer.borderColor = Colors.DHLoginButtonGreen.cgColor
        passwordTxtFld.layer.borderWidth = 2.0
        passwordTxtFld.layer.borderColor = Colors.DHLoginButtonGreen.cgColor*/
        
        usernameTxtFld.attributedPlaceholder = NSAttributedString(string: "ENTER_USERNAME".localized, attributes: [NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.5)])
        passwordTxtFld.attributedPlaceholder = NSAttributedString(string: "ENTER_PASSWORD".localized, attributes: [NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.5)])
        
        //Login Button
        loginButton.layer.cornerRadius = kButtonRadius
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.borderColor = Colors.DHLoginButtonGreen.cgColor
        loginButton.setTitle("LOGIN".localized, for: .normal)
        
        forgotPasswordButton.setTitle("Forgot Password?".localized, for: .normal)
        createAccountButton.setTitle("Create a new account".localized, for: .normal)
    }
    
    private func showActivityIndicator(_ show: Bool) {
        if show {
            activityIndicator.mySetActive(true)
            loginButton.setTitle("", for: .normal)
        }
        else {
            activityIndicator.mySetActive(false)
            loginButton.setTitle("LOGIN".localized, for: .normal)
        }
    }

    func checkLoginStatus() {
        
        // If Already logged in
        if UserDefaults.standard.bool(forKey: userDefaults.isLoggedIn) == true {
            let login: String = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
            
            //SVProgressHUD.show(withStatus: "Logging you in...".localized)
            if !QBChat.instance().isConnected {
                
                let selectedUser = QBUUser()
                selectedUser.email = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
                selectedUser.password = UserDefaults.standard.value(forKey: userDefaults.loggedInUserPassword) as! String!
                self .getReadCount()
                GoogleAnalyticManagerApi.sharedInstance.setuserId(userId: selectedUser.email!)
                GoogleAnalyticManagerApi.sharedInstance.setclientId(clientId: selectedUser.email!)
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Default Login", action:"Login" , label:"Login From Default credential")
                SVProgressHUD.show(withStatus: "Logging you in...".localized)
                
                QBRequest.user(withLogin: login, successBlock: { (response, user) in
                    
                    ServicesManager.instance().logIn(with: selectedUser, completion:{
                        [unowned self] (success, errorMessage) -> Void in
                        
                        SVProgressHUD.dismiss()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.currentUser = user! as QBUUser
                       
                        guard success else {
                            SVProgressHUD.showError(withStatus: errorMessage)
                            return
                        }
                        self.navigateToNextScreen()
                        
                        
                    })
                    
                }, errorBlock: { (error) in
                    
                    print("eeror \(error)")
                })
                
            }
                
            else {
                
                QBRequest.user(withLogin: login, successBlock: { (response, user) in
                    
                    SVProgressHUD.dismiss()
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.currentUser = user! as QBUUser
                    self.navigateToNextScreen()
                      self .getReadCount()
                    GoogleAnalyticManagerApi.sharedInstance.setuserId(userId: UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!)
                    GoogleAnalyticManagerApi.sharedInstance.setclientId(clientId: UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!)
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Default Login", action:"Login" , label:"Login From Default credential")
                }, errorBlock: { (error) in
                    
                    print("eeror \(error)")
                })
                
                
            }
        }
    }
    
    func navigateToNextScreen() {
        SVProgressHUD.dismiss()
        ServicesManager.instance().lastActivityDate = nil
        registerForRemoteNotification()
        
        
        ////  let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.dialogsViewController) as! DialogsViewController
        
        
       // self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: UIImage(named: "navigationImage.png")!)
        self.navigationController?.navigationBar.barTintColor = Colors.PrimaryColor
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 1 || UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 3 {
            self.navigationItem.hidesBackButton = false
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            // self.navigationController?.pushViewController(viewController, animated: true)
            
            
            let tabBarController: DoctorTabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.doctorTabBarViewController) as! DoctorTabBarViewController
            requestTabBarItem  =  (tabBarController.tabBar.items?[1])!
            self.navigationController?.pushViewController(tabBarController, animated: true)
            
        }
            
        else {
            // TabBar
            self.navigationItem.hidesBackButton = true
            let tabBarController: HomeTabBarController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.tabBarViewController) as! HomeTabBarController
            self.navigationController?.pushViewController(tabBarController, animated: true)
        }
        
    }    
    //MARK: - IBAction Methods
    @IBAction func SelectUserTypBtns_Click(_ sender: Any) {
//        if (sender as AnyObject).tag == selectedUserType {
//            return
//        }
//        
////        if (sender as AnyObject).tag == userType.doctor {
////            doctorBtn.backgroundColor = Colors.userTypeSelectedColor
////            patientBtn.backgroundColor = UIColor.lightGray
////        }
////            
////        else {
////            doctorBtn.backgroundColor = UIColor.lightGray
////            patientBtn.backgroundColor = Colors.userTypeSelectedColor
////        }
//        selectedUserType = (sender as AnyObject).tag
        
    }
    
    @IBAction func LoginBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let username = usernameTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "UI Action", action:"Login Button Clicked" , label:"Login with \(username)")
        
        
        if username.isEmpty || password.isEmpty {
//            self.present(UtilityClass.displayAlertMessage(message: "Username and password required.", title: "Error"), animated: true, completion: nil)
            self.present(UtilityClass.displayAlertMessage(message: "Username and password required".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
            
        }
        else {
//            if segmentUserType.selectedSegmentIndex == 0 {
//                selectedUserType =  userType.doctor
//            }
//            else if segmentUserType.selectedSegmentIndex == 1 {
//                
//                selectedUserType =  userType.patient
//            }
//            else if segmentUserType.selectedSegmentIndex == 2 {
//                selectedUserType = userType.educator
//            }
            SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized, maskType: SVProgressHUDMaskType.clear)

            var token : String = ""
            if let tokenTemp = UserDefaults.standard.value(forKey: userDefaults.deviceToken){
                token = tokenTemp as! String
            }
            //print("Token in login click")
            //print(token)
            let parameters: Parameters = [
                "username": username,
                "password": password,
//                "typeid" : selectedUserType
                "devicetoken" : "",
                "deviceType" : "iOS"
            ]
            
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            Alamofire.request("\(baseUrl)\(ApiMethods.login)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                print(response.result)
                
                self.formInterval.end()
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.login) Calling", action:"Login" , label:"Login With Button Click", value : self.formInterval.intervalAsSeconds())
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                        
                        if let val = JSON["result"] {
                            self.present(UtilityClass.displayAlertMessage(message: "Please check your credentials", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                            SVProgressHUD.dismiss()
                        }
                        else{
                                
                            
//                        print("JSON: \(JSON)")
                            let chatID: String = JSON.value(forKey:"chatid") as! String
                            let email: String = JSON.value(forKey: "email") as! String!
                            let id: String = JSON.value(forKey: "_id") as! String!
                            let type: String = JSON.value(forKey:"type") as! String!
                            let fullname: String = JSON.value(forKey:"fullname") as! String!
                            let token: String = JSON.value(forKey:"token") as! String!
                        
                            if type == "Doctor" {
                                self.selectedUserType =  userType.doctor
                            }
                            else if type == "Patient" {
                                self.selectedUserType =  userType.patient
                            }
                            else if type == "Educator" {
                                self.selectedUserType = userType.educator
                            }
                            // Still pending : Store JSONWebToken and NSDate for lastupdate in keyring
                            var account = Account(name: id)
                            var tDate = ""
                          
                            do {
                                try account.fetchFromKeychain()
                                
                                if let taskDate = account.tDate {
                                    tDate = taskDate
                                }
                            } catch {
                                tDate = ""
                                print(error)
                            }
                            
                            let newAccount = Account(name: id, accessToken: token, tDate : tDate)
                            
                            // save / update
                            do {
                                try newAccount.saveInKeychain()
                                print("> saved the account in the Keychain")
                            } catch {
                                print(error)
                            }
                            
                            // Quickblox SIgn Up
                            if chatID.length == 0 {
                            
                                let newUser = QBUUser()
                                newUser.email = email
                                newUser.password = email
                                newUser.login = email
                                newUser.fullName = JSON.value(forKey: "fullname") as! String!
                                newUser.website = "www.visions.com"
                                newUser.tags = NSMutableArray(object: "visionsApp")
                                
                                GoogleAnalyticManagerApi.sharedInstance.setuserId(userId: email)
                                GoogleAnalyticManagerApi.sharedInstance.setclientId(clientId: email)
                                
                                QBRequest.signUp(newUser, successBlock: { (response, user) in
                                
                                    let dictParam: Parameters = [
                                        "userid": JSON.value(forKey: "_id") as! String!,
                                        "chatid": email,
                                        "typeid" : self.selectedUserType
                                    ]
                                    Alamofire.request("\(baseUrl)\(ApiMethods.updatePatient)", method: .post, parameters: dictParam, encoding: JSONEncoding.default).response { response in
                                    // QuickBlox Login
                                        self.loginToQuickBlox(login: email, username: username, userID: id, fullname:fullname)
                                    
                                    }
                                //
                                //                                            Alamofire.request("\(baseUrl)\(ApiMethods.updatePatient)?userid=\(email)&chatid=\(username)&typeid=\(self.selectedUserType)").responseJSON(completionHandler: { (response) in
                                //
                                //                                                                                          })
                                
                                }, errorBlock: { (error) in
                                    print(error)
                                    self.present(UtilityClass.displayAlertMessage(message: "Login error related to quickblox".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                                    SVProgressHUD.dismiss()
                                })
                            }
                            
                            // Quickblox Login
                            else {
                                print("In here going to login now")
                                self.loginToQuickBlox(login: email, username: username, userID: id, fullname: fullname)
                            }
                        }
                    
                    }
                    
                case .failure(let error):
                    var strError = ""
                    if(error.localizedDescription.length>0)
                    {
                        strError = error.localizedDescription
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.login) Calling", action:"Login - Fail" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                    SVProgressHUD.dismiss()
                }
            }
        }
        
    }
    
    func loginToQuickBlox(login: String, username: String, userID: String, fullname: String) {
        
        let selectedUser = QBUUser()
        selectedUser.email = login
        selectedUser.password = login
        if selectedUser.customData == nil {
            selectedUser.customData = userID
        }
        
        
        QBRequest.user(withLogin: login, successBlock: { (response, user) in
            
            ServicesManager.instance().logIn(with: selectedUser, completion:{
                [unowned self] (success, errorMessage) -> Void in
                
                guard success else {
                    SVProgressHUD.showError(withStatus: errorMessage)
                    return
                }
                
                SVProgressHUD.dismiss()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.currentUser = user! as QBUUser
                // print(appDelegate.currentUser)
                
                UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
                UserDefaults.standard.setValue(userID , forKey: userDefaults.loggedInUserID)
                UserDefaults.standard.setValue(username, forKey: userDefaults.loggedInUsername)
                UserDefaults.standard.setValue(login, forKey: userDefaults.loggedInUserEmail)
                UserDefaults.standard.setValue(login, forKey: userDefaults.loggedInUserPassword)
                UserDefaults.standard.setValue(fullname, forKey: userDefaults.loggedInUserFullname)
                UserDefaults.standard.setValue(self.selectedUserType, forKey: userDefaults.loggedInUserType)
                if self.selectedUserType == userType.patient {
                     UserDefaults.standard.setValue(userID, forKey: userDefaults.selectedPatientID)
                }
               
                 let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
               
                  UserDefaults.standard.synchronize()
                
                
                
                
                self.navigateToNextScreen()
            })
            
        }, errorBlock: { (error) in
            
            
            self.present(UtilityClass.displayAlertMessage(message: "Login Error".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
            print("error \(error.data?.description)")
           GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QuickBlox Calling", action:"Fail - login To QuickBlox" , label:String(describing: error.data?.description), value : self.formInterval.intervalAsSeconds())
            SVProgressHUD.showError(withStatus: error.data?.description)
        })
    }
    
    
    func getTaskDate() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        var account = Account(name: patientsID)
        var tDate = ""
        var tokenVal = ""
        do {
            
            try account.fetchFromKeychain()
            
            if let token = account.accessToken {
                tokenVal = token
            }
            
            if let taskDate = account.tDate {
                tDate = taskDate
            }
            
        } catch {
            tDate = ""
            print(error)
        }
        
        Alamofire.request("http://54.212.229.198:3000/getTasks?maxdate="+tDate, method: .post, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    print (JSON)
                    let maxDate: String = JSON.value(forKey:"maxDate") as! String
                    let newAccount = Account(name: patientsID, accessToken: tokenVal, tDate : maxDate)
                    
                    // save / update
                    do {
                        try newAccount.saveInKeychain()
                        print("> saved the account in the Keychain")
                        
                    } catch {
                        
                        print(error)
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
    
    
    //MARK: - TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTxtFld {
            passwordTxtFld.becomeFirstResponder()
        }
        return true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
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
                        tabCounter = result_string
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
    func getMedicationArray() {
        
        Alamofire.request("http://54.244.176.114:3000/medicationArray", method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    print (JSON)
                    if let medicationList: NSArray = JSON.value(forKey:"medicationArray") as? NSArray {
                        //                    self.array = NSMutableArray()
                        dictMedicationName.removeAll()
                        dictMedicationList = NSMutableArray()
                        for data in medicationList {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = medicationObj()
                            obj.medicineName = dict.value(forKey: "medicineName") as! String
                            obj.medicineImage = dict.value(forKey: "medicineImage") as! String
                            obj.type = dict.value(forKey: "type") as! String
                            dictMedicationList.add(obj)
                            dictMedicationName.append(dict.value(forKey: "medicineName") as! String)
                        }
                    }
                    //                    dictMedicationImage = JSON.value(forKey:"medicationImageArray") as! [String]
                    //                    dictMedicationList = JSON.value(forKey:"medicationNameArray") as! [String]
                }
                break
            case .failure:
                print("failure")
                SVProgressHUD.dismiss()
                break
            }
        }
    }
    
    func registerForRemoteNotification() {
        // Register for push in iOS 8
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
        else {
            // Register for push in iOS 7
            UIApplication.shared.registerForRemoteNotifications(matching: [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert])
        }
    }
    
    
}
