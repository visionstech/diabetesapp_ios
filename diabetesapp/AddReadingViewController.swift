//
//  AddReadingViewController.swift
//  DiabetesApp
//
//  Created by Carisa Antariksa on 2/12/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import  SVProgressHUD
import Alamofire


class AddReadingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate  {
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak  var pickerTimingView: UIPickerView!
    @IBOutlet weak  var pickerFreqView: UIPickerView!
    
    @IBOutlet weak var pickerDoneButton: UIBarButtonItem!
    @IBOutlet weak var pickerCancelButton: UIBarButtonItem!
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet var pickerViewInner: UIView!
    
    @IBOutlet weak var btnOkPicker: UIButton!
    @IBOutlet weak var btnCancelPicker: UIButton!
    
    @IBOutlet weak var btnCancelFreqPicker: UIButton!
    @IBOutlet weak var btnOkFreqPicker: UIButton!
    
    var editReadArray = NSMutableArray()
    var tempReadArray = NSMutableArray()
 
    
    var isEditReading : Bool = false
    
    var formInterval: GTInterval!
    var objCarePlanFrequencyObj = CarePlanFrequencyObj()
    let loggedInUserID : String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
    var newReadArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        pickerViewInner.layer.cornerRadius = 10
        pickerViewInner.layer.borderColor = Colors.PrimaryColor.cgColor
        pickerViewInner.layer.borderWidth = 1
        
        pickerViewContainer.layer.borderColor = Colors.PrimaryColor.cgColor
        pickerViewContainer.layer.borderWidth = 1
        
        
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = pickerViewContainer.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pickerViewContainer.insertSubview(blurEffectView, belowSubview: pickerViewInner)
       
        
    }
    
    func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- PickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == self.pickerTimingView)
        {
            return conditionsArray.count
        }
        else
        {
            return frequnecyArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == self.pickerTimingView)
        {
            return conditionsArray[row] as? String
        }
        else
        {
            return frequnecyArray[row] as? String
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if(pickerView == self.pickerTimingView)
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    //MARK:- UIBUtton Delegate Methods
    
    @IBAction func btnTiming_Clicked(_ sender: Any) {
        let window = UIApplication.shared.keyWindow
        pickerViewContainer.setY(y: 64)
        pickerViewContainer.setHeight(height: UIScreen.main.bounds.height-64)
        pickerViewContainer.setWidth(width : UIScreen.main.bounds.width)
        
        //Check pickerViewContainer already on window or not, if not then add on window
        if !pickerViewContainer.isDescendant(of: window!) {
            window?.addSubview(pickerViewContainer)
        }
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        self.tblView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
        self.view.endEditing(true)
        self.pickerTimingView.isHidden = false
        self.pickerFreqView.isHidden = true
        self.btnCancelFreqPicker.isHidden = true
        self.btnOkFreqPicker.isHidden = true
        self.btnCancelPicker.isHidden = false
        self.btnOkPicker.isHidden = false
        self.pickerTimingView.tag = 1
        self.btnOkPicker.tag = 1
        self.btnCancelPicker.tag = 1
        
        if(self.isEditReading)
        {
            let index = conditionsArrayEng.index(of: self.objCarePlanFrequencyObj.time.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            if(index <= conditionsArrayEng.count)
            {
                pickerTimingView.selectRow(index, inComponent: 0, animated: true)
            }
            else
            {
                pickerTimingView.selectRow(0, inComponent: 0, animated: true)
            }
        }
        
        showOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func btnFrequency_Clicked(_ sender: Any) {
        let window = UIApplication.shared.keyWindow
        pickerViewContainer.setY(y: 64)
        pickerViewContainer.setHeight(height: UIScreen.main.bounds.height-64)
        pickerViewContainer.setWidth(width : UIScreen.main.bounds.width)
        
        //Check pickerViewContainer already on window or not, if not then add on window
        if !pickerViewContainer.isDescendant(of: window!) {
            window?.addSubview(pickerViewContainer)
        }
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        self.tblView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
        self.view.endEditing(true)
        self.pickerTimingView.isHidden = true
        self.pickerFreqView.isHidden = false
        self.btnCancelFreqPicker.isHidden = false
        self.btnOkFreqPicker.isHidden = false
        self.btnCancelPicker.isHidden = true
        self.btnOkPicker.isHidden = true
        self.pickerFreqView.tag = 1
        self.btnOkFreqPicker.tag = 1
        self.btnCancelFreqPicker.tag = 1
        if(self.isEditReading)
        {
            let index = frequnecyArray.index(of: self.objCarePlanFrequencyObj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
            if(index <= frequnecyArray.count)
            {
                pickerFreqView.selectRow(index, inComponent: 0, animated: true)
            }
            else
            {
                pickerFreqView.selectRow(0, inComponent: 0, animated: true)
            }
        }
        showOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func btnSaveReading_Clicked(_ sender: Any) {
          self.view.endEditing(true)
        let cell = self.tblView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! AddReadingCell
        self.objCarePlanFrequencyObj.goal = cell.txtGoal.text!
        
        if(self.objCarePlanFrequencyObj.time .isEmpty)
        {
            self.present(UtilityClass.displayAlertMessage(message: "Please Select the timing".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
            //Google Analytic
            GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Reading ", action:"Add Reading" , label:"Please Select the timing")
            SVProgressHUD.dismiss()
        }
        else if(self.objCarePlanFrequencyObj.frequency .isEmpty)
        {
            self.present(UtilityClass.displayAlertMessage(message: "Please Select the frequency".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
            //Google Analytic
            GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Reading ", action:"Add Reading" , label:"Please Select the frequency")
            SVProgressHUD.dismiss()
        }
        else if(self.objCarePlanFrequencyObj.goal .isEmpty)
        {
            self.present(UtilityClass.displayAlertMessage(message: "Please Enter the Goal".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
            //Google Analytic
            GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Reading ", action:"Add Reading" , label:"Please Enter the Goal")
            SVProgressHUD.dismiss()
        }
        else
        {
                if(self.isEditReading)
                {
                    if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                        self.objCarePlanFrequencyObj.isEdit = false
                       
                        
                        let arr : NSArray = UserDefaults.standard.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
                        editReadArray = NSMutableArray(array: arr)
                        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                        let mainDict: NSMutableDictionary = NSMutableDictionary()
                        mainDict.setValue(self.objCarePlanFrequencyObj.id, forKey: "id")
                        mainDict.setValue(self.objCarePlanFrequencyObj.frequency, forKey: "frequency")
                        mainDict.setValue(self.objCarePlanFrequencyObj.time, forKey: "time")
                        mainDict.setValue(self.objCarePlanFrequencyObj.goal, forKey: "goal")
                        mainDict.setValue(loggedInUserID, forKey: "updatedBy")
                        mainDict.setValue(loggedInUserName, forKey: "updatedByName")

                        
                        if editReadArray.count > 0 {
                            for i in 0..<self.editReadArray.count {
                                let id: String = (editReadArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                                print(id)
                                if id == self.objCarePlanFrequencyObj.id {
                                    editReadArray.replaceObject(at:i, with: mainDict)
                                    UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
                                    UserDefaults.standard.synchronize()
                                    break
                                }
                            }
                            editReadArray.add(mainDict)
                        }
                        else {
                            editReadArray.add(mainDict)
                        }
                        
                        if tempReadArray.count >= newReadArray.count{
                            let first = tempReadArray.count - newReadArray.count
                            let finalArray = NSMutableArray();
                            for i in first..<(first+newReadArray.count){
                                finalArray.add(tempReadArray[i])
                            }
                            print("Final array")
                            print(finalArray)
                            UserDefaults.standard.set(finalArray, forKey: "updateReadingCareArray")
                            UserDefaults.standard.synchronize()
                            
                        }
                        // Update tempReadingCareArray when Edit Reading while update on report
                        //  ---- Start ----
                        
                        let myTempReadingData = NSMutableArray()
                        for i in 0..<self.newReadArray.count {
                            let objCarPlan = (newReadArray[i] as? CarePlanFrequencyObj)!
                            let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                            let mainDictEdit: NSMutableDictionary = NSMutableDictionary()
                            mainDictEdit.setValue(objCarPlan.id, forKey: "id")
                            mainDictEdit.setValue(objCarPlan.frequency, forKey: "frequency")
                            mainDictEdit.setValue(objCarPlan.time, forKey: "time")
                            mainDictEdit.setValue(objCarPlan.goal, forKey: "goal")
                            mainDict.setValue(loggedInUserID, forKey: "updatedBy")
                            mainDict.setValue(loggedInUserName, forKey: "updatedByName")
                            myTempReadingData.add(mainDictEdit)
                            
                        }
                        
                        UserDefaults.standard.setValue(myTempReadingData, forKey: "tempReadingCareArray")
                        UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
                        UserDefaults.standard.synchronize()
                        
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil)
                        })
                        //  ---- End ----
                    }
                    else
                    {

                    self.updatecareplanData()
                    }
                }
                else
                {
                    if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                        let arr : NSArray = UserDefaults.standard.array(forKey: "currentAddReadingArray")! as [Any] as NSArray
                        newReadArray = NSMutableArray(array: arr)
                        
                        let mainDict: NSMutableDictionary = NSMutableDictionary()
                        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                        mainDict.setValue(self.objCarePlanFrequencyObj.id, forKey: "id")
                        mainDict.setValue(self.objCarePlanFrequencyObj.frequency, forKey: "frequency")
                        mainDict.setValue(self.objCarePlanFrequencyObj.time, forKey: "time")
                        mainDict.setValue(self.objCarePlanFrequencyObj.goal, forKey: "goal")
                        mainDict.setValue(loggedInUserID, forKey: "updatedBy")
                        mainDict.setValue(loggedInUserName, forKey: "updatedByName")
                        mainDict.setValue(newReadArray.count+1, forKey:"readindex")
                        newReadArray.add(mainDict)
                        
                        UserDefaults.standard.setValue(newReadArray, forKey: "currentAddReadingArray")
                        UserDefaults.standard.synchronize()
                        
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil)
                        })
                    }
                    else{
                    self.addnewreading()
                    }
                }
        }
    }
    @IBAction func btnCloseReading_Clicked(_ sender: Any) {
          self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelFreqBtn_Clicked(_ sender: Any) {
        hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func okFreqBtn_Clicked(_ sender: Any) {
      
        let cell = self.tblView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! AddReadingCell
        
        self.objCarePlanFrequencyObj.frequency = (frequencyArrayEng[pickerFreqView.selectedRow(inComponent: 0)] as? String)!
        
        cell.txtFrequency.text =  (frequnecyArray[pickerFreqView.selectedRow(inComponent: 0)] as? String)!
       /* let valFreq = self.objCarePlanFrequencyObj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        
        if valFreq == "once a week"{
            cell.txtFrequency.text = "1/week".localized
        }
        else if valFreq == "twice a week"{
            cell.txtFrequency.text = "2/week".localized
        }
        else if valFreq == "thrice a week"{
            cell.txtFrequency.text = "3/week".localized
        }
        else if valFreq == "once daily"{
            cell.txtFrequency.text = "Daily".localized
        }
        else if valFreq == "twice daily"{
            cell.txtFrequency.text = "2/Daily".localized
        }*/
        hideOverlay(overlayView: pickerViewContainer)
        
    }
    @IBAction func cancelBtn_Clicked(_ sender: Any){
          self.view.endEditing(true)
        hideOverlay(overlayView: pickerViewContainer)
    }

    @IBAction func okBtn_Clicked(_ sender: Any) {
        
        let cell = self.tblView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! AddReadingCell
        
        self.objCarePlanFrequencyObj.time = (conditionsArray[pickerTimingView.selectedRow(inComponent: 0)] as? String)!
        
        cell.txtTiming.text = conditionsArray[pickerTimingView.selectedRow(inComponent: 0)] as? String
        
        hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func btnDelete_Clicked(_ sender: Any) {
          self.view.endEditing(true)
        self.deleteReading()
    }
    // MARK: - Editable TableView TextField
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //check this
        let cell = self.tblView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! AddReadingCell
        if(textField == cell.txtGoal)
        {
            self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 80 , 0)
            self.tblView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
        }
    }
    private func textFieldDidEndEditing(textField: UITextField, inRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        self.tblView.scrollToRow(at: NSIndexPath(row: 0, section: 0) as IndexPath, at: .top, animated: true)
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let cell = self.tblView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! AddReadingCell
        if(textField == cell.txtGoal)
        {
            self.objCarePlanFrequencyObj.goal = cell.txtGoal.text!
        }
    }
    
//MARK: - Private Overlay Function
private func showOverlay(overlayView: UIView) {
    overlayView.alpha = 0.0
    overlayView.isHidden = false
    
    UIView.animate(withDuration: 0.15) {
        overlayView.alpha = 1.0
    }
}

private func hideOverlay(overlayView: UIView) {
    UIView.animate(withDuration: 0.15, animations: {
        overlayView.alpha = 0.0
    }) { _ in
        overlayView.isHidden = true
    }
}
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell : AddReadingCell = tableView.dequeueReusableCell(withIdentifier: "addreadingcell") as! AddReadingCell
    
    cell.selectionStyle = .none
    cell.txtGoal.tag = indexPath.row
    cell.txtTiming.tag = indexPath.row
    cell.txtFrequency.tag = indexPath.row
    cell.txtGoal.delegate = self
    
    cell.txtGoal.attributedPlaceholder = NSAttributedString(string: "SA_STR_ENTER_GOAL".localized,
                                                            attributes: [NSForegroundColorAttributeName: Colors.DefaultplaceHolderColor])
    cell.txtTiming.attributedPlaceholder = NSAttributedString(string: "SA_STR_ENTER_TIMING".localized,
                                                            attributes: [NSForegroundColorAttributeName: Colors.DefaultplaceHolderColor])
    cell.txtFrequency.attributedPlaceholder = NSAttributedString(string: "SA_STR_ENTER_FREQUNECY".localized,
                                                            attributes: [NSForegroundColorAttributeName: Colors.DefaultplaceHolderColor])
    
    if(self.isEditReading)
    {
        cell.txtGoal.text = self.objCarePlanFrequencyObj.goal
        cell.txtTiming.text = self.objCarePlanFrequencyObj.time
        cell.txtFrequency.text = self.objCarePlanFrequencyObj.frequency
        cell.deleteVW.isHidden = false
    }
    else
    {
        cell.txtGoal.text = ""
        cell.txtTiming.text = ""
        cell.txtFrequency.text = ""
        cell.deleteVW.isHidden = true
    }
    
    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
    cell.txtGoal.textAlignment = .right
    cell.txtFrequency.textAlignment = .right
    cell.txtTiming.textAlignment = .right
    }
    else
    {
        cell.txtGoal.textAlignment = .left
        cell.txtFrequency.textAlignment = .left
        cell.txtTiming.textAlignment = .left
    }
  
    
    return cell
}

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 210
    }
    // MARK: - web service calling
    func deleteReading() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        let parameters: Parameters = [
            "userid": patientsID,
            "readingid" : self.objCarePlanFrequencyObj.id,
            "updatedBy":loggedInUserID,
            "updatedByName":loggedInUserName
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        SVProgressHUD.show(withStatus: "SA_STR_DELETE_READING".localized)
        //"\(baseUrl)\(ApiMethods.deletecareplanReadings)"
        
        Alamofire.request("\(baseUrl)\(ApiMethods.deletecareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                if JSON["result"] != nil {
                    self.present(UtilityClass.displayAlertMessage(message: JSON.value(forKey:"message") as! String, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                    
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Reading Calling", action:"Fail - Web API Calling" , label:JSON.value(forKey:"message") as! String, value : self.formInterval.intervalAsSeconds())
                    
                    SVProgressHUD.dismiss()
                }
                else
                {
                    switch response.result
                    {
                    case .success:
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showSuccess(withStatus: "Deleted Successfully".localized, maskType: SVProgressHUDMaskType.clear)
                        //Google Analytic
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Success - Delete care Plan Reading" , label:"Care Plan Data Deleted Successfully", value : self.formInterval.intervalAsSeconds())
                        
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil )
                        })
                        print("Validation Successful")
                        break
                    case .failure(let error):
                        print("failure")
                        var strError = ""
                        if(error.localizedDescription.length>0)
                        {
                            strError = error.localizedDescription
                        }
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Fail - Web API Calling Reading" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                        SVProgressHUD.dismiss()
                        break
                        
                    }
                }
            }
        }
    }
    
    func updatecareplanData()
    {
        UIApplication.shared.beginIgnoringInteractionEvents()
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        let parameters: Parameters = [
            "readingid": self.objCarePlanFrequencyObj.id,
            "userid": patientsID,
            "readingFreq" : self.objCarePlanFrequencyObj.frequency,
            "readingTime" : self.objCarePlanFrequencyObj.time,
            "readingGoal" : self.objCarePlanFrequencyObj.goal,
            "updatedBy" : loggedInUserID,
            "updatedByName":loggedInUserName
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
       SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        //"\(baseUrl)\(ApiMethods.updatecareplanReadings)"
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            switch response.result {
            case .success:
                 SVProgressHUD.dismiss()
                SVProgressHUD.showSuccess(withStatus: "Updated Successfully".localized, maskType: SVProgressHUDMaskType.clear)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplanReadings) Calling", action:"Success -Update care Plan" , label:"Care Plan Data Updated Successfully", value : self.formInterval.intervalAsSeconds())
                
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil)
                })
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplanReadings) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                SVProgressHUD.dismiss()
                break
                
            }
        }
    }
    func addnewreading()
    {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        let newConditionIndex = conditionsArray.index(of: self.objCarePlanFrequencyObj.time)
       // let newFrequencyIndex = frequnecyArray.index(of: self.objCarePlanFrequencyObj.frequency)
        let parameters: Parameters = [
            "userid": patientsID,
            "readingFreq" : self.objCarePlanFrequencyObj.frequency,
            "readingTime" : conditionsArrayEng[newConditionIndex],
            "readingGoal" : self.objCarePlanFrequencyObj.goal,
            "updatedBy":loggedInUserID,
            "updatedByName":loggedInUserName
        ]
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //"\(baseUrl)\(ApiMethods.addcareplanReadings)"
        Alamofire.request("\(baseUrl)\(ApiMethods.addcareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            
            switch response.result {
            case .success:
                //Google Analytic
                
                
                
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.addcareplanReadings) Calling", action:"Success -Add Care Plan Data" , label:"Add Care Plan Reading Data added Successfully", value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.showSuccess(withStatus: "Reading Added", maskType: SVProgressHUDMaskType.clear)
                
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil )
                })
                
                break
            case .failure(let error):
                print("failure")
                //Google Analytic
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.addcareplanReadings) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                break
                
            }
        }
        
    }
}
