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
    var doctorList = NSMutableArray()
    var educatorsList = NSMutableArray()
    
    
    var isGroupMode : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 1 {
            getDoctorPatients()
            getDoctorEducators()
        }
        else if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 2 {
            getPatientDoctors()
            getPatientEducators()
        }
        else if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 3 {
            //get
        }
        
        // Do any additional setup after loading the view.
        if isGroupMode == false {
            self.navigationItem.rightBarButtonItems = nil
        }
        //getContactsList()
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
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(viewController, animated: true)
        
        //self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    //MARK:- Api Methods
    func getContactsList(){
        //583fd43ab44e8fdb20145c06
        //http://192.168.25.43:3000/getpatients?doctorId=581fa527068eb45d1c916a38
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
                
                ServicesManager.instance().chatService.createGroupChatDialog(withName: name! , photo: nil, occupants: users!) { [weak self] (response, chatDialog) -> Void in
                    
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var obj = ContactObj()
        
        
          if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 1{
            if indexPath.section == 0 {
                if patientList.count != 0 {
                 obj = patientList[indexPath.row] as! ContactObj
                }
            }
            else {
                if educatorsList.count != 0 {
                 obj = educatorsList[indexPath.row] as! ContactObj
                }
            }
        }
          else {
            if indexPath.section == 0 {
                if doctorList.count != 0 {
                    obj = doctorList[indexPath.row] as! ContactObj
                }
            }
            else {
                if educatorsList.count != 0 {
                    obj = educatorsList[indexPath.row] as! ContactObj
                }
            }
        }
        
       // let obj: ContactObj = patientList[indexPath.row] as! ContactObj
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        
        
        if isGroupMode == true {
            if obj.isSelected == "1" {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        
        cell.textLabel?.text = obj.full_name
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj: ContactObj = patientList[indexPath.row] as! ContactObj
        print(obj.patient_id)
        UserDefaults.standard.setValue(obj.patient_id, forKey: userDefaults.selectedPatientID)
        if isGroupMode == true {
           
            obj.isSelected = (obj.isSelected == "1" ? "0" : "1")
            patientList.replaceObject(at:indexPath.row , with: obj)
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.none)
        }
        
        else {
            
            self.createChat(name: "", usersArray: [obj.chatid], completion: { (response, chatDialog) in
                
                
                self.naviagteToChatScreen(dialog: chatDialog!)
            })
        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if UserDefaults.standard.value(forKey: userDefaults.loggedInUserType) as! NSNumber! == 1{
            if section == 0 {
                return "Patients"
            }
            else{
            return "Educators"
            }
        }
        else{
            if section == 0 {
                return "Doctors"
            }
            else{
                return "Educators"
            }        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialog = sender as? QBChatDialog
            }
        }
    }
    
    // MARK: - Api Integration
    func getPatientDoctors()  {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": patientsID
                    ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatDoctors)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let JSON: NSArray = response.result.value as? NSArray {
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let contactObj = ContactObj()
                        contactObj.patient_id = dict.value(forKey: "_id") as! String
                        contactObj.chatid = dict.value(forKey: "chatid") as! String
                        contactObj.full_name = dict.value(forKey: "fullname") as! String
                        contactObj.username = dict.value(forKey: "username") as! String
                        contactObj.isSelected = "0"
                        self.doctorList.add(contactObj)
                    }
                    self.tableView.reloadData()
                    
                }
            
            break
            case .failure:
                break
                
            }
            
        }
    }
    
    func getPatientEducators()  {
        let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": educatorID
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatEducators)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                
                if let JSON: NSArray = response.result.value as? NSArray {
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let contactObj = ContactObj()
                        contactObj.patient_id = dict.value(forKey: "_id") as! String
                        contactObj.chatid = dict.value(forKey: "chatid") as! String
                        contactObj.full_name = dict.value(forKey: "fullname") as! String
                        contactObj.username = dict.value(forKey: "username") as! String
                        contactObj.isSelected = "0"
                        self.educatorsList.add(contactObj)
                    }
                    self.tableView.reloadData()
                }
                
                break
            case .failure:
                break
                
            }
            
        }
    }
    
    func getDoctorPatients()  {
        let doctorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": doctorID
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getDocPatients)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
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
                break
            case .failure:
                break
                
            }
            
        }
    }
    
    func getDoctorEducators()  {
        let doctorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": doctorID
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getDocEducators)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let JSON: NSArray = response.result.value as? NSArray {
                for data in JSON {
                    let dict: NSDictionary = data as! NSDictionary
                    let contactObj = ContactObj()
                    contactObj.patient_id = dict.value(forKey: "_id") as! String
                    contactObj.chatid = dict.value(forKey: "chatid") as! String
                    contactObj.full_name = dict.value(forKey: "fullname") as! String
                    contactObj.username = dict.value(forKey: "username") as! String
                    contactObj.isSelected = "0"
                    self.educatorsList.add(contactObj)
                 }
                     self.tableView.reloadData()
                }
                
                break
            case .failure:
                break
                
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
