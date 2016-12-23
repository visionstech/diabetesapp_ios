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
    var selectedUserType: Int = 1
    
    
    //MARK: - View Load Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLoginStatus()
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
                
//                let selectedUser = QBUUser()
//                selectedUser.email = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
//                selectedUser.password = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
                
                
                QBRequest.user(withLogin: login, successBlock: { (response, user) in
                    
                    ServicesManager.instance().logIn(with: user!, completion:{
                        [unowned self] (success, errorMessage) -> Void in
                        
                        SVProgressHUD.dismiss()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.currentUser = user! as QBUUser
                       // print(appDelegate.currentUser)
                        
                        UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
                        
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
        
        let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.dialogsViewController) as! DialogsViewController
        
        self.navigationController?.pushViewController(viewController, animated: true)
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
        
//        let username = "bhishamtrehan"//usernameTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
//        let password = "bhishamtrehan"//passwordTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        let username = "bhisham"//usernameTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        let password = "baljitpassword"//passwordTxtFld.text!.trimmingCharacters(in: CharacterSet.whitespaces)

        
        if username.isEmpty || password.isEmpty {
            self.present(UtilityClass.displayAlertMessage(message: "Username and password required.", title: "Error", viewController: self), animated: true, completion: nil)
            
            
        }
        else {
            SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized, maskType: SVProgressHUDMaskType.clear)
            
            //http://192.168.25.43:3000/getdataios?username=bhishamtrehan&password=bhishamtrehan&typeid=1
            Alamofire.request("\(baseUrl)\(ApiMethods.login)?username=\(username)&password=\(password)&typeid=2").responseJSON { response in
                
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    
                    print("JSON: \(JSON)")
//                    
                    let selectedUser = QBUUser()
                    selectedUser.email = JSON.value(forKey: "email") as! String!
                    selectedUser.password = selectedUser.email 
                    
                    let login: String =  JSON.value(forKey: "email") as! String!
                    QBRequest.user(withLogin: login, successBlock: { (response, user) in
                        
                        ServicesManager.instance().logIn(with: selectedUser, completion:{
                            [unowned self] (success, errorMessage) -> Void in
                            
                            SVProgressHUD.dismiss()
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.currentUser = user! as QBUUser
                            // print(appDelegate.currentUser)
                            
                            UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
                            
                            SVProgressHUD.dismiss()
                            
                            let email: String = JSON.value(forKey: "email") as! String!
                            let id: String = JSON.value(forKey: "_id") as! String!
                            
                            UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
                            UserDefaults.standard.setValue(id , forKey: userDefaults.loggedInUserID)
                            UserDefaults.standard.setValue(username, forKey: userDefaults.loggedInUsername)
                            UserDefaults.standard.setValue(email, forKey: userDefaults.loggedInUserEmail)
                            UserDefaults.standard.setValue(password, forKey: userDefaults.loggedInUserPassword)
                            UserDefaults.standard.synchronize()
                            
                            
                            let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.dialogsViewController) as! DialogsViewController
                            
                            if self.selectedUserType == userType.doctor {
                                
                                self.navigationController?.pushViewController(viewController, animated: true)
                            }
                                
                            else {
                                
                                // TabBar
                                let tabBarController: HomeTabBarController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.tabBarViewController) as! HomeTabBarController
                                self.navigationController?.pushViewController(tabBarController, animated: true)
                            }
                            
                            
                            guard success else {
                                SVProgressHUD.showError(withStatus: errorMessage)
                                return
                            }
                            self.navigateToNextScreen()
                        })
                    
                    
                    // Logging to Quickblox REST API and chat.
//                    ServicesManager.instance().logIn(with: selectedUser, completion:{
//                        [unowned self] (success, errorMessage) -> Void in
//                        
//                        guard success else {
//                            SVProgressHUD.showError(withStatus: errorMessage)
//                            return
//                        }
//                        
//                        SVProgressHUD.dismiss()
//                        
//                        let email: String = JSON.value(forKey: "email") as! String!
//                        let id: String = JSON.value(forKey: "_id") as! String!
//                        
//                        UserDefaults.standard.set(true, forKey: userDefaults.isLoggedIn)
//                        UserDefaults.standard.setValue(id , forKey: userDefaults.loggedInUserID)
//                        UserDefaults.standard.setValue(username, forKey: userDefaults.loggedInUsername)
//                        UserDefaults.standard.setValue(email, forKey: userDefaults.loggedInUserEmail)
//                        UserDefaults.standard.setValue(password, forKey: userDefaults.loggedInUserPassword)
//                        UserDefaults.standard.synchronize()
//                        
//                        
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                        appDelegate.currentUser = selectedUser as QBUUser
//                        
//                        let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.dialogsViewController) as! DialogsViewController
//                        
//                        if self.selectedUserType == userType.doctor {
//                            
//                            self.navigationController?.pushViewController(viewController, animated: true)
//                        }
//                            
//                        else {
//                            
//                            // TabBar
//                            let tabBarController: HomeTabBarController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.tabBarViewController) as! HomeTabBarController
//                            self.navigationController?.pushViewController(tabBarController, animated: true)
//                        }
                   })
                    
                }
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
    
}
