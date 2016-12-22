//
//  ContactListViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var patientList = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        getContactsList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Custom Methods
    func naviagteToChatScreen(dialog: QBChatDialog)  {
        
        if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }
        
        let viewController: ChatViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        viewController.dialog = dialog
        self.navigationController?.pushViewController(viewController, animated: true)
        
        //self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    //MARK:- Api Methods
    func getContactsList(){
        //583fd43ab44e8fdb20145c06
        //http://192.168.25.43:3000/getpatients?doctorId=581fa527068eb45d1c916a38
        print(UserDefaults.standard.string(forKey:userDefaults.loggedInUserID ))
        let userID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatients)?doctorId=\(userID)").responseJSON { (response) in
            if let JSON: NSArray = response.result.value as? NSArray {
                
                
                for data in JSON {
                    let dict: NSDictionary = data as! NSDictionary
                    let contactObj = ContactObj()
                    contactObj.patient_id = dict.value(forKey: "_id") as! String
                    contactObj.chatid = dict.value(forKey: "chatid") as! String
                    contactObj.full_name = dict.value(forKey: "fullname") as! String
                    contactObj.username = dict.value(forKey: "username") as! String
                    contactObj.isSelected = "0"
                    self.patientList.add(contactObj)
                }
                
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK:- View Load Methods
    @IBAction func Back_Click(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func Done_Click(_ sender: Any) {
        
        var selectesUsers = Array<String>()
        for obj in patientList {
            
            if (obj as AnyObject).isSelected == "1" {
                selectesUsers.append((obj as AnyObject).chatid as String)
            }
        }
        
        // No user selected
        if selectesUsers.count == 0 {
            
            _ = AlertView(title: "Error", message: "Select atleast one user.", cancelButtonTitle: "OK", otherButtonTitle: [""], didClick: { (buttonIndex) in
            })
            
        }
            
            // Private Chat
        else if selectesUsers.count == 1 {
            
            self.createChat(name: "", usersArray: selectesUsers, completion: { (response, chatDialog) in
                
                self.naviagteToChatScreen(dialog: chatDialog!)
            })
        }
            
            // Group Chat
        else {
            
            _ = AlertViewWithTextField(title: "SA_STR_ENTER_CHAT_NAME".localized, message: nil, showOver:self, didClickOk: { (text) -> Void in
                
                let chatName = text!.trimmingCharacters(in: CharacterSet.whitespaces)
                print(chatName)
                
                if chatName.isEmpty {
                    //chatName = self.nameForGroupChatWithUsers(users: users)
                }
                
                self.createChat(name: chatName, usersArray: selectesUsers, completion: { (response, chatDialog) in
                    self.naviagteToChatScreen(dialog: chatDialog!)
                })
                
            }) { () -> Void in
            }
        }
        
    }
    
    //MARK: - Quickblox Methods
    func createChat(name: String?, usersArray: [String], completion: @escaping ((_ response: QBResponse? , _ createdDialog: QBChatDialog?) -> Void) ){
        
        QBRequest.users(withLogins: usersArray , page: QBGeneralResponsePage.init(currentPage: 1, perPage: 10), successBlock: { (response, page, users) in
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
            
            if users?.count == 1 {
                // Creating private chat.
                ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: (users?.first!)!, completion: { (response, chatDialog) in
                    
                    completion(response, chatDialog)
                })
                
            } else {
                // Creating group chat.
                
                ServicesManager.instance().chatService.createGroupChatDialog(withName: "test", photo: nil, occupants: users!) { [weak self] (response, chatDialog) -> Void in
                    
                    guard response.error == nil else {
                        
                        SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                        return
                    }
                    
                    guard let unwrappedDialog = chatDialog else {
                        return
                    }
                    
                    completion(response, unwrappedDialog)
                    
                }
            }
            
            
        }) { (error) in
            
        }
        
    }
    
    
    //MARK:- TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj: ContactObj = patientList[indexPath.row] as! ContactObj
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        if obj.isSelected == "1" {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = obj.full_name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj: ContactObj = patientList[indexPath.row] as! ContactObj
        obj.isSelected = (obj.isSelected == "1" ? "0" : "1")
        patientList.replaceObject(at:indexPath.row , with: obj)
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialog = sender as? QBChatDialog
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
