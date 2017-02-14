//
//  CarePlanReadingViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class CarePlanReadingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var pickerDoneButton: UIBarButtonItem!
    @IBOutlet weak var pickerCancelButton: UIBarButtonItem!
    @IBOutlet var pickerViewContainer: UIView!
   
    var objCarePlanFrequencyObj = CarePlanFrequencyObj()
    var array = NSMutableArray()
    var arrayConstant = NSMutableArray()
    var currentLocale : String = ""
    var formInterval: GTInterval!
    var isEdit: Bool = false
    var editReadArray = NSMutableArray()
    var tempReadArray = NSMutableArray()
    
    @IBOutlet weak var frequencyTblView: UITableView!
    @IBOutlet weak var noreadingsLabel: UILabel!
   // @IBOutlet weak var timingHeaderLabel: UILabel!
   // @IBOutlet weak var goalHeaderLabel: UILabel!
    @IBOutlet weak var takereadingsLabel: UILabel!
    
    @IBOutlet var pickerViewInner: UIView!
    @IBOutlet weak var pickerTimingView: UIPickerView!
    @IBOutlet weak var pickerFreqView: UIPickerView!
    
     @IBOutlet weak var btnOkPicker: UIButton!
     @IBOutlet weak var btnCancelPicker: UIButton!
    
    @IBOutlet weak var btnCancelFreqPicker: UIButton!
    @IBOutlet weak var btnOkFreqPicker: UIButton!
    
    @IBOutlet weak var addReadingView: UIView!
    
    @IBOutlet weak var addNewReadingTitle: UILabel!
    @IBOutlet weak var addNewReadingButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocale = NSLocale.current.languageCode!
      //  timingHeaderLabel.text = "Timing".localized
      //  goalHeaderLabel.text = "Goal".localized
        takereadingsLabel.text = "Take the following readings".localized
        
        addReadingView.backgroundColor = UIColor.white
        addNewReadingButton.backgroundColor = Colors.PrimaryColor

        
        noreadingsLabel.isHidden = true
        tblView.backgroundColor = UIColor.clear

      //  frequencyTblView.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
        
        //TableView Round corner and Border set
        tblView.layer.cornerRadius = kButtonRadius
        tblView.layer.masksToBounds = true
        tblView.layer.borderColor = Colors.PrimaryColor.cgColor
        tblView.layer.borderWidth = 1.0
        
        tblView.tableFooterView =  UIView(frame: .zero)
        
//        frequencyTblView.layer.cornerRadius = kButtonRadius
//        frequencyTblView.layer.masksToBounds = true
//        frequencyTblView.layer.borderColor = Colors.PrimaryColor.cgColor
//        frequencyTblView.layer.borderWidth = 1.0
//        
//        frequencyTblView.tableFooterView =  UIView(frame: .zero)
        
        self.automaticallyAdjustsScrollViewInsets = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        getReadingsData()
       
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kCarePlanReadingScreenName)
        //--------Google Analytics Finish-----
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        //tempReadArray = NSMutableArray()
        
        //tblView.reloadData()
        //print("Temp Read Array")
        //print(self.tempReadArray)
        //UserDefaults.standard.setValue(self.tempReadArray, forKey: "updateReadingCareArray")
       // UserDefaults.standard.synchronize()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
    }
    
    //MARK: - Custom Methods
    func resetUI() {
        
        print("Array count")
        print(self.array.count)

        tblView.isHidden = false
       // frequencyTblView.isHidden = false
      /*  if self.array.count > 0{
            tblView.isHidden = false
            frequencyTblView.isHidden = true
        }
        else{
           // tblView.isHidden = true
            frequencyTblView.isHidden = true
        }
        
        if self.arrayConstant.count > 0{
            tblView.isHidden = false
            frequencyTblView.isHidden = true
        }
        else{
            //tblView.isHidden = true
            frequencyTblView.isHidden = true
        }
        
       /* if self.array.count > 0 {
            frequencyTblView.isHidden = false
        }
        else {
            frequencyTblView.isHidden = true
        }*/
   */ }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
    }
    
    //MARK: - Notifications Methods
    func readingNotification(notification: NSNotification) {
        
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
    

   
    @IBAction func AddReading_Click(_ sender: Any) {
        
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Reading", action:"Add reading Clicked" , label:"Add care plan reading")
      //  NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "addreading")
       // let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        //formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: 210)
        //formSheetController.presentationController?.shouldCenterVertically = true
       // formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        //self.present(formSheetController, animated: true, completion: nil)

    }
    
    
    @IBAction func ToolBarButtons_Click(_ sender: Any) {
        
        self.view.endEditing(true)
       /* if (sender as AnyObject).tag == 0 {
            print(selectedIndexPath , selectedIndex)
            let mainDict: NSMutableDictionary = array[selectedIndexPath] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            obj.time = conditionsArrayEng[pickerView.selectedRow(inComponent: 0)] as! String
            itemsArray.replaceObject(at:selectedIndex, with: obj)
            let mSectioDict = (array[selectedIndexPath] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
            array.replaceObject(at:selectedIndexPath, with: sectionsDict)
            self.view.endEditing(true)
            tblView.reloadData()
            let placesData = NSKeyedArchiver.archivedData(withRootObject: currentEditReadingArray)
        }
*/
    }
    // MARK: - UIButton Event Methods
   
    @IBAction func EditReading_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        let btn = sender as! UIButton
      
        let cell = self.parentCellFor(view: btn) as! CarePlanReadingTableViewCell
        self.objCarePlanFrequencyObj = (array[btn.tag] as? CarePlanFrequencyObj)!
        
        if(!self.objCarePlanFrequencyObj.isEdit)
        {
            self.objCarePlanFrequencyObj.isEdit = true
            cell.btnEdit.setImage(UIImage(named: "save_icon"), for: .normal)
            cell.btnEdit.setImage(UIImage(named: "save_icon"), for: .highlighted)
            self.tblView .reloadData()
        }
        else
        {
            
            let inverseSet = NSCharacterSet(charactersIn:"0123456789-< ").inverted
            
            let components = self.objCarePlanFrequencyObj.goal.components(separatedBy: inverseSet)
            
            // Rejoin these components
            let filtered = components.joined(separator: "") // use join("", components) if you are using Swift 1.2
            if(self.objCarePlanFrequencyObj.goal.length < 1 )
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter valid range value for Goal".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please enter valid range value for Goal")
                SVProgressHUD.dismiss()
            }
            else if( self.objCarePlanFrequencyObj.goal != filtered )
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter valid range value for Goal".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please enter valid range value for Goal")
                SVProgressHUD.dismiss()
            }
                
            else
            {
                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                    self.objCarePlanFrequencyObj.isEdit = false
                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
                    
                    self.tblView.reloadData()
                    
                    self.tblView .layoutIfNeeded()
                    let arr : NSArray = UserDefaults.standard.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
                    editReadArray = NSMutableArray(array: arr)
                    let mainDict: NSMutableDictionary = NSMutableDictionary()
                    mainDict.setValue(self.objCarePlanFrequencyObj.id, forKey: "id")
                    mainDict.setValue(self.objCarePlanFrequencyObj.frequency, forKey: "frequency")
                    mainDict.setValue(self.objCarePlanFrequencyObj.time, forKey: "time")
                    mainDict.setValue(self.objCarePlanFrequencyObj.goal, forKey: "goal")
                    if editReadArray.count > 0 {
                        for i in 0..<self.editReadArray.count {
                            let id: String = (editReadArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                            print(id)
                            if id == self.objCarePlanFrequencyObj.id {
                                editReadArray.replaceObject(at:i, with: mainDict)
                                UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
                                UserDefaults.standard.synchronize()
                                return
                            }
                        }
                        editReadArray.add(mainDict)
                    }
                    else {
                        editReadArray.add(mainDict)
                    }
                   
                    
                    if tempReadArray.count >= array.count{
                        let first = tempReadArray.count - array.count
                        var finalArray = NSMutableArray();
                        //var index : Int = 0
                        for i in first..<(first+array.count){
                            finalArray.add(tempReadArray[i])
                            //index = index + 1
                        }
                        print("Final array")
                        print(finalArray)
                        UserDefaults.standard.set(finalArray, forKey: "updateReadingCareArray")
                        //print(UserDefaults.standard.array(forKey: "updateReadingCareArray"))
                        UserDefaults.standard.synchronize()
                        print("Stuff")
                        print(UserDefaults.standard.array(forKey: "updateReadingCareArray"))
                    }
                    UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
                    UserDefaults.standard.synchronize()
                    
                }
                else
                {
                    //if self.pickerTimingView.superview == nil && self.pickerFreqView.superview == nil
                      //  {
                            self.updatecareplanData()
                            self.objCarePlanFrequencyObj.isEdit = false
                            cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
                            cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
                            self.tblView .reloadData()
                       // }
                    //else{
                     //   print("Please close picker view")
                    //}
                   
                }
            }
            
            
        }
    }
    
       
    @IBAction func cancelFreqBtn_Clicked(_ sender: Any) {
         hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func okFreqBtn_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        
        let indexPath = IndexPath(row: btn.tag, section: 0)
        self.objCarePlanFrequencyObj = (array[btn.tag] as? CarePlanFrequencyObj)!
        
        let cell = self.tblView.cellForRow(at: indexPath) as! CarePlanReadingTableViewCell
        self.objCarePlanFrequencyObj.frequency = (frequnecyArray[pickerFreqView.selectedRow(inComponent: 0)] as? String)!
        
        let valFreq = self.objCarePlanFrequencyObj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
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
        hideOverlay(overlayView: pickerViewContainer)
        
    }
    @IBAction func cancelBtn_Clicked(_ sender: Any) {
          hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func okBtn_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        
        let indexPath = IndexPath(row: btn.tag, section: 0)
         self.objCarePlanFrequencyObj = (array[btn.tag] as? CarePlanFrequencyObj)!
        
        let cell = self.tblView.cellForRow(at: indexPath) as! CarePlanReadingTableViewCell
        self.objCarePlanFrequencyObj.time = (conditionsArray[pickerTimingView.selectedRow(inComponent: 0)] as? String)!
    
        cell.conditionLbl.text = conditionsArray[pickerTimingView.selectedRow(inComponent: 0)] as? String
        
        hideOverlay(overlayView: pickerViewContainer)
    }
    @IBAction func btnFreq_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        self.view.endEditing(true)
        self.pickerTimingView.isHidden = true
        self.pickerFreqView.isHidden = false
        self.btnCancelFreqPicker.isHidden = false
        self.btnOkFreqPicker.isHidden = false
        self.btnCancelPicker.isHidden = true
        self.btnOkPicker.isHidden = true
        self.pickerFreqView.tag = btn.tag
        self.btnOkFreqPicker.tag = btn.tag
        self.btnCancelFreqPicker.tag = btn.tag
        let carePlanFrequencyObj = (array[btn.tag] as? CarePlanFrequencyObj)!
        
        let index = frequnecyArray.index(of: carePlanFrequencyObj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        pickerFreqView.selectRow(index, inComponent: 0, animated: true)
        
        showOverlay(overlayView: pickerViewContainer)
        
    }
    @IBAction func btnTiming_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        self.view.endEditing(true)
        self.pickerTimingView.isHidden = false
        self.pickerFreqView.isHidden = true
        self.btnCancelFreqPicker.isHidden = true
        self.btnOkFreqPicker.isHidden = true
        self.btnCancelPicker.isHidden = false
        self.btnOkPicker.isHidden = false
        self.pickerTimingView.tag = btn.tag
        self.btnOkPicker.tag = btn.tag
        self.btnCancelPicker.tag = btn.tag

        let carePlanFrequencyObj = (array[btn.tag] as? CarePlanFrequencyObj)!
        
        let index = conditionsArrayEng.index(of: carePlanFrequencyObj.time.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))

        pickerTimingView.selectRow(index, inComponent: 0, animated: true)
        
        showOverlay(overlayView: pickerViewContainer)
        
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
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        view.removeGestureRecognizer(sender)
    }
    // MARK: - Api Methods
    func updatecareplanData()
    {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "readingid": self.objCarePlanFrequencyObj.id,
            "userid": patientsID,
            "readingFreq" : self.objCarePlanFrequencyObj.frequency,
            "readingTime" : self.objCarePlanFrequencyObj.time,
            "readingGoal" : self.objCarePlanFrequencyObj.goal
            
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        SVProgressHUD.show(withStatus: "Loading readings plan".localized, maskType: SVProgressHUDMaskType.clear)
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            switch response.result {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "Updated Successfully".localized, maskType: SVProgressHUDMaskType.clear)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplanReadings) Calling", action:"Success -Update care Plan" , label:"Care Plan Data Updated Successfully", value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                self.tblView.reloadData()
                
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
    func getReadingsData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            
           // array = NSMutableArray()
            let patientsID: String! = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            
            let parameters: Parameters = [
                "userid": patientsID
            ]//"\(baseUrl)\(ApiMethods.getcareplanReadings)
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            Alamofire.request("\(baseUrl)\(ApiMethods.getcareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                self.formInterval.end()
                switch response.result {
                case .success:
                    print("Validation Successful")
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getcareplanReadings) Calling", action:"Success - Get care plan Readings Data" , label:"Get care plan Readings Data Listed Successfully", value : self.formInterval.intervalAsSeconds())
                    
                    if let JSON: NSArray = response.result.value as? NSArray {
                        self.array.removeAllObjects()
                        for data in JSON {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj1 = CarePlanFrequencyObj()
                            obj1.id = dict.value(forKey: "_id") as! String
                            let goalStr: String = dict.value(forKey: "goal") as! String
                            obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                            obj1.time = dict.value(forKey: "time") as! String
                            obj1.frequency = dict.value(forKey: "frequency") as! String
                            obj1.isEdit = false
                            self.array.add(obj1)
                        }
                        print(self.array)
                    }
                    self.tblView.reloadData()
                    break
                    
                case .failure(let error):
                    print("failure")
                    //Google Analytic
                    var strError = ""
                    if(error.localizedDescription.length>0)
                    {
                        strError = error.localizedDescription
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getcareplanReadings) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                    self.tblView.reloadData()
                    // self.frequencyTblView.reloadData()
                    // self.resetUI()
                    
                    break
                    
                }
        }
    }
}

    
   
    // MARK: - Get Subview and Superview
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
        return array.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CarePlanReadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! CarePlanReadingTableViewCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.btnEdit.tag = indexPath.row
        cell.btnFreq.tag = indexPath.row
        cell.btnTiming.tag = indexPath.row
        cell.txtGoal.tag = indexPath.row
        let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
       
        
       // tempReadArray.removeAll()
        
        if let obj: CarePlanFrequencyObj = array[indexPath.row] as? CarePlanFrequencyObj {
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
            
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            mainDict.setValue(obj.id, forKey: "id")
            mainDict.setValue(obj.frequency, forKey: "frequency")
            mainDict.setValue(obj.time, forKey: "time")
            mainDict.setValue(obj.goal, forKey: "goal")
            
            tempReadArray.add(mainDict)
           

            cell.txtGoal.delegate = self
            cell.btnFreq.addTarget(self, action: #selector(btnFreq_Clicked(_:)), for: .touchUpInside)
            cell.btnTiming.addTarget(self, action: #selector(btnTiming_Clicked(_:)), for: .touchUpInside)
            if(obj.isEdit)
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
            }
        }
        return cell;
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell : CarePlanReadingHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")! as! CarePlanReadingHeaderTableViewCell
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
//            cell.frequencyLbl.textAlignment = .center
           cell.timingHeaderLabel.textAlignment = .center
//            cell.goalHeaderLabel.textAlignment = .left
        }
        
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
            
//            frequencyTblView.separatorInset = UIEdgeInsets.zero
//            
//            frequencyTblView.layoutMargins = UIEdgeInsets.zero

            
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
            
//            var frame1 = self.frequencyTblView.frame
//            frame1.size.height = self.frequencyTblView.contentSize.height
//            self.frequencyTblView.frame = frame1

            
        }     catch let exception {
            print("Exception Occure in LeadDetailViewController willDisplayCell: \(exception)")
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
