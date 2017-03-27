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

    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
     var tempReadArray = NSMutableArray()
    
    @IBOutlet weak var csTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csOldTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var costAddReadingButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var costheaderEditButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constHeaderLastViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var csNewHeaderEditSpaceWidth: NSLayoutConstraint!
    @IBOutlet weak var csOldHeaderEditSpaceWidth: NSLayoutConstraint!
    
    @IBOutlet weak var csBottomScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var timingHeaderLabel: UILabel!
    @IBOutlet weak var goalHeaderLabel: UILabel!
    
    @IBOutlet weak var oldFrequencyLbl: UILabel!
    @IBOutlet weak var oldTimingHeaderLabel: UILabel!
    @IBOutlet weak var oldGoalHeaderLabel: UILabel!
    @IBOutlet weak var readingScroll: UIScrollView!
    @IBOutlet weak var vmReadingMain: UIView!
    @IBOutlet weak var vmNewReading: UIView!
    @IBOutlet weak var vmOldReading: UIView!
    
    @IBOutlet weak var csvmReadingMainHeight: NSLayoutConstraint!
    @IBOutlet weak var csvmNewReadingHeight: NSLayoutConstraint!
    @IBOutlet weak var csvmOldReadingHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblNewChangeByDr: UILabel!
    @IBOutlet weak var lblOldChangeByDr: UILabel!
    
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet weak var vmNewHeader: UIView!
    @IBOutlet weak var vmoldHeader: UIView!
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
    
    @IBOutlet weak var newTblView: UITableView!
    @IBOutlet weak var oldTblView: UITableView!
    var newArray = NSMutableArray()
    var oldArray = NSMutableArray()
    
    var repoReadArray = NSMutableArray()
     var repoOldReadArray = NSMutableArray()
    var arrayCopy = NSArray()

    var newReadingAddedTemp = NSArray()
    var editedReadTempArray = NSArray()
    var readingDeletedTemp = NSArray()

    
    var updateArray = NSMutableArray()
    var currentEditReadingArray = NSMutableArray()
    
    var objCarePlanFrequencyObj = CarePlanFrequencyObj()

    //    @IBOutlet weak var numberLbl: UILabel!
//    @IBOutlet weak var goalLbl: UITextField!
//    @IBOutlet weak var conditionLbl: UITextField!
//    
//    @IBOutlet weak var mainView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newTblView.backgroundColor = UIColor.clear
        newTblView.tableHeaderView =  UIView(frame: .zero)
        newTblView.tableFooterView =  UIView(frame: .zero)
        
        oldTblView.backgroundColor = UIColor.clear
        oldTblView.tableHeaderView =  UIView(frame: .zero)
        oldTblView.tableFooterView =  UIView(frame: .zero)
        
        self.automaticallyAdjustsScrollViewInsets = true
        
        timingHeaderLabel.text = "CONDITION".localized
        goalHeaderLabel.text = "Goal".localized
        frequencyLbl.text = "Frequency".localized
        
        
        
        oldTimingHeaderLabel.text = "CONDITION".localized
        oldGoalHeaderLabel.text = "Goal".localized
        oldFrequencyLbl.text = "Frequency".localized
        oldTimingHeaderLabel.backgroundColor = Colors.medicationConditionGrayColor
        oldGoalHeaderLabel.backgroundColor = Colors.medicationConditionGrayColor
        oldFrequencyLbl.backgroundColor = Colors.medicationConditionGrayColor
        
        timingHeaderLabel.text = "CONDITION".localized
        goalHeaderLabel.text = "Goal".localized
        frequencyLbl.text = "Frequency".localized
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addNotifications()
        
        //Setup Round corners to Header View for new and old
        vmNewHeader.roundCorners(corners: [.topLeft, .topRight], radius: kButtonRadius)
        vmoldHeader.roundCorners(corners: [.topLeft, .topRight], radius: kButtonRadius)
        
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            doctorReportAPI()
        }
        else {
            getReadingsData()
        }
        //}
    }
    override func viewWillAppear(_ animated: Bool) {
        
        self.csOldHeaderEditSpaceWidth.constant = 8
        self.csNewHeaderEditSpaceWidth.constant = 8
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
        
        if self.newArray.count > 0 {
            newTblView.isHidden = false
          //  noreadingsLabel.isHidden = false
            self.vmNewHeader.isHidden = false
        }
        else {
            newTblView.isHidden = true
          //  noreadingsLabel.isHidden = true
            self.vmNewHeader.isHidden = true
        }
        if self.oldArray.count > 0 {
            oldTblView.isHidden = false
            self.vmoldHeader.isHidden = false
        }
        else {
            oldTblView.isHidden = true
            self.vmoldHeader.isHidden = true
        }
        
        if(self.selectedUserType != userType.patient)
        {
            oldTblView.isHidden = false
        }
        else
        {
            oldTblView.isHidden = true
            self.vmoldHeader.isHidden = true
        }
        
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
            let objCarePlanObj = (self.newArray[textField.tag] as? CarePlanFrequencyObj)!
            objCarePlanObj.goal = textField.text!
        }
    }

    
    //MARK: - Notifications Methods
    func readingNotification(notification: NSNotification) {
       self.newTblView.reloadData()
        
    }
    
    // MARK: - Api Methods
    
    func doctorReportAPI() {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)! as String
        let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
        
        let parameters: Parameters = [
            "taskid": taskID,
            "patientid": patientsID,
            "numDaysBack": "0",
            "condition": "All conditions"
        ]
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getDoctorRequestReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                self.newArray = NSMutableArray()
                self.repoReadArray = NSMutableArray()
                self.repoOldReadArray = NSMutableArray()
                self.oldArray = NSMutableArray()
                var totalHeightForTableNew = 0
                var totalHeightForTableOld = 0
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    let jsonArrRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "currentReading") as! NSArray)
                    let jsonArrReadOld : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "oldReadings") as! NSArray)
                    let jsonArrUpdatedRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedReading") as! NSArray)
                    let jsonArrNewRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "newReading") as! NSArray)
                    let jsonArrDeleteNewRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "deletedReading") as! NSArray)
                    
                    //aaa
                    
                    if jsonArrReadOld.count > 0 {
                        self.oldArray.removeAllObjects()
                        for data in jsonArrReadOld {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj1 = CarePlanFrequencyObj()
                            if dict.value(forKey: "id") != nil{
                                obj1.id = dict.value(forKey: "id") as! String
                            }
                            else if dict.value(forKey: "_id") != nil{
                                obj1.id = dict.value(forKey: "_id") as! String
                            }
                            
                            let goalStr: String = dict.value(forKey: "goal") as! String
                            obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                            obj1.time = dict.value(forKey: "time") as! String
                            obj1.frequency = dict.value(forKey: "frequency") as! String
                            obj1.isEdit = false
                            self.repoOldReadArray.add(dict)
                            self.oldArray.add(obj1)
                        }
                    }
                    
                    UserDefaults.standard.setValue(self.repoOldReadArray, forKey: "repoOldReadiArray")
                    UserDefaults.standard.synchronize()
                    
                    if jsonArrRead.count > 0 {
                        self.newArray.removeAllObjects()
                        for data in jsonArrRead {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            if dict.value(forKey: "id") != nil{
                                obj.id = dict.value(forKey: "id") as! String
                            }
                            else if dict.value(forKey: "_id") != nil{
                                obj.id = dict.value(forKey: "_id") as! String
                            }
                            obj.goal = dict.value(forKey: "goal") as! String
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            self.repoReadArray.add(dict)
                            self.newArray.add(obj)
                        }
                    }
                    
                    //Update current medication if educator updated
                    if jsonArrUpdatedRead.count > 0 {
                        for data1 in jsonArrUpdatedRead{
                            
                            let dict: NSDictionary = data1 as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            obj.id = dict.value(forKey: "id") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            obj.time = dict.value(forKey: "time") as! String
                            obj.goal = dict.value(forKey: "goal") as! String
                            
                            
                            
                            for i in 0..<self.newArray.count {
                                let objCarPlan = (self.newArray[i] as? CarePlanFrequencyObj)!
                                if(objCarPlan.id ==  obj.id )
                                {
                                    self.repoReadArray.replaceObject(at: i, with: dict)
                                    self.newArray.replaceObject(at: i, with: obj)
                                    break
                                }
                            }
                        }
                        
                    }
                    
                    //Add new medication if educator added
                    if jsonArrNewRead.count > 0 {
                        
                        for data in jsonArrNewRead {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            if (dict.value(forKey: "_id") == nil)
                            {
                                obj.id = dict.value(forKey: "id") as! String
                            }
                            else
                            {
                                obj.id = dict.value(forKey: "_id") as! String
                            }
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            obj.goal = dict.value(forKey: "goal") as! String
                            obj.time = dict.value(forKey: "time") as! String
                            
                            self.newArray.add(obj)
                            self.repoReadArray.add(dict)
                        }
                    }
                    
                    //Delete Medication Data From the cashe
                    
                    for data1 in jsonArrDeleteNewRead{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanFrequencyObj()
                        obj.id = dict.value(forKey: "id") as! String
                        for i in 0..<self.newArray.count {
                            let objCarPlan = (self.newArray[i] as? CarePlanFrequencyObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.newArray.remove(objCarPlan)
                                self.repoReadArray.removeObject(at: i)
                                break
                            }
                        }
                    }
                    
                    if  UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                        self.addDefaultValueReading()
                    }
                    
                    UserDefaults.standard.setValue(self.repoReadArray, forKey: "repoReadiArray")
                    UserDefaults.standard.synchronize()
                    
                    
                    self.arrayCopy = self.newArray.mutableCopy() as! NSArray
                    totalHeightForTableNew = totalHeightForTableNew + ((self.newArray.count * CarePlanReadingViewController.kTableheight))
                    totalHeightForTableOld = totalHeightForTableOld + ((self.oldArray.count * CarePlanReadingViewController.kTableheight))
                    
                    self.csvmReadingMainHeight.constant = CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld + 50)
                    self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
                    self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
                    
                    self.csvmNewReadingHeight.constant = CGFloat(totalHeightForTableNew + 50)
                    self.csvmOldReadingHeight.constant = CGFloat(totalHeightForTableOld + 50)
                    
                    self.vmReadingMain.updateConstraintsIfNeeded()
                    self.vmOldReading.updateConstraintsIfNeeded()
                    self.vmNewReading.updateConstraintsIfNeeded()
                    
                    self.readingScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld + 50))
                    
                    var dataDict = Dictionary<String, CGFloat>()
                    dataDict["height"] = CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 50)
                    
                    
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "ReadingHeightReportView"), object: nil, userInfo:dataDict)
                    
                    //  ---- End ----
                    self.newTblView.reloadData()
                    self.oldTblView.reloadData()
                    
                    self.resetUI()
                    self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)

                }
                
                break
            case .failure:
                print("failure")
                self.newArray = NSMutableArray()
                self.newTblView.reloadData()
                self.newTblView.layoutIfNeeded()
                self.resetUI()
                SVProgressHUD.showError(withStatus: response.result.error?.localizedDescription)
                break
                
            }
        }
        
        
    }
    
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
                    self.newArray = NSMutableArray()
                    self.oldArray = NSMutableArray()
                    var totalHeightForTableNew = 0
                    var totalHeightForTableOld = 0

                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                       
                        self.oldArray.removeAllObjects()
                        if  let JSONOldRed :  NSArray = JSON.value(forKey: "oldReadings") as? NSArray{
                            
                            for data in JSONOldRed {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj1 = CarePlanFrequencyObj()
                                if dict.value(forKey: "id") != nil{
                                    obj1.id = dict.value(forKey: "id") as! String
                                }
                                else if dict.value(forKey: "_id") != nil{
                                    obj1.id = dict.value(forKey: "_id") as! String
                                }
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                obj1.time = dict.value(forKey: "time") as! String
                                obj1.frequency = dict.value(forKey: "frequency") as! String
                                obj1.isEdit = false
                                self.oldArray.add(obj1)
                            }
                        }
                        
                        if  let JSONNewRead :  NSArray = JSON.value(forKey: "readingsTime") as? NSArray{
                            self.newArray.removeAllObjects()
                            for data in JSONNewRead {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj1 = CarePlanFrequencyObj()
                                obj1.id = dict.value(forKey: "_id") as! String
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                obj1.time = dict.value(forKey: "time") as! String
                                obj1.frequency = dict.value(forKey: "frequency") as! String
                                obj1.isEdit = false
                                self.newArray.add(obj1)
                            }
                        }
                        
                        let arrNew = UserDefaults.standard.array(forKey: "currentAddReadingArray")! as [Any] as NSArray
                        self.newReadingAddedTemp = NSMutableArray(array: arrNew)
                        
                        let arrDelete = UserDefaults.standard.array(forKey: "currentDeleteReadingArray")! as [Any] as NSArray
                        self.readingDeletedTemp = NSMutableArray(array: arrDelete)
                        
                        let arrEdit = UserDefaults.standard.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
                        self.editedReadTempArray = NSMutableArray(array: arrEdit)
                        
                        //   if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                        
                        // if editedReadTemp.count > 0{
                        for data in self.editedReadTempArray{
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            obj.id = dict.value(forKey: "id") as! String
                            obj.goal = dict.value(forKey: "goal") as! String
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            for i in 0..<self.newArray.count{
                                let obj1 : CarePlanFrequencyObj = self.newArray[i] as! CarePlanFrequencyObj
                                
                                //let obj1 = CarePlanFrequencyObj()
                                
                                if obj1.id == obj.id{
                                    
                                    obj1.id = obj.id
                                    obj1.goal = obj.goal
                                    obj1.time = obj.time
                                    obj1.frequency = obj.frequency
                                    
                                    self.newArray.replaceObject(at: i, with: obj1)
                                    break
                                }
                                
                            }
                        }
                      
                        for data1 in self.newReadingAddedTemp {
                            let dict: NSDictionary = data1 as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            obj.id = ""
                            let goalStr: String = dict.value(forKey: "goal") as! String
                            obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            self.newArray.add(obj)
                        }
                        for data2 in self.readingDeletedTemp{
                            let dict: NSDictionary = data2 as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            obj.id = dict.value(forKey: "id") as! String
                            
                            for i in 0..<self.newArray.count{
                                let obj1 : CarePlanFrequencyObj = self.newArray[i] as! CarePlanFrequencyObj
                              
                                if obj1.id == obj.id{
                                    
                                    self.newArray.removeObject(at: i)
                                    break
                                }
                                
                            }
                        }
                        
                    }
                    
                    self.arrayCopy = self.newArray.mutableCopy() as! NSArray
                    
                    totalHeightForTableNew = totalHeightForTableNew + ((self.newArray.count * CarePlanReadingViewController.kTableheight))
                    totalHeightForTableOld = totalHeightForTableOld + ((self.oldArray.count * CarePlanReadingViewController.kTableheight))
                    
                    self.csvmReadingMainHeight.constant = CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld + 50)
                    self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
                    self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
                    
                    self.csvmNewReadingHeight.constant = CGFloat(totalHeightForTableNew + 50)
                    self.csvmOldReadingHeight.constant = CGFloat(totalHeightForTableOld + 50)
                    
                    self.vmReadingMain.updateConstraintsIfNeeded()
                    self.vmOldReading.updateConstraintsIfNeeded()
                    self.vmNewReading.updateConstraintsIfNeeded()
                    
                    self.readingScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld + 50))
                    
                    var dataDict = Dictionary<String, CGFloat>()
                    dataDict["height"] = CGFloat(totalHeightForTableNew + 50) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 50)
                    
                    
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue: "ReadingHeightReportView"), object: nil, userInfo:dataDict)
                    
                    //  ---- End ----
                    self.newTblView.reloadData()
                    self.oldTblView.reloadData()
                    
                    self.resetUI()
                    self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)

                    
                    break
                    
                case .failure:
                    print("failure")
                    self.newTblView.reloadData()
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
                        self.newArray.removeAllObjects()
                        for data in arr {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanReadingObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            let goalStr: String = dict.value(forKey: "goal") as! String
                            obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            self.newArray.add(obj)
                        }
                        
                        print(self.newArray)
                    }
                    self.newTblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                case .failure:
                    print("failure")
                    self.newTblView.reloadData()
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
                        self.newArray.removeAllObjects()
                        for data in arr {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanReadingObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            let goalStr: String = dict.value(forKey: "goal") as! String
                            obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            self.newArray.add(obj)
                        }
                        
                        print(self.newArray)
                    }
                    self.newTblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                case .failure:
                    print("failure")
                    self.newTblView.reloadData()
                    self.resetUI()
                    
                    break
                    
                }
            }
        }
    }
    
    func addDefaultValueReading(){
        
        let arrEdit : NSArray = UserDefaults.standard.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
        let jsonArrUpdatedRead = NSMutableArray(array: arrEdit)
        //Update current medication if educator updated
        if jsonArrUpdatedRead.count > 0 {
            for data1 in jsonArrUpdatedRead{
                
                let dict: NSDictionary = data1 as! NSDictionary
                let obj = CarePlanFrequencyObj()
                obj.id = dict.value(forKey: "id") as! String
                obj.frequency = dict.value(forKey: "frequency") as! String
                obj.time = dict.value(forKey: "time") as! String
                obj.goal = dict.value(forKey: "goal") as! String
                
                
                
                for i in 0..<self.newArray.count {
                    let objCarPlan = (self.newArray[i] as? CarePlanFrequencyObj)!
                    if(objCarPlan.id ==  obj.id )
                    {
                        self.newArray.replaceObject(at: i, with: obj)
                        self.repoReadArray.replaceObject(at: i, with: dict)
                        break
                    }
                }
            }
            
        }
        
        let arrNew : NSArray = UserDefaults.standard.array(forKey: "currentAddReadingArray")! as [Any] as NSArray
        let jsonArrNewRead = NSMutableArray(array: arrNew)
        //Add new medication if educator added
        if jsonArrNewRead.count > 0 {
            
            for data in jsonArrNewRead {
                let dict: NSDictionary = data as! NSDictionary
                let obj = CarePlanFrequencyObj()
                //  obj.id = dict.value(forKey: "_id") as! String
                obj.frequency = dict.value(forKey: "frequency") as! String
                obj.goal = dict.value(forKey: "goal") as! String
                obj.time = dict.value(forKey: "time") as! String
                
                self.newArray.add(obj)
                self.repoReadArray.add(dict)
            }
        }
        
        //Delete Medication Data From the cashe
        
        let arrDelete : NSArray = UserDefaults.standard.array(forKey: "currentDeleteReadingArray")! as [Any] as NSArray
        let jsonArrDeleteNewRead = NSMutableArray(array: arrDelete)
        
        for data1 in jsonArrDeleteNewRead{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanFrequencyObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.newArray.count {
                let objCarPlan = (self.newArray[i] as? CarePlanFrequencyObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.newArray.remove(objCarPlan)
                    self.repoReadArray.removeObject(at: i)
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
    func reloadTable()
    {
        self.newTblView.reloadData()
        self.oldTblView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.newTblView)
        {
            return newArray.count
        }
        else
        {
            return oldArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView == self.newTblView)
        {
            let cell : CarePlanReadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! CarePlanReadingTableViewCell
            
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.btnEdit.tag = indexPath.row
            
            
            if let obj: CarePlanFrequencyObj = newArray[indexPath.row] as? CarePlanFrequencyObj {
                cell.goalLbl.text = obj.goal
                
                
                
                if(!obj.time.isEmpty)
                {
                    var tempString : [String] = obj.time.components(separatedBy: " ")
                    if(tempString[0] == "Pre")
                    {
                        obj.time = "Before "+tempString[1]
                    }
                    else if(tempString[0] == "Post")
                    {
                        obj.time = "After "+tempString[1]
                    }
                }
                
                let selectedConditionIndex = conditionsArrayEng.index(of: obj.time)
                if selectedConditionIndex < conditionsArrayEng.count
                {
                    cell.conditionLbl.text = conditionsArray[selectedConditionIndex] as? String
                }
                else
                {
                    cell.conditionLbl.text = conditionsArray[0] as? String
                }
                cell.conditionLbl.text = conditionsArray[selectedConditionIndex] as? String
                
                let valFreq = obj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
                if valFreq == "once a week"{
                    
                    cell.frequencyLbl.text = "1/week".localized
                }
                else if valFreq == "twice a week"{
                    cell.frequencyLbl.text = "2/week".localized
                }
                else if valFreq == "thrice a week"{
                    cell.frequencyLbl.text = "3/week".localized
                }
                else if valFreq == "once daily"{
                    cell.frequencyLbl.text = "Daily".localized
                }
                else if valFreq == "twice daily"{
                    cell.frequencyLbl.text = "2/Daily".localized
                }
                
                cell.goalLbl.layer.mask = nil
                cell.conditionLbl.layer.mask = nil
                
                let mainDict: NSMutableDictionary = NSMutableDictionary()
                mainDict.setValue(obj.id, forKey: "id")
                mainDict.setValue(obj.frequency, forKey: "frequency")
                mainDict.setValue(obj.time, forKey: "time")
                mainDict.setValue(obj.goal, forKey: "goal")
                
                tempReadArray.add(mainDict)
                
                cell.conditionLbl.textAlignment = .center
                cell.frequencyLbl.textAlignment = .center
                cell.goalLbl.textAlignment = .center
                
                cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
                cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
                
                if(selectedUserType == userType.patient)
                {
                    if obj.wasUpdated{
                        cell.conditionLbl.backgroundColor = UIColor.orange
                        cell.goalLbl.backgroundColor = UIColor.orange
                        cell.frequencyLbl.backgroundColor = UIColor.orange
                    }
                    else{
                        cell.conditionLbl.backgroundColor = Colors.historyHeaderColor
                        cell.goalLbl.backgroundColor = Colors.historyHeaderColor
                        cell.frequencyLbl.backgroundColor = Colors.historyHeaderColor
                    }
                    
                    cell.csBtnEditWidth.constant = 2
                    cell.btnEdit.setNeedsUpdateConstraints()
                    cell.btnEdit.isHidden = true
                }
                else{
                    cell.csBtnEditWidth.constant = 2
                    cell.btnEdit.setNeedsUpdateConstraints()
                    cell.btnEdit.isHidden = true
                    
                   // cell.btnEdit.isHidden = false
                }
                
                if(indexPath.row == self.newArray.count-1)
                {
                    let rect = cell.conditionLbl.bounds
                    
                    var maskPath  = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.conditionLbl.layer.mask = maskLayer
                    
                    
                    let rect1 = cell.goalLbl.bounds
                    
                    var maskPath1  = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath1 = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath1 = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer1 = CAShapeLayer()
                    maskLayer1.frame = self.view.bounds
                    maskLayer1.path = maskPath1.cgPath
                    cell.goalLbl.layer.mask = maskLayer1
                }
                
            }
            return cell;
        }
        else
        {
            let cell : CarePlanReadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! CarePlanReadingTableViewCell
            
            cell.selectionStyle = .none
            cell.tag = indexPath.row
            cell.btnEdit.tag = indexPath.row
            
            
            if let obj: CarePlanFrequencyObj = oldArray[indexPath.row] as? CarePlanFrequencyObj {
                cell.goalLbl.text = obj.goal
                
                /*if selectedUserType == userType.patient{
                 if obj.wasUpdated{
                 cell.conditionLbl.backgroundColor = UIColor.orange
                 cell.goalLbl.backgroundColor = UIColor.orange
                 cell.frequencyLbl.backgroundColor = UIColor.orange
                 }
                 else{
                 cell.conditionLbl.backgroundColor = UIColor.clear
                 cell.goalLbl.backgroundColor = UIColor.clear
                 cell.frequencyLbl.backgroundColor = UIColor.clear
                 }
                 }*/
                
                if(!obj.time.isEmpty)
                {
                    var tempString : [String] = obj.time.components(separatedBy: " ")
                    if(tempString[0] == "Pre")
                    {
                        obj.time = "Before "+tempString[1]
                    }
                    else if(tempString[0] == "Post")
                    {
                        obj.time = "After "+tempString[1]
                    }
                }
                
                let selectedConditionIndex = conditionsArrayEng.index(of: obj.time)
                if selectedConditionIndex < conditionsArrayEng.count
                {
                    cell.conditionLbl.text = conditionsArray[selectedConditionIndex] as? String
                }
                else
                {
                    cell.conditionLbl.text = conditionsArray[0] as? String
                }
                
                
                let valFreq = obj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
                if valFreq == "once a week"{
                    
                    cell.frequencyLbl.text = "1/week".localized
                }
                else if valFreq == "twice a week"{
                    cell.frequencyLbl.text = "2/week".localized
                }
                else if valFreq == "thrice a week"{
                    cell.frequencyLbl.text = "3/week".localized
                }
                else if valFreq == "once daily"{
                    cell.frequencyLbl.text = "Daily".localized
                }
                else if valFreq == "twice daily"{
                    cell.frequencyLbl.text = "2/Daily".localized
                }
                
                cell.goalLbl.layer.mask = nil
                cell.conditionLbl.layer.mask = nil
                
                let mainDict: NSMutableDictionary = NSMutableDictionary()
                mainDict.setValue(obj.id, forKey: "id")
                mainDict.setValue(obj.frequency, forKey: "frequency")
                mainDict.setValue(obj.time, forKey: "time")
                mainDict.setValue(obj.goal, forKey: "goal")
                
                tempReadArray.add(mainDict)
                
                cell.conditionLbl.textAlignment = .center
                cell.frequencyLbl.textAlignment = .center
                cell.goalLbl.textAlignment = .center
                
                cell.conditionLbl.backgroundColor = Colors.oldMedicationTableBGColor
                cell.frequencyLbl.backgroundColor = Colors.oldMedicationTableBGColor
                cell.goalLbl.backgroundColor = Colors.oldMedicationTableBGColor
                
                cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
                cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
                
                cell.csBtnEditWidth.constant = 2
                cell.btnEdit.setNeedsUpdateConstraints()
                cell.btnEdit.isHidden = true
                
                if(indexPath.row == self.oldArray.count-1)
                {
                    let rect = cell.conditionLbl.bounds
                    
                    var maskPath  = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.conditionLbl.layer.mask = maskLayer
                    
                    
                    let rect1 = cell.goalLbl.bounds
                    
                    var maskPath1  = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath1 = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath1 = UIBezierPath(roundedRect: rect1, byRoundingCorners: ([.bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer1 = CAShapeLayer()
                    maskLayer1.frame = self.view.bounds
                    maskLayer1.path = maskPath1.cgPath
                    cell.goalLbl.layer.mask = maskLayer1
                }
            }
            return cell;
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == self.newTblView)
        {
            return 41
        }
        else
        {
            return 41
        }
    }
    override func viewDidLayoutSubviews() {
        defer {
        }
        do {
            newTblView.separatorInset = UIEdgeInsets.zero
            
            newTblView.layoutMargins = UIEdgeInsets.zero
            
        }     catch let exception {
            print("Exception Occure in LeadDetailViewController viewDidLayoutSubviews: \(exception)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt : IndexPath) {
        defer {
        }
        do {
            if(tableView == self.newTblView)
            {
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
                
            }
            else
            {
                cell.separatorInset = UIEdgeInsets.zero
                cell.layoutMargins = UIEdgeInsets.zero
            }
            
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
            let mainDict: NSMutableDictionary = self.newArray[selectedIndexPath] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            obj.time = conditionsArray[pickerView.selectedRow(inComponent: 0)] as! String
            itemsArray.replaceObject(at:selectedIndex, with: obj)
            let mSectioDict = (self.newArray[selectedIndexPath] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
            self.newArray.replaceObject(at:selectedIndexPath, with: sectionsDict)
            self.view.endEditing(true)
            newTblView.reloadData()
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
