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

class LoginViewController: UIViewController {
    
    struct userType {
        static let doctor = 1
        static let patient = 0
    }

    
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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SelectUserTypBtns_Click(_ sender: Any) {
        if (sender as AnyObject).tag == selectedUserType {
            return
        }
        
        if (sender as AnyObject).tag == userType.doctor {
            doctorBtn.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
            patientBtn.backgroundColor = UIColor.lightGray
        }
            
        else {
            doctorBtn.backgroundColor = UIColor.lightGray
            patientBtn.backgroundColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
        }
        selectedUserType = (sender as AnyObject).tag
        
    }
    
    
    @IBAction func LoginBtn_Click(_ sender: Any) {
        
        self.view.endEditing(true)
        
        if usernameTxtFld.text != "" && passwordTxtFld.text != "" {
            
            Alamofire.request("http://192.168.25.43:3000/getdataios?username=bhishamtrehan&password=bhishamtrehan&typeid=1").responseJSON { response in
               
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    
//                    QBUUser *selectedUser = [QBUUser user];
//                    selectedUser.email = @"bhishamtrehan@gmsil.com";
//                    selectedUser.password = @"bhishamtrehan@gmsil.com";
                    
                    let selectedUser = QBUUser()
                    selectedUser.email = "bhishamtrehan@gmsil.com"
                    selectedUser.password = "bhishamtrehan@gmsil.com"
                    
                    SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localizedLowercase + selectedUser.email!, maskType: SVProgressHUDMaskType.clear)
                    
                    // Logging to Quickblox REST API and chat.
                    ServicesManager.instance().logIn(with: selectedUser, completion:{
                        [unowned self] (success, errorMessage) -> Void in
                        
                        SVProgressHUD.dismiss()
                        
                        guard success else {
                            SVProgressHUD.showError(withStatus: errorMessage)
                            return
                        }
                        
                        print(selectedUser) ;
                        
                        let viewController: DialogsViewController = self.storyboard?.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
                        
                        if self.selectedUserType == userType.doctor {
                            
                            self.navigationController?.pushViewController(viewController, animated: true)
                        }
                            
                        else {
                            
                            // TabBar
                            let tabBarController: HomeTabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarView") as! HomeTabBarController
                            self.navigationController?.pushViewController(tabBarController, animated: true)
                        }
                        
                        
                        //self.registerForRemoteNotification()
                        //self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                        //SVProgressHUD.showSuccess(withStatus: "SA_STR_LOGGED_IN".localized)
                        
                    })
                    
                }
            }
            
//            Alamofire.request(.GET, url, parameters: dict as? [String : AnyObject]).responseJSON(completionHandler: { (response) in
//                
//                print("response \(response)")
//            })
            
            //            let viewController: RecentChatsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RecentChatsView") as! RecentChatsViewController
            //
            //            if selectedUserType == userType.doctor {
            //
            //                self.navigationController?.pushViewController(viewController, animated: true)
            //            }
            //
            //            else {
            //
            //                // TabBar
            //                let tabBarController: HomeTabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarView") as! HomeTabBarController
            //                self.navigationController?.pushViewController(tabBarController, animated: true)
            //            }
            
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
