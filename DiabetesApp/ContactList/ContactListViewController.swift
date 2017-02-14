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
import Alamofire
import SDWebImage


class ContactListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var patientList = NSMutableArray()
    var doctorList = NSMutableArray()
    var educatorsList = NSMutableArray()
    var isGroupMode : Bool = false
    var formInterval: GTInterval!
    
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedUserType == userType.doctor {
            
            getDoctorPatients()
            //            getDoctorEducators()
        }
        else if selectedUserType == userType.educator {
            getEducatorDoctors()
            getEducatorPatients()
        }
        
        //self.navigationItem.title = "Contacts".localized
        // Do any additional setup after loading the view.
        self.tabBarController?.navigationItem.title = "Contacts".localized
        if isGroupMode == false || selectedUserType != userType.educator{
            self.navigationItem.rightBarButtonItems = nil
        }
        //getContactsList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kContactListScreenName)
        //--------Google Analytics Finish-----
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
        
        var recipientIDArray : [String] = []
        var recipientNameArray : [String] = []
        
        var patienthcNumber: String = ""
        
        var usersArray = Array<String>()
        if selectedPatient.chatid != "" {
            usersArray.append(selectedPatient.chatid)
            recipientIDArray.append(selectedPatient.patient_id)
            recipientNameArray.append(selectedPatient.full_name)
        }
        
        
        if(selectedPatient.HCNumber.isEmpty == false){
            patienthcNumber = selectedPatient.HCNumber
        }
        
        //In group chat; the doctor names goes second to maintain consistency. Because when a group is created; it'll be difficult to check who created the group when we are getting the doctor's name during patient chat
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        recipientNameArray.append(loggedInUserName)
        
        
        for obj in educatorsList {
            
            let educatrObj: ContactObj = obj as! ContactObj
            
            if educatrObj.chatid != "" {
                usersArray.append(educatrObj.chatid)
                recipientNameArray.append(educatrObj.full_name)
            }
        }
        let loggedInUserID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        
        recipientIDArray.append(loggedInUserID)
        
        
        self.createChat(name: selectedPatient.full_name.trimmingCharacters(in: CharacterSet.whitespaces), usersArray: usersArray, isGroup: true, patientID: selectedPatient.patient_id, HCNumber: patienthcNumber, recipientIDArray: recipientIDArray, recipientNames: recipientNameArray, completion: { (response, chatDialog) in
            
            UserDefaults.standard.setValue(selectedPatient.patient_id, forKey: userDefaults.selectedPatientID)
            self.naviagteToChatScreen(dialog: chatDialog!)
        })
        
    }
    
    //MARK:- Api Methods
    func getContactsList(){
        //583fd43ab44e8fdb20145c06
        //http://192.168.25.43:3000/getpatients?doctorId=581fa527068eb45d1c916a38
        let userID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatients)?doctorId=\(userID)").responseJSON { (response) in
            if let JSON: NSArray = response.result.value as? NSArray {
                self.formInterval.end()
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
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getPatients) Calling", action:"Success - Web API Calling" , label:"get Patients List", value : self.formInterval.intervalAsSeconds())
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
        var patienthcNumber : String = ""
        var doctorid : String = ""
        var recipientIDArray : [String] = []
        var recipientNameArray : [String] = []
        // get selected Patient
        
        
        for obj in patientList {
            
            if (obj as AnyObject).isSelected == "1" {
                
                
                selectesUsers.append((obj as AnyObject).chatid as String)
                patientName = (obj as AnyObject).full_name.trimmingCharacters(in: CharacterSet.whitespaces)
                patientid = (obj as AnyObject).patient_id
                patienthcNumber = (obj as AnyObject).HCNumber
                recipientIDArray.append((obj as AnyObject).patient_id as String)
                recipientNameArray.append((obj as AnyObject).full_name as String)
                // recipientIDArray.add(patientid)
                break
            }
        }
        
        
        // get selected Doctor
        for docObj in doctorList {
            
            if (docObj as AnyObject).isSelected == "1" {
                
                doctorid = (docObj as AnyObject).patient_id
                selectesUsers.append((docObj as AnyObject).chatid as String)
                recipientIDArray.append((docObj as AnyObject).patient_id as String)
                recipientNameArray.append((docObj as AnyObject).full_name as String)
                break
            }
        }
        
        // No user selected
        if selectesUsers.count < 2 {
            GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Error", action:"Create Group For Doctor" , label:"You need to select one patient and one doctor")
            
            _ = AlertView(title: "SA_STR_ERROR".localized, message: "You need to select one patient and one doctor".localized, cancelButtonTitle: "SA_STR_OK".localized, otherButtonTitle: [""], didClick: { (buttonIndex) in
            })
            return
        }
        
        //The last index will be the name of the logged in user
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        recipientNameArray.append(loggedInUserName)
        
        self.createChat(name: patientName, usersArray: selectesUsers, isGroup: true, patientID: patientid, HCNumber: patienthcNumber, recipientIDArray: recipientIDArray, recipientNames: recipientNameArray, completion: { (response, chatDialog) in
            //            print("Now creating")
            UserDefaults.standard.setValue(patientid, forKey: userDefaults.selectedPatientID)
            self.naviagteToChatScreen(dialog: chatDialog!)
        })
        
    }
    
    //MARK: - Quickblox Methods
    func createChat(name: String?, usersArray: [String], isGroup: Bool,patientID : String, HCNumber: String, recipientIDArray: [String], recipientNames: [String], completion: @escaping ((_ response: QBResponse? , _ createdDialog: QBChatDialog?) -> Void) ){
        
        
        
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Chat", action:"Create Chat" , label:"Create Chat \(name)")
        
        print("name array:")
        print(recipientNames)
        
        QBRequest.users(withLogins: usersArray , page: QBGeneralResponsePage.init(currentPage: 1, perPage: 10), successBlock: { (response, page, users) in
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
            
            if isGroup == false {
                // Creating private chat.
                var tempArray : [String] = []
                
                ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: (users?.first!)!, completion: { (response, chatDialog) in
                    let object = QBCOCustomObject()
                    object.className = "Patient"
                    object.fields?.setObject(patientID, forKey: "patient_id" as NSCopying)
                    object.fields?.setObject(chatDialog?.id as Any, forKey: "chat_id" as NSCopying)
                    object.fields?.setObject(HCNumber, forKey: "HCNumber" as NSCopying)
                    
                    print("Doctor count")
                    print(self.doctorList.count)
                    if(self.doctorList.count>0)
                    {
                        
                        tempArray = ["doctor"]
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    else if(self.educatorsList.count>0)
                    {
                        tempArray = ["educator"]
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    else if(self.patientList.count>0)
                    {
                        tempArray = ["patient"]
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    
                    object.fields?.setObject(recipientNames, forKey: "recipientNames" as NSCopying)
                    
                    QBRequest.createObject(object, successBlock: nil, errorBlock: nil)
                    let updateDialog = chatDialog?.copy() as! QBChatDialog
                    updateDialog.data = ["PatientID" : patientID, "HCNumber":HCNumber]
                    
                    UserDefaults.standard.setValue(HCNumber, forKey: userDefaults.selectedPatientHCNumber)
                    
                    
                    UserDefaults.standard.set(tempArray, forKey: userDefaults.recipientTypesArray)
                    UserDefaults.standard.set(recipientIDArray, forKey: userDefaults.recipientIDArray)
                    
                    
                    
                    
                    
                    QBRequest.update(chatDialog!, successBlock: { (response, updatedDialog) in
                        
                        guard updatedDialog != nil else {
                            return
                        }
                        completion(response, updatedDialog)
                    }, errorBlock: { (error) in
                        print("Error")
                    })
                    completion(response, chatDialog)
                })
                
            } else {
                // Creating group chat.
                
                
                
                //  ServicesManager.instance().chatService.createGroupChatDialog(withName: name! , photo: nil, occupants: users!) { [weak self] (response, chatDialog) -> Void in
                ServicesManager.instance().chatService.createGroupChatDialog(withName: name! , photo: patientID, occupants: users!) { [weak self] (response, chatDialog) -> Void in
                    
                    // storing custom parameters in quickblox
                    
                    
                    guard response.error == nil else {
                        
                        SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                        return
                    }
                    
                    
                    
                    guard chatDialog != nil else {
                        return
                    }
                    var tempArray: [String] = []
                    
                    let object = QBCOCustomObject()
                    object.className = "Patient"
                    object.fields?.setObject(patientID, forKey: "patient_id" as NSCopying)
                    object.fields?.setObject(chatDialog?.id as Any, forKey: "chat_id" as NSCopying)
                    object.fields?.setObject(HCNumber, forKey: "HCNumber" as NSCopying)
                    
                    if((self?.doctorList.count)! > 0 && (self?.educatorsList.count)! > 0)
                    {
                        tempArray = ["doctor", "educator"]
                        
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    else if((self?.doctorList.count)! > 0 && (self?.patientList.count)! > 0)
                    {
                        tempArray = ["patient", "doctor"]
                        
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    else if((self?.educatorsList.count)! > 0 && (self?.patientList.count)! > 0)
                    {
                        tempArray = ["patient", "doctor"]
                        
                        object.fields?.setObject(tempArray, forKey: "recipientTypes" as NSCopying)
                        object.fields?.setObject(recipientIDArray, forKey: "recipientIDs" as NSCopying)
                    }
                    
                    
                    object.fields?.setObject(recipientNames, forKey: "recipientNames" as NSCopying)
                    UserDefaults.standard.set(tempArray, forKey: userDefaults.recipientTypesArray)
                    UserDefaults.standard.set(recipientIDArray, forKey: userDefaults.recipientIDArray)
                    
                    
                    QBRequest.createObject(object, successBlock: nil, errorBlock: nil)
                    let updateDialog = chatDialog?.copy() as! QBChatDialog
                    updateDialog.data = ["PatientID" : patientID, "HCNumber":HCNumber]
                    
                    
                    UserDefaults.standard.setValue(HCNumber, forKey: userDefaults.selectedPatientHCNumber)
                    
                    QBRequest.update(chatDialog!, successBlock: { (response, updatedDialog) in
                        
                        guard updatedDialog != nil else {
                            return
                        }
                        completion(response, updatedDialog)
                    }, errorBlock: { (error) in
                        print("Error")
                    })
                    
                }
            }
            
            
        }) { (error) in
            print("Error1")
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
        // print("Done 3")
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
        // print("Done 2")
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
            
            let selectedPatientID : String = obj.patient_id
            let imagePath = "http://54.212.229.198:3000/upload/" + selectedPatientID + "image.jpg"
            let manager:SDWebImageManager = SDWebImageManager.shared()
            
            //cell.dialogTypeImage.image =   UIImage(named:"user.png")!
            manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                  options: SDWebImageOptions.highPriority,
                                  progress: nil,
                                  completed: {[weak self] (image, error, cached, finished, url) in
                                    if (error == nil && (image != nil) && finished) {
                                        print("Got the image")
                                        if let userNameImg: UIImageView = cell.contentView.viewWithTag(2) as? UIImageView {
                                            //let userNameImg: UIImageView = (cell.contentView.viewWithTag(2) as? UIImageView)!
                                            print("Setting up")
                                            userNameImg.layer.cornerRadius =
                                                userNameImg.frame.size.width/2
                                            
                                            userNameImg.clipsToBounds = true
                                            
                                            userNameImg.image = image
                                        }
                                        
                                    }
            })
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
        
        //print("Done 1")
        var obj: ContactObj = ContactObj()
        var patienthcNumber: String = ""
        
        var recipientIDArray : [String] = []
        var recipientNameArray : [String] = []
        
        if selectedUserType == userType.educator {
            
            if indexPath.section == 0 {
                obj = patientList[indexPath.row] as! ContactObj
                recipientNameArray.append(obj.full_name)
            }
            else {
                
                obj = doctorList[indexPath.row] as! ContactObj
                recipientNameArray.append(obj.full_name)
            }
        }
        else {
            
            obj = patientList[indexPath.row] as! ContactObj
            recipientNameArray.append(obj.full_name)
        }
        
        // group chat
        if isGroupMode == true {
            
            if selectedUserType == userType.educator {
                self.resetSelectedUsers(indexPath: indexPath)
                tableView .reloadData()
            }
            
        }
            // single chat
        else {
            
            // doctor
            
            if selectedUserType == userType.doctor
            {
                getPatientEducators(patientID: obj.patient_id) { (result) -> Void in
                    if(result){
                        self.createGroupForDoctor(selectedPatient: obj)
                    }
                    else
                    {
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Error", action:"Create Group For Doctor" , label:"there are no educators associated to this patient.")
                        
                        //Add Alert code here
                        _ = AlertView(title: "Error", message: "there are no educators associated to this patient.", cancelButtonTitle: "OK", otherButtonTitle: [""], didClick: { (buttonIndex) in
                        })
                    }
                    
                }
                
            }
                //  educator
            else {
                var usersArray = Array<String>()
                if obj.chatid != "" {
                    usersArray.append(obj.chatid)
                    
                    recipientIDArray.append(obj.patient_id)
                    if(obj.HCNumber.isEmpty == false){
                        patienthcNumber = obj.HCNumber
                    }
                    
                }
                
                //The last index will be the name of the logged in user
                let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                recipientNameArray.append(loggedInUserName)
                
                self.createChat(name:  obj.full_name, usersArray: usersArray, isGroup: false, patientID: obj.patient_id, HCNumber: patienthcNumber, recipientIDArray: recipientIDArray, recipientNames: recipientNameArray, completion: { (response, chatDialog) in
                    
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
        //print("Done 4")
        if selectedUserType == userType.educator {
            if section == 0 {
                return "Patients".localized
            }
            else {
                return "Doctors".localized
            }
        }
        else {
            return "Patients".localized
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
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatDoctors)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
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
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getPatDoctors) Calling", action:"Success - Web API Calling" , label:"get Patient Doctors List", value : self.formInterval.intervalAsSeconds())
                    
                }
                
                break
            case .failure(let error):
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getPatDoctors) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                break
                
                
            }
            
        }
    }
    
    func getPatientEducators(patientID: String, withCompletionHandler:@escaping (_ result:Bool) -> Void)  {
        
        let parameters: Parameters = [
            "id": patientID
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getPatEducators)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
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
                    print("Printing list in educators")
                    print(self.educatorsList)
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getPatEducators) Calling", action:"Success - Web API Calling" , label:"get Patient Educators List", value : self.formInterval.intervalAsSeconds())
                    //                    self.tableView.reloadData()
                    withCompletionHandler(true)
                    
                }
                break
            case .failure(let error):
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getPatEducators) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                withCompletionHandler(false)
                break
                
            }
            
        }
    }
    
    func getDoctorPatients()  {
        let doctorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": doctorID
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getDocPatients)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            switch response.result {
            case .success:
                print("Validation Successful in doctor patients")
                if let JSON: NSArray = response.result.value as? NSArray {
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let contactObj = ContactObj()
                        contactObj.patient_id = dict.value(forKey: "_id") as! String
                        print("ID of patient")
                        print(contactObj.patient_id)
                        contactObj.chatid = dict.value(forKey: "chatid") as! String
                        contactObj.full_name = dict.value(forKey: "fullname") as! String
                        contactObj.username = dict.value(forKey: "username") as! String
                        contactObj.HCNumber = dict.value(forKey: "HCNumber") as! String
                        contactObj.isSelected = "0"
                        self.patientList.add(contactObj)
                    }
                    self.tableView.reloadData()
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getDocPatients) Calling", action:"Success - Web API Calling" , label:"get Doctor Patients List", value : self.formInterval.intervalAsSeconds())
                }
                break
            case .failure(let error):
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getDocPatients) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                break
                
            }
            
        }
    }
    
    func getDoctorEducators()  {
        let doctorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": doctorID
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getDocEducators)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
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
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getDocEducators) Calling", action:"Success - Web API Calling" , label:"get Doctor Educators List", value : self.formInterval.intervalAsSeconds())
                    
                    self.tableView.reloadData()
                }
                
                break
            case .failure(let error):
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getDocEducators) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                break
                
            }
            
        }
    }
    
    func getEducatorPatients(){
        let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": educatorID
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        Alamofire.request("\(baseUrl)\(ApiMethods.getEduPatients)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
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
                        contactObj.HCNumber = dict.value(forKey: "HCNumber") as! String
                        contactObj.isSelected = "0"
                        self.patientList.add(contactObj)
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getEduPatients) Calling", action:"Success - Web API Calling" , label:"get Educator Patients List", value : self.formInterval.intervalAsSeconds())
                    }
                    self.tableView.reloadData()
                }
                
                break
            case .failure(let error):
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getEduPatients) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                break
            }
            
        }
    }
    
    
    func getEducatorDoctors(){
        
        let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "id": educatorID
        ]
        print("Educator ID")
        print(educatorID)
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getEduDoctors)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
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
                        print("Dict")
                        print(dict)
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getEduDoctors) Calling", action:"Success - Web API Calling" , label:"get Educator Doctors List", value : self.formInterval.intervalAsSeconds())
                        
                        
                    }
                    self.tableView.reloadData()
                }
                
                break
            case .failure(let error):
                let resultText = NSString(data: response.result.error! as! Data, encoding: String.Encoding.utf8.rawValue)
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getEduDoctors) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
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
