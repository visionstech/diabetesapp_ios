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

class LoginViewController: UIViewController, QBCoreDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var usernameTxtFld: UITextField!
    @IBOutlet weak var passwordTxtFld: UITextField!
    @IBOutlet weak var doctorBtn: UIButton!
    @IBOutlet weak var patientBtn: UIButton!
    
    //MARK: - var
    @IBOutlet weak var segmentUserType: UISegmentedControl!
    var selectedUserType: Int = 1
    
    
    //MARK: - View Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
       checkLoginStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        usernameTxtFld.text = ""
        passwordTxtFld.text = ""
        segmentUserType.selectedSegmentIndex = 0
        selectedUserType = 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Custom Methods
    func checkLoginStatus() {
        
        // If Already logged in
        if UserDefaults.standard.bool(forKey: userDefaults.isLoggedIn) == true {
            let login: String = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
            
            SVProgressHUD.show(withStatus: "Please wait...")
            if !QBChat.instance().isConnected {
                
                let selectedUser = QBUUser()
                selectedUser.email = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
                selectedUser.password = UserDefaults.standard.value(forKey: userDefaults.loggedInUserPassword) as! String!
                
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
                    
                }, errorBlock: { (error) in
                    
                    print("eeror \(error)")
                })
                
                
            }
        }
    }
    
    func navigateToNextScreen() {
        SVProgressHUD.dismiss()
        registerForRemoteNotification()
        
        let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.dialogsViewController) as! DialogsViewController
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: UIImage(named: "navigationImage.png")!)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 1 || UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 3 {
            self.navigationItem.hidesBackButton = false
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
            self.navigationController?.pushViewController(viewController, animated: true)
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
        if (sender as AnyObject).tag == selectedUserType {
            return
        }
        
        if (sender as AnyObject).tag == userType.doctor {
            doctorBtn.backgroundColor = Colors.userTypeSelectedColor
            patientBtn.backgroundColor = UIColor.lightGray
        }
            
        else {
            doctorBtn.backgroundColor = UIColor.lightGray
            patientBtn.backgroundColor = Colors.userTypeSelectedColor
        }
        selectedUserType = (sender as AnyObject).tag
        
    }
    
    @IBAction func LoginBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        let username = usernameTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = passwordTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)

        
        if username.isEmpty || password.isEmpty {
            self.present(UtilityClass.displayAlertMessage(message: "Username and password required.", title: "Error", viewController: self), animated: true, completion: nil)
            
        }
        else {
            if segmentUserType.selectedSegmentIndex == 0 {
               selectedUserType =  userType.doctor
            }
            else if segmentUserType.selectedSegmentIndex == 1 {
                
               selectedUserType =  userType.patient
            }
            else if segmentUserType.selectedSegmentIndex == 2 {
                selectedUserType = userType.educator
            }
            SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized, maskType: SVProgressHUDMaskType.clear)
            
            print("\(baseUrl)\(ApiMethods.login)?username=\(username)&password=\(password)&typeid=\(selectedUserType)")
            
                        let parameters: Parameters = [
                            "username": username,
                            "password": password,
                            "typeid" : selectedUserType
                        ]
            
                        Alamofire.request("\(baseUrl)\(ApiMethods.login)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                            print(response.result)
                            
                            
                            switch response.result {
                            case .success:
                                print("Validation Successful")
            
                                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                                    
                                    print("JSON: \(JSON)")
                                    let chatID: String = JSON.value(forKey:"chatid") as! String
                                    let email: String = JSON.value(forKey: "email") as! String!
                                    let id: String = JSON.value(forKey: "_id") as! String!
                                    // Quickblox SIgn Up
                                    if chatID.length == 0 {
                                        
                                        let newUser = QBUUser()
                                        newUser.email = email
                                        newUser.password = email
                                        newUser.login = email
                                        newUser.fullName = JSON.value(forKey: "fullname") as! String!
                                        newUser.website = "www.visions.com"
                                        newUser.tags = NSMutableArray(object: "visionsApp")
                                        
                                        QBRequest.signUp(newUser, successBlock: { (response, user) in
                                            
                                            let dictParam: Parameters = [
                                                "userid": JSON.value(forKey: "_id") as! String!,
                                                "chatid": username,
                                                "typeid" : self.selectedUserType
                                            ]
                                        Alamofire.request("\(baseUrl)\(ApiMethods.updatePatient)", method: .post, parameters: dictParam, encoding: JSONEncoding.default).response { response in
                                            // QuickBlox Login
                                            self.loginToQuickBlox(login: email, username: username, userID: id)
                                            
                                            }
//                                            
//                                            Alamofire.request("\(baseUrl)\(ApiMethods.updatePatient)?userid=\(email)&chatid=\(username)&typeid=\(self.selectedUserType)").responseJSON(completionHandler: { (response) in
//                                                
//                                                                                          })
                                            
                                        }, errorBlock: { (error) in
                                            print(error)
                                            SVProgressHUD.dismiss()
                                        })
                                    }
                                        
                                        // Quickblox Login
                                    else {
                                        self.loginToQuickBlox(login: email, username: username, userID: id)
                                    }
                                    
                                    
                                }
                                
                            case .failure(let error):
                                print(error)
                                SVProgressHUD.dismiss()
                            }
                        }
            
            
//            Alamofire.request("\(baseUrl)\(ApiMethods.login)?username=\(username)&password=\(password)&typeid=\(selectedUserType)").responseJSON { response in
//                
//                if response.result.debugDescription == "FAILURE" {
//                    
//                }
//                else {
//                
//                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
//                    
//                    print("JSON: \(JSON)")
////                    
//                    let selectedUser = QBUUser()
//                    selectedUser.email = JSON.value(forKey: "email") as! String!
//                    selectedUser.password = selectedUser.email 
//                    
//                    let login: String =  JSON.value(forKey: "email") as! String!
//                    QBRequest.user(withLogin: login, successBlock: { (response, user) in
//                        
//                        ServicesManager.instance().logIn(with: selectedUser, completion:{
//                            [unowned self] (success, errorMessage) -> Void in
//                            
//                            guard success else {
//                                SVProgressHUD.showError(withStatus: errorMessage)
//                                return
//                            }
//                            
//                            SVProgressHUD.dismiss()
//                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                            appDelegate.currentUser = user! as QBUUser
//                            // print(appDelegate.currentUser)
//                            
//                            let email: String = JSON.value(forKey: "email") as! String!
//                            let id: String = JSON.value(forKey: "_id") as! String!
//                            
//                            UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
//                            UserDefaults.standard.setValue(id , forKey: userDefaults.loggedInUserID)
//                            UserDefaults.standard.setValue(username, forKey: userDefaults.loggedInUsername)
//                            UserDefaults.standard.setValue(email, forKey: userDefaults.loggedInUserEmail)
//                            UserDefaults.standard.setValue(email, forKey: userDefaults.loggedInUserPassword)
//                             UserDefaults.standard.setValue(self.selectedUserType, forKey: userDefaults.loggedInUserType)
//                            UserDefaults.standard.synchronize()
//                            
//                            self.navigateToNextScreen()
//                        })
//                    
//                    }, errorBlock: { (error) in
//                        
//                        print("error \(error)")
//                        SVProgressHUD.showError(withStatus: error.data?.description)
//                    })
//                    
//                }
//              }
//            }
            
        }
        
    }
    
    func loginToQuickBlox(login: String, username: String, userID: String) {
        
        let selectedUser = QBUUser()
        selectedUser.email = login
        selectedUser.password = login
        
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
                UserDefaults.standard.setValue(self.selectedUserType, forKey: userDefaults.loggedInUserType)
                
                UserDefaults.standard.synchronize()
                
                self.navigateToNextScreen()
            })
            
        }, errorBlock: { (error) in
            
            print("error \(error.data?.description)")
            SVProgressHUD.showError(withStatus: error.data?.description)
        })
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
