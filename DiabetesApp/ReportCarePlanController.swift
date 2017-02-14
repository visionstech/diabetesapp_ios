//
//  ReportCarePlanController.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import  Alamofire
import SVProgressHUD

let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))

class ReportCarePlanController: UIViewController, UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var btnOkFreqPicker: UIButton!
    @IBOutlet weak var btnCancelFreqPicker: UIButton!
    @IBOutlet weak var btnOkPicker: UIButton!
    @IBOutlet weak var btnCancelPicker: UIButton!
    @IBOutlet weak var pickerFreqView: UIPickerView!
    @IBOutlet weak var pickerTimingView: UIPickerView!
    @IBOutlet weak var pickerViewInner: UIView!
    @IBOutlet weak var noReadingsAvailable: UILabel!
    @IBOutlet weak var takereadingsLabel: UILabel!
    var reportUSer = String()
    var selectedIndex = Int()
    var selectedIndexPath = Int()
    var array = NSMutableArray()
    var currentEditReadingArray = NSMutableArray()
    
    var objCarePlanFrequencyObj = CarePlanFrequencyObj()

    //    @IBOutlet weak var numberLbl: UILabel!
//    @IBOutlet weak var goalLbl: UITextField!
//    @IBOutlet weak var conditionLbl: UITextField!
//    
//    @IBOutlet weak var mainView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
        
        //TableView Round corner and Border set
        tblView.layer.cornerRadius = kButtonRadius
        tblView.layer.masksToBounds = true
        tblView.layer.borderColor = Colors.PrimaryColor.cgColor
        tblView.layer.borderWidth = 1.0
        
        tblView.tableFooterView =  UIView(frame: .zero)
        
        self.automaticallyAdjustsScrollViewInsets = true

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNotifications()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        
        if !UserDefaults.standard.bool(forKey: "groupChat") {
            if selectedUserType == userType.doctor {
                getDoctorReadingsData()
            }
            else{
                getReadingsData()
            }
        }
        else {
            if selectedUserType == userType.doctor {
                getDoctorSingleData()
            }
            else{
                getReadingsData()
            }
        }
    }
    
    //func viewDidAppear() {
       
        // Dispose of any resources that can be recreated.
   // }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
       
    }
    
    //MARK: - Custom Methods
    func resetUI() {
        
        tblView.isHidden = false

        /*if self.array.count > 0 {
            tblView.isHidden = false
             noReadingsAvailable.isHidden = true
        }
        else {
            
            tblView.isHidden = true
            noReadingsAvailable.isHidden = false
        }*/
    }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
    }
    
    //MARK: - textfield  Delegates
    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let selectedIndex : Int = Int(textField.accessibilityLabel!)!
        let mainDict: NSMutableDictionary = array[textField.tag] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
        let readDict: NSMutableDictionary = NSMutableDictionary()
        
      
        readDict.setValue(obj.id, forKey: "id")
        readDict.setValue(obj.frequency, forKey: "frequency")
        readDict.setValue(obj.time, forKey: "time")
        readDict.setValue(obj.goal, forKey: "goal")
        print("In read dict")
        print(readDict)
        if self.currentEditReadingArray.count > 0 {
            for i in 0..<self.currentEditReadingArray.count {
                let id: String = (currentEditReadingArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                print(id)
                if id == obj.id {
                    currentEditReadingArray.replaceObject(at:i, with: readDict)
                    textField.resignFirstResponder()
                    UserDefaults.standard.setValue(currentEditReadingArray, forKey: "currentEditReadingArray")
                    UserDefaults.standard.synchronize()
                    return true
                }
            }
            currentEditReadingArray.add(readDict)
            
        }
        else {
            currentEditReadingArray.add(readDict)
        }
        
        UserDefaults.standard.setValue(currentEditReadingArray, forKey: "currentEditReadingArray")
        UserDefaults.standard.synchronize()
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        let selectedIndex : Int = Int(textField.accessibilityLabel!)!
        let mainDict: NSMutableDictionary = array[textField.tag] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
        let readDict: NSMutableDictionary = NSMutableDictionary()
        readDict.setValue(obj.id, forKey: "id")
        readDict.setValue(obj.frequency, forKey: "frequency")
        readDict.setValue(obj.time, forKey: "time")
        readDict.setValue(obj.goal, forKey: "goal")
       

        if self.currentEditReadingArray.count > 0 {
            for i in 0..<self.currentEditReadingArray.count {
                print("In read dict more 0")
                print(readDict)
                let id: String = (currentEditReadingArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                print(id)
                if id == obj.id {
                    currentEditReadingArray.replaceObject(at:i, with: readDict)
                    UserDefaults.standard.setValue(currentEditReadingArray, forKey: "currentEditReadingArray")
                    UserDefaults.standard.synchronize()
                    return
                }
            }
            currentEditReadingArray.add(readDict)
            
        }
        else {
            
            currentEditReadingArray.add(readDict)
        }
        print("In read dict")
        print(currentEditReadingArray)
        UserDefaults.standard.setValue(currentEditReadingArray, forKey: "currentEditReadingArray")
        UserDefaults.standard.synchronize()
        print("Done with storing")
        print(UserDefaults.standard.array(forKey: "currentEditReadingArray")! as [Any] as NSArray)

        //        currentEditReadingArray.add(readDict)
        
        
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.accessibilityValue  != "goal" {
            selectedIndex = Int(textField.accessibilityLabel!)!
            selectedIndexPath =  textField.tag
        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityValue == "goal" {
            let selectedIndex : Int = Int(textField.accessibilityLabel!)!
            let mainDict: NSMutableDictionary = array[textField.tag] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
            obj.goal  = ((resultString) as NSString) as String
            itemsArray.replaceObject(at:selectedIndex, with: obj)
            let mSectioDict = (array[textField.tag] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
            array.replaceObject(at:textField.tag, with: sectionsDict)
            
        }
        return true
    }*/
    
    // MARK: - Editable TableView TextField
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //check this
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GIntakeViewController.dismissKeyboard(_:))))
        textField.becomeFirstResponder()
    }
    private func textFieldDidEndEditing(textField: UITextField, inRowAtIndexPath indexPath: NSIndexPath) {
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField .resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = self.parentCellFor(view: textField) as! CarePlanReadingTableViewCell
        
        if !cell.isViewEmpty {
            cell.goalLbl.text = textField.text
            self.objCarePlanFrequencyObj.goal = textField.text!
            let objCarePlanObj = (array[textField.tag] as? CarePlanFrequencyObj)!
            objCarePlanObj.goal = textField.text!
        }
    }

    
    //MARK: - Notifications Methods
    func readingNotification(notification: NSNotification) {
        tblView.reloadData()
        
    }
    
    // MARK: - Api Methods
    func getReadingsData() {
        
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
           
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
            
           
            let parameters: Parameters = [
                "patientid": patientsID,
                "educatorid": educatorID,
                "numDaysBack": "0",
                "condition": "All conditions"
            ]
            
            print(parameters)
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getEducatorGroupReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            //print(response)
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                       
                        let arr  = NSMutableArray(array: JSON.object(forKey: "readingsTime")as! NSArray)
                        self.array.removeAllObjects()
                       // for time in frequnecyArray {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            mainDict.setValue(String(describing: time), forKey: "frequency")
                            let itemsArray: NSMutableArray = NSMutableArray()
                            for data in arr {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj = CarePlanReadingObj()
                                obj.id = dict.value(forKey: "_id") as! String
                                // Between
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                //obj.goal = dict.value(forKey: "goal") as! String
                                obj.time = dict.value(forKey: "time") as! String
                                obj.frequency = dict.value(forKey: "frequency") as! String
                               
                               // if String(describing: time) == obj.frequency {
                                    itemsArray.add(obj)
                                //}
                            }
                            
                            if itemsArray.count > 0{
                                //                                for i : Int in 0 ..< itemsArray.count {
                                mainDict.setObject(itemsArray, forKey: "data" as NSCopying)
                                self.array.add(mainDict)
                                // }
                            }
                            
                       // }
                        
                        print(self.array)
                    }
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                case .failure:
                    print("failure")
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                }
            }
        }
    }
    
    func getDoctorSingleData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            
            let parameters: Parameters = [
                "patientid": patientsID,
                "numDaysBack": "1",
                "condition": "All conditions"
            ]
            print(parameters)
            
            Alamofire.request("http://54.244.176.114:3000/getdoctorsingle", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print(JSON)
                        let arr  = NSMutableArray(array: JSON.object(forKey: "readingsTime")as! NSArray)
                        self.array.removeAllObjects()
                       // for time in frequnecyArray {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            mainDict.setValue(String(describing: time), forKey: "frequency")
                            let itemsArray: NSMutableArray = NSMutableArray()
                            for data in arr {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj = CarePlanReadingObj()
                                obj.id = dict.value(forKey: "_id") as! String
                                // Between
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                //obj.goal = dict.value(forKey: "goal") as! String
                                obj.time = dict.value(forKey: "time") as! String
                                obj.frequency = dict.value(forKey: "frequency") as! String
                                print("Readings time")
                                print(String(describing: time))
                                print(obj.frequency)
                               // if String(describing: time) == obj.frequency {
                                    itemsArray.add(obj)
                                //}
                            }
                            
                            if itemsArray.count > 0{
                                //                                for i : Int in 0 ..< itemsArray.count {
                                mainDict.setObject(itemsArray, forKey: "data" as NSCopying)
                                self.array.add(mainDict)
                                // }
                            }
                            
                        //}
                        
                        print(self.array)
                    }
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                case .failure:
                    print("failure")
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                }
            }
        }
    }

    
    func getDoctorReadingsData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
            
            let parameters: Parameters = [
                "taskid": taskID,
                "patientid": patientsID,
                "numDaysBack": "0",
                "condition": "All conditions"
            ]
            //print(parameters)
            
            Alamofire.request("http://54.244.176.114:3000/getdoctorreport", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print(JSON)
                        let arr  = NSMutableArray(array: JSON.object(forKey: "readingsTime")as! NSArray)
                        self.array.removeAllObjects()
                        //for time in frequnecyArray {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            mainDict.setValue(String(describing: time), forKey: "frequency")
                            let itemsArray: NSMutableArray = NSMutableArray()
                            for data in arr {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj = CarePlanReadingObj()
                                obj.id = dict.value(forKey: "_id") as! String
                                // Between
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                //obj.goal = dict.value(forKey: "goal") as! String
                                obj.time = dict.value(forKey: "time") as! String
                                obj.frequency = dict.value(forKey: "frequency") as! String
                                print( obj.frequency)
                               // if String(describing: time) == obj.frequency {
                                    itemsArray.add(obj)
                                //}
                            }
                            
                            if itemsArray.count > 0{
                                //                                for i : Int in 0 ..< itemsArray.count {
                                mainDict.setObject(itemsArray, forKey: "data" as NSCopying)
                                self.array.add(mainDict)
                                // }
                            }
                            
                       // }
                        
                        print(self.array)
                    }
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                case .failure:
                    print("failure")
                    self.tblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                }
            }
        }
    }
    
    
    func parentCellFor(view: UIView) -> UITableViewCell {
        if (view.superview == nil){
            return view as! UITableViewCell
        }
        
        if   view is UITableViewCell {
            return (view as! UITableViewCell)
        }
        return self.parentCellFor(view: view.superview!)
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let mainDict: NSMutableDictionary = array[section] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        
        return itemsArray.count
        //return itemsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      //  print("Array count")
       // print(array.count)
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mainDict: NSMutableDictionary = array[indexPath.section] as! NSMutableDictionary
        
        
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        

        let tempArray : NSArray = UserDefaults.standard.array(forKey: "updateReadingCareArray")! as [Any] as NSArray

        
        
        //print("Bool vaue for readings")
        //print(UserDefaults.standard.bool(forKey: "CurrentReadEditBool"))
        
        
        let cell : ReportCarePlanReadingViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! ReportCarePlanReadingViewCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnFreq.tag = indexPath.row
        cell.btnTiming.tag = indexPath.row
        cell.txtGoal.tag = indexPath.row
        
        
        let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        
        
        if let obj: CarePlanReadingObj = itemsArray[indexPath.row] as? CarePlanReadingObj {
            cell.goalLbl.text = obj.goal
            cell.txtGoal.text = obj.goal
            cell.conditionLbl.text = obj.time
            
            let valFreq = obj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
            if valFreq == "once a week"{
                cell.frequencyLbl.text = "1/week"
            }
            else if valFreq == "twice a week"{
                cell.frequencyLbl.text = "2/week"
            }
            else if valFreq == "thrice a week"{
                cell.frequencyLbl.text = "3/week"
            }
            else if valFreq == "once daily"{
                cell.frequencyLbl.text = "Daily"
            }
            else if valFreq == "twice daily"{
                cell.frequencyLbl.text = "2/Daily"
            }
            
            cell.txtGoal.delegate = self
            cell.txtGoal.isHidden = true
            cell.btnEdit.isHidden = true
            cell.btnTiming.isHidden = true
           // cell.btnFreq.addTarget(self, action: #selector(btnFreq_Clicked(_:)), for: .touchUpInside)
            //cell.btnTiming.addTarget(self, action: #selector(btnTiming_Clicked(_:)), for: .touchUpInside)
            /*if(obj.isEdit)
            {
                cell.btnTiming.isHidden = false
                cell.btnFreq.isHidden = false
                cell.txtGoal.isHidden = false
            }
            else
            {
                cell.btnTiming.isHidden = true
                cell.btnFreq.isHidden = true
                cell.txtGoal.isHidden = true
            }
            
            if(selectedUserType == userType.patient)
            {
                cell.btnEdit.isHidden = true
                cell.btnTiming.isHidden = true
                cell.btnFreq.isHidden = true
                cell.txtGoal.isHidden = true
            }
            else{
                cell.btnEdit.isHidden = false
            }*/
        }
        return cell;
    }

    
        //CODE BELOW IS IF EDITING IS REQUIRED ON REPORT VIEW ITSELF
       /* let mainDict: NSMutableDictionary = array[indexPath.section] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        let cell : ReportCarePlanReadingViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! ReportCarePlanReadingViewCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        
        if !UserDefaults.standard.bool(forKey: "groupChat") {
            if selectedUserType == userType.doctor {
                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                    cell.goalLbl.isUserInteractionEnabled = true
                    cell.conditionLbl.isUserInteractionEnabled = true
                }
                else {
                    cell.goalLbl.isUserInteractionEnabled = false
                    cell.conditionLbl.isUserInteractionEnabled = false
                }
                
            }
            else {
                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                    cell.goalLbl.isUserInteractionEnabled = true
                    cell.conditionLbl.isUserInteractionEnabled = true
                }
                else {
                    cell.goalLbl.isUserInteractionEnabled = false
                    cell.conditionLbl.isUserInteractionEnabled = false
                }
            }
        }
        else {
            if selectedUserType == userType.doctor {
                
                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                    cell.goalLbl.isUserInteractionEnabled = true
                    cell.conditionLbl.isUserInteractionEnabled = true
                }
                else {
                    cell.goalLbl.isUserInteractionEnabled = false
                    cell.conditionLbl.isUserInteractionEnabled = false
                }
                
                //                cell.goalLbl.isUserInteractionEnabled = true
                //                cell.conditionLbl.isUserInteractionEnabled = true
            }
            else {
                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                    cell.goalLbl.isUserInteractionEnabled = true
                    cell.conditionLbl.isUserInteractionEnabled = true
                }
                else {
                    cell.goalLbl.isUserInteractionEnabled = false
                    cell.conditionLbl.isUserInteractionEnabled = false
                }
                
                
            }
            
        }
        //        if selectedUserType == userType.doctor {
        //
        //            cell.goalLbl.isUserInteractionEnabled = true
        //            cell.conditionLbl.isUserInteractionEnabled = true
        //
        //
        //        }
        //        else {
        //            if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
        //                cell.goalLbl.isUserInteractionEnabled = true
        //                cell.conditionLbl.isUserInteractionEnabled = true
        //            }
        //            else {
        //            cell.goalLbl.isUserInteractionEnabled = false
        //            cell.conditionLbl.isUserInteractionEnabled = false
        //            }
        //        }
        //
        cell.goalLbl.delegate = self
        cell.conditionLbl.delegate = self
        
        
        if let obj: CarePlanReadingObj = itemsArray[indexPath.row] as? CarePlanReadingObj {
            cell.goalLbl.tag = indexPath.section
            cell.goalLbl.accessibilityLabel = "\(indexPath.row)"
            cell.goalLbl.accessibilityValue = "goal"
            
            cell.conditionLbl.text = obj.time
            cell.conditionLbl.tag = indexPath.section
            cell.conditionLbl.accessibilityLabel = "\(indexPath.row)"
            cell.conditionLbl.accessibilityValue = "Condition"
            cell.conditionLbl.inputView = pickerViewContainer
            
            if obj.frequency.lowercased() == "Once a week".lowercased(){
                cell.goalLbl.text = "1/week"
            }
            else if obj.frequency.lowercased() == "Twice a week".lowercased(){
                cell.goalLbl.text = "2/week"
            }
            else if obj.frequency.lowercased() == "Thrice a week".lowercased(){
                cell.goalLbl.text = "3/week"
            }
            else if obj.frequency.lowercased() == "Once Daily".lowercased(){
                cell.goalLbl.text = "Daily"
            }
            else if obj.frequency.lowercased() == "Twice Daily".lowercased(){
                cell.goalLbl.text = "2/Daily"
            }

           
           // cell.goalLbl.text = obj.goal
           
           // cell.numberLbl.text = "\(indexPath.row+1)."
        }
        
        return cell
        
    }*/
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : CarePlanReadingHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")! as! CarePlanReadingHeaderTableViewCell
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func viewDidLayoutSubviews() {
        defer {
        }
        do {
            tblView.separatorInset = UIEdgeInsets.zero
            
            tblView.layoutMargins = UIEdgeInsets.zero
            
        }     catch let exception {
            print("Exception Occure in LeadDetailViewController viewDidLayoutSubviews: \(exception)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        defer {
        }
        do {
            cell.separatorInset = UIEdgeInsets.zero
            
            cell.layoutMargins = UIEdgeInsets.zero
            
            var frame = self.tblView.frame
            frame.size.height = self.tblView.contentSize.height
            self.tblView.frame = frame
        }     catch let exception {
            print("Exception Occure in LeadDetailViewController willDisplayCell: \(exception)")
        }
    }

    
    //MARK:- PickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conditionsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return conditionsArray[row] as? String
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    @IBAction func pickerCancelButton(_ sender: Any) {
    }
    
    @IBAction func ToolBarButtons_Click(_ sender: Any) {
   
        self.view.endEditing(true)
        if (sender as AnyObject).tag == 0 {
            print(selectedIndexPath , selectedIndex)
            let mainDict: NSMutableDictionary = array[selectedIndexPath] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            obj.time = conditionsArray[pickerView.selectedRow(inComponent: 0)] as! String
            itemsArray.replaceObject(at:selectedIndex, with: obj)
            let mSectioDict = (array[selectedIndexPath] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
            array.replaceObject(at:selectedIndexPath, with: sectionsDict)
            self.view.endEditing(true)
            tblView.reloadData()
            let placesData = NSKeyedArchiver.archivedData(withRootObject: currentEditReadingArray)
            UserDefaults.standard.set(placesData, forKey: "currentEditReadingArray")
            UserDefaults.standard.set(currentEditReadingArray, forKey: "currentEditReadingArray")
            UserDefaults.standard.synchronize()
            
            print(currentEditReadingArray)
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
