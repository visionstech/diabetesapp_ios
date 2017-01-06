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
    
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedUserType == userType.doctor {
            
            getDoctorPatients()
            getDoctorEducators()
        }
        else if selectedUserType == userType.educator {
            
        }
        
        
        // Do any additional setup after loading the view.
        if isGroupMode == false || selectedUserType != userType.educator{
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
    
    func resetSelectedUsers(indexPath: IndexPath) {
        var count = 0
        var array: NSMutableArray = NSMutableArray()
        if indexPath.section == 0 {
            array = patientList
        }
        else {
            array = doctorList
        }
        
        for dict in array {
            let obj: ContactObj = dict as! ContactObj
            
            if count == indexPath.row {
                obj.isSelected = (obj.isSelected == "1" ? "0" : "1")
            }
            else {
                obj.isSelected = "0"
            }
            if indexPath.section == 0 {
                patientList.replaceObject(at:count , with: obj)
            }
            else {
                doctorList.replaceObject(at:count , with: obj)
            }
            
            count += 1
        }
    }
    
    
    // MARK: - Create Group for Doctor
    func createGroupForDoctor(selectedPatient:ContactObj) {
        
        var usersArray = Array<String>()
        if selectedPatient.chatid != "" {
            usersArray.append(selectedPatient.chatid)
        }
        
        for obj in educatorsList {
            let educatrObj: ContactObj = obj as! ContactObj
            if educatrObj.chatid != "" {
                usersArray.append(educatrObj.chatid)
            }
        }
        
        self.createChat(name: selectedPatient.full_name.trimmingCharacters(in: CharacterSet.whitespaces), usersArray: usersArray, isGroup: true, patientID: selectedPatient.patient_id, completion: { (response, chatDialog) in
            
            
            UserDefaults.standard.setValue(selectedPatient.patient_id, forKey: userDefaults.selectedPatientID)
            self.naviagteToChatScreen(dialog: chatDialog!)
        })
        
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
        var patientName: String = ""
        var patientid : String = ""
        
        // get selected Patient
        for obj in patientList {
            
            if (obj as AnyObject).isSelected == "1" {
                selectesUsers.append((obj as AnyObject).chatid as String)
                patientName = (obj as AnyObject).full_name.trimmingCharacters(in: CharacterSet.whitespaces)
                patientid = (obj as AnyObject).patient_id
                break
            }
        }
        
        // get selected Doctor
        for docObj in doctorList {
            
            if (docObj as AnyObject).isSelected == "1" {
                selectesUsers.append((docObj as AnyObject).chatid as String)
                break
            }
        }
        
        // No user selected
        if selectesUsers.count > 2 {
            
            _ = AlertView(title: "Error", message: "You need to select one patient and one doctor.", cancelButtonTitle: "OK", otherButtonTitle: [""], didClick: { (buttonIndex) in
            })
            return
        }
        
        self.createChat(name: patientName, usersArray: selectesUsers, isGroup: true, patientID: patientid, completion: { (response, chatDialog) in
            
            UserDefaults.standard.setValue(patientid, forKey: userDefaults.selectedPatientID)
            self.naviagteToChatScreen(dialog: chatDialog!)
        })
        
    }
    
    //MARK: - Quickblox Methods
    func createChat(name: String?, usersArray: [String], isGroup: Bool,patientID : String, completion: @escaping ((_ response: QBResponse? , _ createdDialog: QBChatDialog?) -> Void) ){
        
        QBRequest.users(withLogins: usersArray , page: QBGeneralResponsePage.init(currentPage: 1, perPage: 10), successBlock: { (response, page, users) in
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
            
            if isGroup == false {
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
                    
                    guard chatDialog != nil else {
                        return
                    }
                    chatDialog!.data = ["PatientID" : patientID ]
                    
                    QBRequest.update(chatDialog!, successBlock: { (response, updatedDialog) in
                        
                        guard updatedDialog != nil else {
                            return
                        }
                        print(updatedDialog!)
                        completion(response, updatedDialog)
                    }, errorBlock: { (error) in
                        
                    })
                    
                }
            }
            
            
        }) { (error) in
            
        }
    }
    
    
    //MARK:- TableView Delegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedUserType == userType.educator {
            return 2
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if selectedUserType == userType.educator {
            
            if section == 0 {
                return patientList.count
            }
            else {
                return doctorList.count
            }
        }
        else {
            return patientList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var obj = ContactObj()
        
        if selectedUserType == userType.educator {
            
            if indexPath.section == 0 {
                obj = patientList[indexPath.row] as! ContactObj
            }
            else {
                obj = doctorList[indexPath.row] as! ContactObj
            }
            
        }
        else {
            obj = patientList[indexPath.row] as! ContactObj
        }
        
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "patientCell", for: indexPath)
        if let userNameLbl: UILabel = cell.contentView.viewWithTag(1) as? UILabel {
            userNameLbl.text = obj.full_name
        }
        if isGroupMode == true {
            if obj.isSelected == "1" {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var obj: ContactObj = ContactObj()
        if selectedUserType == userType.educator {
            
            if indexPath.section == 0 {
                obj = patientList[indexPath.row] as! ContactObj
            }
            else {
                obj = doctorList[indexPath.row] as! ContactObj
            }
        }
        else {
            obj = patientList[indexPath.row] as! ContactObj
        }
        
        // group chat
        if isGroupMode == true {
            
            if selectedUserType == userType.educator {
                self.resetSelectedUsers(indexPath: indexPath)
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
        }
            // single chat
        else {
            
            // doctor
            if selectedUserType == userType.doctor {
                createGroupForDoctor(selectedPatient: obj)
            }
                
                //  educator
            else {
                
                var usersArray = Array<String>()
                if obj.chatid != "" {
                    usersArray.append(obj.chatid)
                }
                
                self.createChat(name: "", usersArray: usersArray, isGroup: false, patientID: obj.patient_id, completion: { (response, chatDialog) in
                    
                    UserDefaults.standard.setValue(obj.patient_id, forKey: userDefaults.selectedPatientID)
                    self.naviagteToChatScreen(dialog: chatDialog!)
                })
            }
            
        }
        
        //        UserDefaults.standard.setValue(obj.patient_id, forKey: userDefaults.selectedPatientID)
        //        if isGroupMode == true {
        //
        //            self.resetSelectedUsers(index: indexPath.row)
        //           // obj.isSelected = (obj.isSelected == "1" ? "0" : "1")
        //            //patientList.replaceObject(at:indexPath.row , with: obj)
        //            tableView.reloadData()
        //        }
        //
        //        else {
        //
        //            self.createChat(name: "", usersArray: [obj.chatid], completion: { (response, chatDialog) in
        //
        //                self.naviagteToChatScreen(dialog: chatDialog!)
        //            })
        //        }
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if selectedUserType == userType.educator {
            if section == 0 {
                return "Patients"
            }
            else {
                return "Doctors"
            }
        }
        else {
            return "Patients"
        }
        
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
