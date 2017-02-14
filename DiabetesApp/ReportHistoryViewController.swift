//
//  ReportHistoryViewController.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire

class ReportHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var noHistoryAvailableLbl: UILabel!
   
    @IBOutlet weak var conditionTxtFld: UITextField!
    
    @IBOutlet weak var conditionView: UIView!
    @IBOutlet weak var tblView: UITableView!
    
   // @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet var pickerViewContainer: UIView!
    
    @IBOutlet weak var conditionDropDownArrow: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var isToday : Bool = true
    var isAll : Bool = true
    var selectedConditionIndex : Int = 0
    
    // MARK:- Var
    var sectionsArray = NSMutableArray()
    var boolArray = NSMutableArray()
    var noOfDays = "0"
    
    var currentLocale: String = ""
    
    @IBOutlet weak var conditionTitle: UILabel!
    var obj = NSDictionary()
    var cellArray = NSArray()
    var formInterval: GTInterval!
    
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = "Report".localized
        selectedConditionIndex = 0
        conditionTitle.text = "CONDITION".localized
        noHistoryAvailableLbl.text = "No Readings Available".localized
        conditionTxtFld.text = conditionsArray[0] as! String
        self.setUI()
        
        currentLocale = NSLocale.current.languageCode!
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            conditionTxtFld.textAlignment = .left
            conditionDropDownArrow.image = UIImage(named:"readinghistoryBack")
        }
        else {
            conditionTxtFld.textAlignment = .right
            conditionDropDownArrow.image = UIImage(named:"history_condition")
        }

        
        //self.addNotifications()
        //getHistory()
        tblView.backgroundColor = UIColor.clear
        conditionTxtFld.text = conditionsArray[0] as? String
        if !UserDefaults.standard.bool(forKey: "groupChat") {
            if selectedUserType == userType.doctor {
                getDoctorReportReadingHistory(condition: conditionsArrayEng[0] as! String)
            }
            else{
                getReportReadingHistory(condition: conditionsArrayEng[0] as! String)
            }
        }
        else {
            
            if selectedUserType == userType.doctor {
                getDoctorSingleReadingHistory(condition: conditionsArrayEng[0] as! String)
            }
                
            else{
                getReportReadingHistory(condition: conditionsArrayEng[0] as! String)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        selectedConditionIndex = 0
       // getDoctorSingleReadingHistory(condition: conditionsArray[0] as! String)
        noOfDays = "0"
        conditionTxtFld.text = conditionsArray[0] as! String
        resetUI()
        
        self.addNotifications()
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kReportHistoryViewScreenName)
        //--------Google Analytics Finish-----
        
         getReportReadingHistory(condition: conditionsArrayEng[0] as! String)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Custom Methods
    func setUI() {
        conditionView.layer.cornerRadius = kButtonRadius
        conditionView.layer.borderColor = Colors.PrimaryColor.cgColor
        conditionView.layer.borderWidth = 1

        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            conditionTxtFld.textAlignment = .left
            conditionDropDownArrow.image = UIImage(named:"readinghistoryBack")
        }
        else {
            conditionTxtFld.textAlignment = .right
            conditionDropDownArrow.image = UIImage(named:"history_condition")
        }
        
        conditionTxtFld.inputView = pickerViewContainer
        
        
    }
    
    func resetUI() {
        if self.sectionsArray.count > 0 {
            tblView.isHidden = false
            noHistoryAvailableLbl.isHidden = true
        }
        else {
            
            tblView.isHidden = true
            noHistoryAvailableLbl.isHidden = false
        }
    }
    
    func addNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.listViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.noOfDaysNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
      /*  if selectedUserType == userType.doctor {
            
          
        }
        else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.listViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.noOfDaysNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
        }*/
        
    }
    
    func refreshSelectedSections(section: Int) {
        
        var value: Bool =  self.boolArray [section] as! Bool
        if value == true {
            value = false
        }
        else {
            value = true
        }
        boolArray.replaceObject(at: section, with: value)
        self.tblView.reloadData()
    }
    
    
    //MARK: - Notifications Methods
    func listViewNotification(notification: NSNotification) {
        
        let dict = notification.object as! NSDictionary
        let receivedCondition = dict["current"]
        
        selectedConditionIndex = conditionsArrayEng.index(of: receivedCondition!)
        pickerView.selectRow(selectedConditionIndex, inComponent: 0, animated: true)
        getDoctorReportReadingHistory(condition: conditionsArrayEng[selectedConditionIndex] as! String)
        conditionTxtFld.text = conditionsArray[selectedConditionIndex] as! String
    }
    
    func noOfDaysNotification(notification: NSNotification) {
        
        noOfDays = String(describing: notification.value(forKey: "object")!)
        print("noOfDays \(noOfDays)")
        let selectedConditionEng = conditionsArrayEng[selectedConditionIndex] as? String
        UserDefaults.standard.setValue(selectedConditionEng, forKey: "currentHistoryCondition")
        //getHistory()
        if selectedUserType == userType.doctor {
            
            if UserDefaults.standard.bool(forKey: "groupChat") {
                getDoctorSingleReadingHistory(condition: selectedConditionEng!)
                
            }else{
                getDoctorReportReadingHistory(condition: selectedConditionEng!)
            }
        }
        else {
            getReportReadingHistory(condition: selectedConditionEng!)
        }
        
        
    }
    
    //MARK: - ToolBarButtons Methods
    @IBAction func ToolBarButtons_Click(_ sender: Any) {
        self.view.endEditing(true)
        if (sender as AnyObject).tag == 0 {
            
            conditionTxtFld.text = conditionsArray[pickerView.selectedRow(inComponent: 0)] as? String
            selectedConditionIndex = pickerView.selectedRow(inComponent: 0) as Int
            let selectedConditionEng = conditionsArrayEng[selectedConditionIndex] as? String
            UserDefaults.standard.setValue(selectedConditionEng, forKey: "currentHistoryCondition")
            // Api Method
            if selectedUserType == userType.doctor {
                
                if UserDefaults.standard.bool(forKey: "groupChat") {
                    
                    getDoctorSingleReadingHistory(condition: selectedConditionEng!)
                }else{
                    getDoctorReportReadingHistory(condition: selectedConditionEng!)
                }
            }
            else {
                getReportReadingHistory(condition: selectedConditionEng! )
            }
        }
    }
    
    
    
    //MARK: - Api Methods
    
    func getDoctorReportReadingHistory(condition: String) {
        
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            sectionsArray.removeAllObjects()
            boolArray.removeAllObjects()
            
            let ConditionVal = conditionsArrayEng[selectedConditionIndex] as? String
            
            let tempString : [String] = ConditionVal!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = ConditionVal!
            }
            
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "userid": patientsID,
                "numDaysBack": noOfDays,
                "condition": newCondition
            ]
            
            if(Int(noOfDays)! < 0)
            {
                return;
            }
            
            if(Int(noOfDays)! > 1 && newCondition != "All conditions")
            {
                isToday = false
                isAll = false
            }
            else if(Int(noOfDays)! > 1 && newCondition=="All conditions")
            {
                isToday = false
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition=="All conditions")
            {
                isToday = true
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition != "All conditions")
            {
                isToday = true
                isAll = false
            }
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getglucoseDaysCondition)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                self.formInterval.end()
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Success -get Reading History Data for Doctor Request Tab" , label:"get Reading History Data Doctor Requet Tab Successfully", value : self.formInterval.intervalAsSeconds())
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        
                        //  print("JSON \(JSON)")
                        
                        
                        /* var dict : NSDictionary = NSDictionary()
                         if self.conditionTxtFld.text == String(conditionsArray[0] as! String) {
                         self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                         if(self.sectionsArray.count>0){
                         dict = NSDictionary(dictionary: self.sectionsArray[0] as! NSDictionary)
                         }
                         
                         }*/
                        if newCondition == String(conditionsArrayEng[0] as! String) {
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            if mainArray.count != 0 {
                           //     self.noHistoryAvailableLbl.isHidden = true
                                self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            }
                        }
                        else {
                            
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            
                            
                            if mainArray.count != 0 {
                               // self.noHistoryAvailableLbl.isHidden = true
                                let mainDict: NSMutableDictionary = NSMutableDictionary()
                                var count = 0
                                let itemsArray = NSMutableArray()
                                for dict in mainArray {
                                    let obj: NSDictionary = dict as! NSDictionary
                                    let dateStr: String = String(describing: obj.allKeys.first!)
                                    if count == 0 {
                                        
                                        if let numDaysInt = Int(self.noOfDays){
                                            let startDate = Calendar.current.date(byAdding: .day, value: -numDaysInt, to: Date())
                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "dd/MM/YYYY"
                                            dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                            let someDate = dateFormatter.string(from: startDate!)
                                            
                                            mainDict.setValue(someDate, forKey: "start_date")
                                        }
                                        else{
                                            mainDict.setValue("", forKey: "start_date")
                                        }
                                        
                                    }
                                    else if count == mainArray.count-1 {
                                        
                                        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd/MM/YYYY"
                                         dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                        let someDate = dateFormatter.string(from: endDate!)
                                        
                                        mainDict.setValue(someDate, forKey: "end_date")
                                        
                                    }
                                    let array: NSArray = NSArray(array: (dict as AnyObject).object(forKey: dateStr) as! NSArray)
                                    itemsArray.addObjects(from: array as! [Any])
                                    
                                    count += 1
                                }
                                mainDict.setObject(itemsArray.copy(), forKey: "items" as NSCopying)
                                self.sectionsArray.add(mainDict)
                            }
                        }
                        
                        for _ in self.sectionsArray {
                            self.boolArray.add(false)
                        }
                        
                        if(Int(self.noOfDays)! == 0)
                        {
                            self.boolArray[0] = true
                        }
                        
                        
                        
                        
                        //                    print(self.sectionsArray)
                        self.tblView.reloadData()
                        self.resetUI()
                    }
                    
                    break
                case .failure(let error):
                    //Google Analytic
                    var strError = ""
                    if(error.localizedDescription.length>0)
                    {
                        strError = error.localizedDescription
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                    print("failure")
                    
                    break
                    
                }
            }
        }
        
    }
    
    func getDoctorSingleReadingHistory(condition: String) {
        
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            sectionsArray.removeAllObjects()
            boolArray.removeAllObjects()
            
            let ConditionVal = conditionsArrayEng[selectedConditionIndex] as? String
            
            let tempString : [String] = ConditionVal!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = ConditionVal!
            }
            
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "userid": patientsID,
                "numDaysBack": noOfDays,
                "condition": newCondition
            ]
            
           // newCondition = "All conditions"
            if(Int(noOfDays)! < 0)
            {
                return;
            }
            
            if(Int(noOfDays)! > 1 && newCondition != "All conditions")
            {
                isToday = false
                isAll = false
            }
            else if(Int(noOfDays)! > 1 && newCondition=="All conditions")
            {
                isToday = false
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition=="All conditions")
            {
                isToday = true
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition != "All conditions")
            {
                isToday = true
                isAll = false
            }
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getglucoseDaysCondition)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                self.formInterval.end()
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Success -get Reading History Data For Doctor Report Group chat" , label:"get Doctor Report Group chat Data Successfully", value : self.formInterval.intervalAsSeconds())
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        
                        //  print("JSON \(JSON)")
                        
                        
                        /* var dict : NSDictionary = NSDictionary()
                         if self.conditionTxtFld.text == String(conditionsArray[0] as! String) {
                         self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                         if(self.sectionsArray.count>0){
                         dict = NSDictionary(dictionary: self.sectionsArray[0] as! NSDictionary)
                         }
                         
                         }*/
                        if newCondition == String(conditionsArrayEng[0] as! String) {
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            if mainArray.count != 0 {
                               // self.noHistoryAvailableLbl.isHidden = true
                                self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            }
                        }
                        else {
                            
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            
                            
                            if mainArray.count != 0 {
                                //self.noHistoryAvailableLbl.isHidden = true
                                let mainDict: NSMutableDictionary = NSMutableDictionary()
                                var count = 0
                                let itemsArray = NSMutableArray()
                                for dict in mainArray {
                                    let obj: NSDictionary = dict as! NSDictionary
                                    let dateStr: String = String(describing: obj.allKeys.first!)
                                    if count == 0 {
                                        
                                        if let numDaysInt = Int(self.noOfDays){
                                            let startDate = Calendar.current.date(byAdding: .day, value: -numDaysInt, to: Date())
                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "dd/MM/YYYY"
                                             dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                            let someDate = dateFormatter.string(from: startDate!)
                                            
                                            mainDict.setValue(someDate, forKey: "start_date")
                                        }
                                        else{
                                            mainDict.setValue("", forKey: "start_date")
                                        }
                                        
                                    }
                                    else if count == mainArray.count-1 {
                                        
                                        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd/MM/YYYY"
                                        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                        let someDate = dateFormatter.string(from: endDate!)
                                        
                                        mainDict.setValue(someDate, forKey: "end_date")
                                        
                                    }
                                    let array: NSArray = NSArray(array: (dict as AnyObject).object(forKey: dateStr) as! NSArray)
                                    itemsArray.addObjects(from: array as! [Any])
                                    
                                    count += 1
                                }
                                mainDict.setObject(itemsArray.copy(), forKey: "items" as NSCopying)
                                self.sectionsArray.add(mainDict)
                            }
                        }
                        
                        for _ in self.sectionsArray {
                            self.boolArray.add(false)
                        }
                        
                        if(Int(self.noOfDays)! == 0)
                        {
                            self.boolArray[0] = true
                        }
                        
                        self.tblView.reloadData()
                        self.resetUI()
                    }
                    
                    break
                case .failure(let error):
                    //Google Analytic
                    var strError = ""
                    if(error.localizedDescription.length>0)
                    {
                        strError = error.localizedDescription
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                    print("failure")
                    
                    break
                    
                }
            }
        }

    }
    
    
    func getReportReadingHistory(condition: String) {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            sectionsArray.removeAllObjects()
            boolArray.removeAllObjects()
            
            let ConditionVal = conditionsArrayEng[selectedConditionIndex] as? String
            
            let tempString : [String] = ConditionVal!.components(separatedBy: " ")
            var newCondition : String = ""
            if tempString[0] == "Before"{
                
                newCondition = "Pre "+tempString[1]
            }
            else if tempString[0] == "After"{
                newCondition = "Post "+tempString[1]
            }
            else{
                newCondition = ConditionVal!
            }
            
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "userid": patientsID,
                "numDaysBack": noOfDays,
                "condition": newCondition
            ]
            
            if(Int(noOfDays)! < 0)
            {
                return;
            }
            
            if(Int(noOfDays)! > 1 && newCondition != "All conditions")
            {
                isToday = false
                isAll = false
            }
            else if(Int(noOfDays)! > 1 && newCondition=="All conditions")
            {
                isToday = false
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition=="All conditions")
            {
                isToday = true
                isAll = true
            }
            else if(Int(noOfDays)! <= 1 && newCondition != "All conditions")
            {
                isToday = true
                isAll = false
            }
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getglucoseDaysCondition)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                self.formInterval.end()
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Success -get Reading History Data For Educator Report" , label:"get Educator Report  Data Successfully", value : self.formInterval.intervalAsSeconds())
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        
                        //  print("JSON \(JSON)")
                        
                        
                        /* var dict : NSDictionary = NSDictionary()
                         if self.conditionTxtFld.text == String(conditionsArray[0] as! String) {
                         self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                         if(self.sectionsArray.count>0){
                         dict = NSDictionary(dictionary: self.sectionsArray[0] as! NSDictionary)
                         }
                         
                         }*/
                        if newCondition == String(conditionsArrayEng[0] as! String) {
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            if mainArray.count != 0 {
                               // self.noHistoryAvailableLbl.isHidden = true
                                self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            }
                        }
                        else {
                            
                            let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                            
                            
                            if mainArray.count != 0 {
                               // self.noHistoryAvailableLbl.isHidden = true
                                let mainDict: NSMutableDictionary = NSMutableDictionary()
                                var count = 0
                                let itemsArray = NSMutableArray()
                                for dict in mainArray {
                                    let obj: NSDictionary = dict as! NSDictionary
                                    let dateStr: String = String(describing: obj.allKeys.first!)
                                    if count == 0 {
                                        
                                        if let numDaysInt = Int(self.noOfDays){
                                            let startDate = Calendar.current.date(byAdding: .day, value: -numDaysInt, to: Date())
                                            
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "dd/MM/YYYY"
                                            dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                            let someDate = dateFormatter.string(from: startDate!)
                                            
                                            mainDict.setValue(someDate, forKey: "start_date")
                                        }
                                        else{
                                            mainDict.setValue("", forKey: "start_date")
                                        }
                                        
                                    }
                                    else if count == mainArray.count-1 {
                                        
                                        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "dd/MM/YYYY"
                                        dateFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                                        let someDate = dateFormatter.string(from: endDate!)
                                        
                                        mainDict.setValue(someDate, forKey: "end_date")
                                        
                                    }
                                    let array: NSArray = NSArray(array: (dict as AnyObject).object(forKey: dateStr) as! NSArray)
                                    itemsArray.addObjects(from: array as! [Any])
                                    
                                    count += 1
                                }
                                mainDict.setObject(itemsArray.copy(), forKey: "items" as NSCopying)
                                self.sectionsArray.add(mainDict)
                            }
                        }
                        
                        for _ in self.sectionsArray {
                            self.boolArray.add(false)
                        }
                        
                        if(Int(self.noOfDays)! == 0)
                        {
                            self.boolArray[0] = true
                        }
                        
                        
                        
                        
                        //                    print(self.sectionsArray)
                        self.tblView.reloadData()
                        self.resetUI()
                    }
                    
                    break
                case .failure(let error):
                    //Google Analytic
                    var strError = ""
                    if(error.localizedDescription.length>0)
                    {
                        strError = error.localizedDescription
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getglucoseDaysCondition) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                    print("failure")
                    
                    break
                    
                }
            }
        }

    }
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let bool : Bool = boolArray[section] as! Bool
            if bool == true {
                
                let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
                let dateStr: String = String(describing: dict.allKeys.first!)
                let array: NSArray = NSArray(array: dict.object(forKey: dateStr) as! NSArray)
                
                return array.count
            }
            else {
                return 0
            }
        }
            
        else {
            let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
            
            if dict.object(forKey: "items") != nil{
                 let array: NSArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
                return array.count

            }
           return 0
            
        }
        
        // return (bool == true ? 4 : 0)
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let dict: NSDictionary = sectionsArray[indexPath.section] as! NSDictionary
            
            if conditionTxtFld.text == String(conditionsArray[0] as! String) {
                let dateStr: String = String(describing: dict.allKeys.first!)
                cellArray = NSArray(array: dict.object(forKey: dateStr) as! NSArray)
                obj = cellArray[indexPath.row] as! NSDictionary
            }
            else {
                cellArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
                obj = cellArray[indexPath.row] as! NSDictionary
            }
            
            let cell: HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell")! as! HistoryTableViewCell
            
            if(isToday && isAll || !isToday && isAll)
            {
                
                cell.readingLbl.text = "\(obj.value(forKey: "reading")!) mg/dl"
                
                if (obj.value(forKey: "reading") as? Int)! > 180{
                    cell.readingLbl.textColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 238.0/255.0, alpha: 1.0)
                }
                else if (obj.value(forKey: "reading") as? Int)! < 70{
                    cell.readingLbl.textColor = Colors.DHPinkRed
                }
                else{
                    cell.readingLbl.textColor = Colors.PrimaryColor
                }
                
                var conditionString = String(describing: obj.value(forKey: "condition")!)
                
                var tempString : [String] = conditionString.components(separatedBy: " ")
                if tempString[0] == "Pre"
                {
                    conditionString = "Before "+tempString[1]
                }
                else if tempString[0] == "Post"
                {
                    conditionString = "After "+tempString[1]
                }
                
                
                var outStr : String = ""
                
                /* if currentLocale == "en"
                 {
                 let inFormatter = DateFormatter()
                 inFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                 inFormatter.dateFormat = "hh:mm a"
                 
                 let outFormatter = DateFormatter()
                 outFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                 outFormatter.dateFormat = "HH:mm"
                 
                 let date = inFormatter.date(from: String(describing: obj.value(forKey: "readingtime")!))
                 outStr = outFormatter.string(from: date!)
                 }
                 else{*/
                outStr = String(describing: obj.value(forKey: "readingtime")!)
                // }
                
                let index = conditionsArrayEng.index(of: conditionString)
                if(index != -1)
                {
                    cell.dateLbl.text = conditionsArray[index] as? String
                }
                else{
                    cell.dateLbl.text = String(describing: obj.value(forKey: "condition")!)
                }
                
                
                // cell.dateLbl.text = String(describing: obj.value(forKey: "condition")!)
                cell.conditionLbl.text = outStr
                cell.conditionLbl.textColor = Colors.PrimaryColor
                cell.commentLabel.text = String(describing: obj.value(forKey: "comment")!)
                //            cell.selectionStyle = .default
                
            }
            else{
                cell.readingLbl.text = "\(obj.value(forKey: "reading")!) mg/dl"
                
                if (obj.value(forKey: "reading") as? Int)! > 180{
                    cell.readingLbl.textColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 238.0/255.0, alpha: 1.0)
                }
                else if (obj.value(forKey: "reading") as? Int)! < 70{
                    cell.readingLbl.textColor = Colors.DHPinkRed
                }
                else{
                    cell.readingLbl.textColor = Colors.PrimaryColor
                }
                
                var conditionString = String(describing: obj.value(forKey: "condition")!)
                
                var tempString : [String] = conditionString.components(separatedBy: " ")
                if tempString[0] == "Pre"
                {
                    conditionString = "Before "+tempString[1]
                }
                else if tempString[0] == "Post"
                {
                    conditionString = "After "+tempString[1]
                }
                let index = conditionsArrayEng.index(of: conditionString)
                
                var outStrCondition : String = ""
                var outStrReadingTime : String = ""
                /* if currentLocale == "ar"
                 {
                 let inFormatter = DateFormatter()
                 inFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                 inFormatter.dateFormat = "hh:mm a"
                 
                 let outFormatter = DateFormatter()
                 outFormatter.locale = NSLocale(localeIdentifier: "en") as Locale!
                 outFormatter.dateFormat = "HH:mm"
                 
                 var date = inFormatter.date(from: String(describing: obj.value(forKey: "condition")!))
                 outStrCondition = outFormatter.string(from: date!)
                 
                 //for reading time with date and day of the week
                 inFormatter.dateFormat = "d EEEE"
                 outFormatter.dateFormat = "d EEEE"
                 
                 let tempString : String = String(describing: obj.value(forKey: "readingtime")!)
                 let tempSplits : [String] = tempString.components(separatedBy: " ")
                 let result : String = tempSplits[0]+" "+tempSplits[2]
                 let reading = inFormatter.date(from: result)
                 
                 outStrReadingTime = outFormatter.string(from: reading!)
                 
                 }
                 else{*/
                outStrCondition = String(describing: obj.value(forKey: "condition")!)
                
                let tempStringRead : String = String(describing: obj.value(forKey: "readingtime")!)
                let tempSplits : [String] = tempStringRead.components(separatedBy: " ")
                let result : String = tempSplits[0]+tempSplits[1]+" "+tempSplits[2]
                outStrReadingTime = result
                //  }
                
                cell.dateLbl.text = outStrReadingTime
                cell.dateLbl.textColor = Colors.PrimaryColor
                cell.conditionLbl.text = outStrCondition
                cell.conditionLbl.textColor = Colors.PrimaryColor
                cell.commentLabel.text = String(describing: obj.value(forKey: "comment")!)
            }
            let clearView = UIView()
            clearView.backgroundColor = UIColor.clear // Whatever color you like
            UITableViewCell.appearance().selectedBackgroundView = clearView
            // cell.selectionStyle = .none
            
            //        cell.readingLbl.text = "\(obj.value(forKey: "reading")!) mg/dl"
            //        cell.dateLbl.text = String(describing: obj.value(forKey: "created")!)
            //        cell.conditionLbl.text = String(describing: obj.value(forKey: "condition")!)
            return cell
            
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arr =  cellArray .object(at: indexPath.row)
        
        let dict =   arr as! NSDictionary
        
        //print("\(dict.value(forKey: "reading")!) mg/dl")
        self.present(UtilityClass.displayAlertMessage(message: "\(dict.value(forKey: "reading")!) mg/dl".localized, title: ""), animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        headerView.backgroundColor = UIColor.clear
        let topView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        topView.backgroundColor = Colors.historyHeaderColor
        //        topView.layer.shadowColor = UIColor.black.cgColor
        //        topView.layer.shadowOpacity = 1
        //        topView.layer.shadowOffset = CGSize.zero
        //        topView.layer.shadowRadius = 10
        //        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 10
        let lbl: UILabel = UILabel(frame: CGRect(x: 40, y: 5, width: tableView.frame.size.width-80, height: 35))
        let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
        
        lbl.textColor = UIColor.white
        lbl.font = Fonts.HistoryHeaderFont
        headerView.addSubview(topView)
        headerView.addSubview(lbl)
        headerView.tag = section
        
        
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let dateStr: String = String(describing: dict.allKeys.first!)
            lbl.text = dateStr
            
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureReconizer:)))
            headerView.addGestureRecognizer(tapGesture)
            
            var arrowImgView = UIImageView()
            
            if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                
                arrowImgView = UIImageView(frame: CGRect(x:17 , y: 14, width: 17, height: 17))
                headerView.addSubview(arrowImgView)
            }
            else {
                
                arrowImgView = UIImageView(frame: CGRect(x:headerView.frame.size.width-27 , y: 14, width: 17, height: 17))
                headerView.addSubview(arrowImgView)
            }
            
          //  let arrowImgView: UIImageView = UIImageView(frame: CGRect(x:headerView.frame.size.width-27 , y: 14, width: 17, height: 17))
          //  headerView.addSubview(arrowImgView)
            
            let bool : Bool = boolArray[section] as! Bool
            if bool == true {
                let bottomView: UIView = UIView(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 10))
                bottomView.backgroundColor = Colors.historyHeaderColor
                headerView.addSubview(bottomView)
                
                arrowImgView.image = UIImage(named: "collapseArrow")
                
            }
            else {
               // arrowImgView.image = UIImage(named: "expandArrow")
                
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    arrowImgView.image = UIImage(named: "expandArrowBack")
                }
                else {
                    arrowImgView.image = UIImage(named: "expandArrow")
                }
                
            }
        }
        else {
            let startDate = (dict.value(forKey: "start_date"))
            let endDate = (dict.value(forKey: "end_date"))
            
            if startDate != nil && endDate != nil{
                
                /*if currentLocale == "ar"{
                
                    
                    
                    let inFormatter = DateFormatter()
                    inFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    inFormatter.dateFormat = "d-M-yyyy HH:mm:ss"
                    
                    let outFormatter = DateFormatter()
                    outFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    outFormatter.dateFormat = "d-MM-YYYY"
                    
                    let startDateStr : String = String(describing: dict.value(forKey: "start_date")!)
                    let startDateStringTime = "\(startDateStr) 00:00:00"
                    let startdate = inFormatter.date(from: startDateStringTime)
                    let startDateString = outFormatter.string(from: startdate!)
                    
                    let endDateStr : String = String(describing: dict.value(forKey: "end_date")!)
                    let endDateStringTime = "\(endDateStr) 00:00:00"
                    let enddate = inFormatter.date(from: endDateStringTime)
                    let endDateString = outFormatter.string(from: enddate!)
                    
                    lbl.text = startDateString+"  -  "+endDateString
                }
                else{*/
                    lbl.text = "\(String(describing: dict.value(forKey: "start_date")!)) - \(String(describing: dict.value(forKey: "end_date")!))"
               // }
            }
            else if startDate != nil {
                
                /*if currentLocale == "ar"
                {
                    let inFormatter = DateFormatter()
                    inFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    inFormatter.dateFormat = "d-M-yyyy HH:mm:ss"
                    
                    let outFormatter = DateFormatter()
                    outFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    outFormatter.dateFormat = "d-MM-YYYY"
                    
                    let startDateStr : String = String(describing: dict.value(forKey: "start_date")!)
                    let startDateStringTime = "\(startDateStr) 00:00:00"
                    var startdate = inFormatter.date(from: startDateStringTime)
                    let startDateString = outFormatter.string(from: startdate!)
                    
                    lbl.text = startDateString
                }
                else{*/
                    lbl.text = "\(String(describing: dict.value(forKey: "start_date")!))"
                //}
            }
            else if endDate != nil {
                
               /* if currentLocale == "ar"
                {
                    let inFormatter = DateFormatter()
                    inFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    inFormatter.dateFormat = "d-M-yyyy HH:mm:ss"
                    
                    let outFormatter = DateFormatter()
                    outFormatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
                    outFormatter.dateFormat = "d-MM-YYYY"
                    
                    let endDateStr : String = String(describing: dict.value(forKey: "end_date")!)
                    let endDateStringTime = "\(endDateStr) 00:00:00"
                    var enddate = inFormatter.date(from: endDateStringTime)
                    let endDateString = outFormatter.string(from: enddate!)
                    
                    lbl.text = endDateString
                }
                else{*/
                    lbl.text = "\(String(describing: dict.value(forKey: "end_date")!))"
               // }
            }
            else{
                lbl.text = ""
            }

            
            let bottomView: UIView = UIView(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 10))
            bottomView.backgroundColor = Colors.historyHeaderColor
            headerView.addSubview(bottomView)
        }
        
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    //MARK: - Header Tap Gesture
    func tapHeader(gestureReconizer: UITapGestureRecognizer){
        
        if gestureReconizer.view != nil {
            
            self.refreshSelectedSections(section: (gestureReconizer.view?.tag)!)
            
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
