//
//  ReportMedicationViewController.swift
//  DiabetesApp
//
//  Created by Developer on 2/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import  SVProgressHUD
import SDWebImage

class ReportMedicationViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var noMedicationsAvailableLabel: UILabel!
    
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var addNewMedicationBtn: UIButton!
    @IBOutlet weak var addNewMedicationView: UIView!
    
    @IBOutlet weak var constTableBottom: NSLayoutConstraint!
    @IBOutlet weak var imgAddMedicineIcon: UIImageView!
    
    @IBOutlet weak var lblAddMedicineTitle: UILabel!
    
    let picker = UIImagePickerController()
    var array = NSMutableArray()
    var repoMedArray = NSMutableArray()
    var arrayCopy = NSArray()
    var selectedIndex : NSIndexPath = NSIndexPath()
    var editMedArray = NSMutableArray()
    var updateArray = NSMutableArray()

    var isnewConditionAdd : Bool = false
    
    var formInterval: GTInterval!
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    let loggedInUserID : String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
    
    var addNewCurrentMedArray = NSArray()
    var editNewCurrentMedArray = NSArray()
    var deleteNewCurrentMedArray = NSArray()
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.allowsEditing = false
        picker.delegate = self
        lblAddMedicineTitle.text = "ADD_MEDICATION_LABEL".localized
        noMedicationsAvailableLabel.text = "No Medications Available".localized
        noMedicationsAvailableLabel.isHidden = true
        tblView.backgroundColor = UIColor.clear
        addNewMedicationView.backgroundColor = UIColor.white
        addNewMedicationBtn.backgroundColor = Colors.PrimaryColor
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kMedicationScreenName)
        //--------Google Analytics Finish-----
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            doctorReportAPI()
        }
        else {
            getMedicationsData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        if(selectedUserType == userType.patient)
        {
            self.constTableBottom.constant = 0
            self.addNewMedicationView.isHidden = true
            self.tblView.setNeedsUpdateConstraints()
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
    }
    
    //MARK: - Custom Methods
    func dismissPopup() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func resetUI() {
        if self.array.count > 0 {
            tblView.isHidden = false
            // noMedicationsAvailableLabel.isHidden = true
        }
        else {
            tblView.isHidden = true
            // noMedicationsAvailableLabel.isHidden = false
        }
    }
    
    func readingMedicationNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let cell = self.tblView.cellForRow(at: selectedIndex as IndexPath) as! CarePlanMedicationTableViewCell
        
        if let medicationname = userInfo["medicationname"] as? String {
            //if let medicationtype = userInfo["type"] as? String {
            for data in dictMedicationList {
                if let medication = data as? medicationObj {
                    if(medication.medicineName == medicationname)
                    {
                        if let obj: CarePlanObj = array[selectedIndex.row] as? CarePlanObj {
                            
                            obj.type = medication.type
                            let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                            
                            let manager:SDWebImageManager = SDWebImageManager.shared()
                            
                            manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                                  options: SDWebImageOptions.highPriority,
                                                  progress: nil,
                                                  completed: {[weak self] (image, error, cached, finished, url) in
                                                    if (error == nil && (image != nil) && finished) {
                                                        obj.carePlanImageURL = image!
                                                        cell.medImageView.image = image!
                                                        
                                                        let tapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(self?.imageTapped))
                                                        cell.medImageView.isUserInteractionEnabled = true
                                                        cell.medImageView.addGestureRecognizer(tapGestureRecognizer)
                                                        
                                                        
                                                        self?.array.removeObject(at: (self?.selectedIndex.row)!)
                                                        self?.array.insert(obj, at: (self?.selectedIndex.row)!)
                                                    }
                            })
                        }
                    }
                }
            }
            // }
        }
    }
    
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.medicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNewMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.addNewMedication), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.closeAddNewMedication(notification:)), name: NSNotification.Name(rawValue: Notifications.closeAddNewMedication), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        
    }
    
    //MARK: - Notifications Methods
    func medicationNotification(notification: NSNotification) {
        
    }
    
    func addNewMedicationNotification(notification: NSNotification) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        self.getMedicationsData()
    }
    
    func closeAddNewMedication(notification: NSNotification) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
    }
    
    func addMedicationNotification(notification: NSNotification) {
        
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "addmedication")
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: 210)
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.isTransparentTouchEnabled = false
        self.present(formSheetController, animated: true, completion: nil)
        
    }
    
    //MARK: - Helpers
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func selectMedicineImage_Click(_ sender: Any) {
        self.view.endEditing(true)
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        let index: Int = (sender as AnyObject).tag
        picker.view.tag = index
        present(picker, animated: true, completion: nil)
    }
    
    
    @IBAction func AddMedicine_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add medication Clicked" , label:"Add care plan medication")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "addmedication")
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: 210)
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        self.present(formSheetController, animated: true, completion: nil)
    }
    
    
    @IBAction func EditMedication_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Edit medication Clicked" , label:"Edit care plan medication")
        self.view.endEditing(true)
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let obj: CarePlanObj = (array[index] as? CarePlanObj)!
        
        if(!obj.isEdit)
        {
            btn.setImage(UIImage(named: "save_icon"), for: .normal)
            btn.setImage(UIImage(named: "save_icon"), for: .highlighted)
            btn.setTitle("".localized,for: .normal)
            btn.setTitle("".localized,for: .highlighted)
            if let obj: CarePlanObj = array[index] as? CarePlanObj {
                obj.isEdit = true
            }
            self.tblView.reloadData()
            self.tblView .layoutIfNeeded()
            let cell = self.parentCellFor(view: btn) as! CarePlanMedicationTableViewCell
            
            self .perform(#selector(firstResponder), with: cell, afterDelay: 0.5)
        }
        else
        {
            // isnewConditionAdd = false
            if let obj: CarePlanObj = array[index] as? CarePlanObj {
                if(obj.name .isEmpty)
                {
                    showAlert(title: "Data missing", message: "Please input medicine name".localized)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please input medicine name")
                    //SVProgressHUD.dismiss()
                }
                else if (obj.condition.count  < 1)
                {
                    showAlert(title: "Data missing", message: "Please input atleast one condition".localized)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please input atleast one condition")
                    // SVProgressHUD.dismiss()
                }
                else if(obj.dosage.count < 1)
                {
                    showAlert(title: "Data missing", message: "Please input atleast one dosage value".localized)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please input atleast one dosage value")
                    // SVProgressHUD.dismiss()
                }
                else if obj.dosage.contains(0) {
                    showAlert(title: "Data missing", message: "Dosage value should be more than 0".localized)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Dosage value should be more than 0")
                    // SVProgressHUD.dismiss()
                }
                else if (obj.condition.contains(""))
                {
                    showAlert(title: "Data missing", message: "Please input atleast one condition value".localized)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please input atleast one condition value")
                    //SVProgressHUD.dismiss()
                }
                else
                {
                    btn.setImage(UIImage(named: "edit_icon"), for: .normal)
                    btn.setImage(UIImage(named: "edit_icon"), for: .highlighted)
                    btn.setTitle("".localized,for: .normal)
                    btn.setTitle("".localized,for: .highlighted)
                    if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                        
                        obj.isEdit = false
                        self.tblView.reloadData()
                        self.tblView .layoutIfNeeded()
                        let arr : NSArray = UserDefaults.standard.array(forKey: "currentEditMedicationArray")! as [Any] as NSArray
                        editMedArray = NSMutableArray(array: arr)
                        let mainDict: NSMutableDictionary = NSMutableDictionary()
                        mainDict.setValue(obj.id, forKey: "id")
                        mainDict.setValue(obj.name, forKey: "name")
                        mainDict.setValue(obj.dosage, forKey: "dosage")
                        mainDict.setValue(obj.condition, forKey: "condition")
                        if editMedArray.count > 0 {
                            for i in 0..<self.editMedArray.count {
                                let id: String = (editMedArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                                print(id)
                                if id == obj.id {
                                    editMedArray.replaceObject(at:i, with: mainDict)
                                    UserDefaults.standard.setValue(editMedArray, forKey: "currentEditMedicationArray")
                                    UserDefaults.standard.synchronize()
                                    return
                                }
                            }
                            editMedArray.add(mainDict)
                            
                        }
                        else {
                            editMedArray.add(mainDict)
                        }
                        UserDefaults.standard.setValue(editMedArray, forKey: "currentEditMedicationArray")
                        UserDefaults.standard.synchronize()
                        //self.navigationController?.popViewController(animated: true)
                        
                    }
                    else{
                        self.updatecareplanData(careObj: obj, btnEdit: btn)
                    }
                }
            }
            //Save Codding here
        }
    }
    
    @IBAction func btnAdd_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add medication Clicked" , label:"Add care plan medication condition")
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let cell = self.parentCellFor(view: btn)
        self.listSubviewsOf(cell)
        if let obj1: CarePlanObj = self.array[index] as? CarePlanObj {
            
            if obj1.dosage.contains(0) {
                showAlert(title: "Data missing", message: "Dosage value should be more than 0".localized)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Add Medication" , label:"Dosage value should be more than 0")
            }
            else if (obj1.condition.contains(""))
            {
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Add Medication" , label:"Please input atleast one condition value")
                showAlert(title: "Data missing", message: "Please input atleast one condition value".localized)
            }
            else
            {
                isnewConditionAdd = true
                obj1.dosage.append(0)
                obj1.condition.append("")
                obj1.isEdit = true
                self.array.removeObject(at: index)
                self.array.insert(obj1, at: index)
                self.resetUI()
                self.tblView .reloadData()
                self.tblView .layoutIfNeeded()
            }
        }
    }
    
    @IBAction func btndeleteCondtion_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Delete medication Field Clicked" , label:"Delete care plan medication Field")
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let cell = self.parentCellFor(view: btn)
        
        if !cell.isViewEmpty {
            let indexPath = self.tblView.indexPathForRow(at: cell.center)!
            if let obj: CarePlanObj = array[indexPath.row] as? CarePlanObj {
                if(obj.dosage.count<=1)
                {
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"delete Card Medication Field" , label:"Medication must have one condition and dosage")
                    showAlert(title: "Data missing", message: "Please input atleast one condition value".localized)
                }
                else
                {
                    obj.dosage.remove(at: index)
                    obj.condition.remove(at: index)
                    array.removeObject(at: indexPath.row)
                    array.insert(obj, at: indexPath.row)
                    self.tblView .reloadData()
                    self.tblView .layoutIfNeeded()
                    self.resetUI()
                }
                
            }
        }
    }
    
    
    @IBAction func btnClose_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        
        if let objMain: CarePlanObj = self.arrayCopy[index] as? CarePlanObj {
            objMain.isEdit = false
            if !isnewConditionAdd
            {
                array.removeObject(at: index)
                array.insert(objMain, at: index)
            }
            
        }
        
        self.tblView.reloadData()
    }
    @IBAction func DeleteMedication_Click(_ sender: Any) {
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        if let obj: CarePlanObj = array[index] as? CarePlanObj {
            self.deleteMedications(careObj: obj)
        }
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Delete Medication Click" , label:"User Click on delete Medication Click")
        array.removeObject(at: index)
        tblView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        for i in index..<array.count {
            self.tblView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
        }
        
        self.resetUI()
    }
    
    // MARK: - Api Methods
    func updatecareplanData(careObj : CarePlanObj, btnEdit  : UIButton)
    {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        
        let parameters: Parameters = [
            "userID": patientsID,
            "medname": careObj.name,
            "medicineID" : careObj.id,
            "arrayCondition" : careObj.condition,
            "arrayDosage" : careObj.dosage,
            "updatedBy":loggedInUserID,
            "updatedByName":loggedInUserName
            
        ]
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            switch response.result {
            case .success:
                careObj.isEdit = false
                SVProgressHUD.showSuccess(withStatus: "Medication Updated".localized, maskType: SVProgressHUDMaskType.clear)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplan) Calling", action:"Success -Update care Plan" , label:"Care Plan Data Updated Successfully", value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                self.tblView.reloadData()
                self.tblView .layoutIfNeeded()
                
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplan) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                self.resetUI()
                SVProgressHUD.dismiss()
                break
                
            }
        }
        
    }
    
    func deleteMedications(careObj : CarePlanObj) {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        let parameters: Parameters = [
            "userid": patientsID,
            "medicineID" : careObj.id,
            "updatedBy":loggedInUserID,
            "updatedByName":loggedInUserName
        ]
        
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        SVProgressHUD.show(withStatus: "SA_STR_DELETE_MEDICATION".localized)
        Alamofire.request("\(baseUrl)\(ApiMethods.deletecareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                if JSON["result"] != nil {
                    self.present(UtilityClass.displayAlertMessage(message: JSON.value(forKey:"message") as! String, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                    
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Fail - Web API Calling" , label:JSON.value(forKey:"message") as! String, value : self.formInterval.intervalAsSeconds())
                    
                    SVProgressHUD.dismiss()
                }
                else
                {
                    switch response.result
                    {
                    case .success:
                        SVProgressHUD.dismiss()
                        //Google Analytic
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Success - Delete care Plan" , label:"Care Plan Data Deleted Successfully", value : self.formInterval.intervalAsSeconds())
                        print("Validation Successful")
                        break
                    case .failure(let error):
                        print("failure")
                        var strError = ""
                        if(error.localizedDescription.length>0)
                        {
                            strError = error.localizedDescription
                        }
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                        SVProgressHUD.dismiss()
                        break
                        
                    }
                }
            }
        }
    }
    
    
    func getMedicationsData() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid": patientsID
        ]
        SVProgressHUD.show(withStatus: "Loading Medications".localized)
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        //"\(baseUrl)\(ApiMethods.getcareplan)"
        Alamofire.request("\(baseUrl)\(ApiMethods.getcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            SVProgressHUD.dismiss()
            switch response.result {
            case .success:
                
                print("Validation Successful")
                self.array = NSMutableArray()
                
                self.arrayCopy = NSArray()
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getcareplanUpdated Calling", action:"Success - get Medications List" , label:"get Medications Listed Successfully", value : self.formInterval.intervalAsSeconds())
                
                if let JSON: NSArray = response.result.value as? NSArray {
                    //self.array = NSMutableArray()
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        if let medtype = dict.value(forKey: "type"){
                            obj.type =  medtype as! String
                        }
                        else{
                            obj.type =  ""
                        }
                        obj.isNew = false
                        obj.isEdit = false
                        for data in dictMedicationList {
                            if let medication = data as? medicationObj {
                                if(medication.medicineName == obj.name)
                                {
                                    let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                                    obj.strImageURL = imagePath
                                    
                                }
                            }
                        }
                        
                        if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                            for timing in timingArray{
                                let tempDict: NSDictionary = timing as! NSDictionary
                                obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                obj.condition.append(tempDict.value(forKey:"condition") as! String)
                            }
                        }
                        
                        self.array.add(obj)
                    }
                    
                    
                    //Update Edited Objects
                    let arrEdit : NSArray = UserDefaults.standard.array(forKey: "currentEditMedicationArray")! as [Any] as NSArray
                    self.editNewCurrentMedArray = NSMutableArray(array: arrEdit)
                    for data1 in self.editNewCurrentMedArray{
                        
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        if let medtype = dict.value(forKey: "type"){
                            obj.type =  medtype as! String
                        }
                        else{
                            obj.type =  ""
                        }
                        obj.isNew = false
                        obj.isEdit = false
                        
                        for data in dictMedicationList {
                            if let medication = data as? medicationObj {
                                if(medication.medicineName == obj.name)
                                {
                                    let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                                    obj.strImageURL = imagePath
                                    
                                }
                            }
                        }
                        if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                            for timing in timingArray{
                                let tempDict: NSDictionary = timing as! NSDictionary
                                obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                obj.condition.append(tempDict.value(forKey:"condition") as! String)
                            }
                        }
                        for i in 0..<self.array.count {
                            let objCarPlan = (self.array[i] as? CarePlanObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.array.replaceObject(at: i, with: obj)
                                break
                            }
                        }
                    }
                    
                    //Add Medication Data From the cashe
                    let tempAddArray : NSArray = UserDefaults.standard.array(forKey: "currentAddNewMedicationArray")! as [Any] as NSArray
                    self.addNewCurrentMedArray = NSMutableArray(array: tempAddArray)
                    
                    for data1 in self.addNewCurrentMedArray{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        if let medtype = dict.value(forKey: "type"){
                            obj.type =  medtype as! String
                        }
                        else{
                            obj.type =  ""
                        }
                        obj.isNew = false
                        obj.isEdit = false
                        
                        for data in dictMedicationList {
                            if let medication = data as? medicationObj {
                                if(medication.medicineName == obj.name)
                                {
                                    let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                                    obj.strImageURL = imagePath
                                    
                                }
                            }
                        }
                        if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                            for timing in timingArray{
                                let tempDict: NSDictionary = timing as! NSDictionary
                                obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                obj.condition.append(tempDict.value(forKey:"condition") as! String)
                            }
                        }
                        self.array.add(obj)
                    }
                    
                    //Delete Medication Data From the cashe
                    let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
                    self.deleteNewCurrentMedArray = NSMutableArray(array: tempDeleteArray)
                    for data1 in self.deleteNewCurrentMedArray{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "id") as! String
                        for i in 0..<self.array.count {
                            let objCarPlan = (self.array[i] as? CarePlanObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.array.remove(objCarPlan)
                                break
                            }
                        }
                    }
                }
                self.arrayCopy = self.array.mutableCopy() as! NSArray
                
                //print("Object medication array")
                // print(self.array)
                self.tblView.reloadData()
                self.tblView.layoutIfNeeded()
                self.resetUI()
                
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getcareplanUpdated Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                self.array = NSMutableArray()
                self.tblView.reloadData()
                self.tblView.layoutIfNeeded()
                self.resetUI()
                
                SVProgressHUD.dismiss()
                break
                
            }
        }
        
    }
    // DoctorReport Api
    
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
                self.array = NSMutableArray()
                self.repoMedArray = NSMutableArray()
                
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    let jsonArrNewMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "newMedication") as! NSArray)
                    let jsonArrUpdateMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedMedication") as! NSArray)
                    let jsonArrDeleteNewMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "deletedMedication") as! NSArray)
                    
                    
                    if jsonArr.count > 0 {
                        self.array.removeAllObjects()
                        for data in jsonArr {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            obj.name = dict.value(forKey: "name") as! String
                            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                                for timing in timingArray{
                                    let tempDict: NSDictionary = timing as! NSDictionary
                                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                                }
                            }
                            self.repoMedArray.add(dict)
                            self.array.add(obj)
                        }
                    }
                    
                    //Update current medication if educator updated
                    if jsonArrUpdateMed.count > 0 {
                        for data1 in jsonArrUpdateMed{
                            
                            let dict: NSDictionary = data1 as! NSDictionary
                            let obj = CarePlanObj()
                            obj.id = dict.value(forKey: "id") as! String
                            obj.name = dict.value(forKey: "name") as! String
                            if let medtype = dict.value(forKey: "type"){
                                obj.type =  medtype as! String
                            }
                            else{
                                obj.type =  ""
                            }
                            obj.isNew = false
                            obj.isEdit = false
                            
                            for data in dictMedicationList {
                                if let medication = data as? medicationObj {
                                    if(medication.medicineName == obj.name)
                                    {
                                        let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                                        obj.strImageURL = imagePath
                                        
                                    }
                                }
                            }
                            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                                for timing in timingArray{
                                    let tempDict: NSDictionary = timing as! NSDictionary
                                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                                }
                            }
                            for i in 0..<self.array.count {
                                let objCarPlan = (self.array[i] as? CarePlanObj)!
                                if(objCarPlan.id ==  obj.id )
                                {
                                    self.array.replaceObject(at: i, with: obj)
                                    
                                      self.repoMedArray.replaceObject(at: i, with: dict)
                                    break
                                }
                            }
                        }
                    }
                    
                    //Add new medication if educator added
                    if jsonArrNewMed.count > 0 {
                        for data in jsonArrNewMed {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanObj()
                            if (dict.value(forKey: "_id") == nil)
                            {
                                obj.id = dict.value(forKey: "id") as! String
                            }
                            else
                            {
                                obj.id = dict.value(forKey: "_id") as! String
                            }
                            obj.name = dict.value(forKey: "name") as! String
                            obj.tempIndex = dict.value(forKey:"medindex") as! Int
                            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                                for timing in timingArray{
                                    let tempDict: NSDictionary = timing as! NSDictionary
                                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                                }
                            }
                            self.array.add(obj)
                            self.repoMedArray.add(dict)
                        }
                    }
                    
                    //Delete Medication Data From the cashe
                    for data1 in jsonArrDeleteNewMed{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "id") as! String
                        for i in 0..<self.array.count {
                            let objCarPlan = (self.array[i] as? CarePlanObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.array.remove(objCarPlan)
                                self.repoMedArray.removeObject(at: i)
                                break
                            }
                        }
                    }
                    
                    if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                        self.addDefaultValue()
                    }
                    
                    UserDefaults.standard.setValue(self.repoMedArray, forKey: "repoMediArray")
                    UserDefaults.standard.synchronize()
                    self.arrayCopy = self.array.mutableCopy() as! NSArray
                    
                    //print("Object medication array")
                    // print(self.array)
                    self.tblView.reloadData()
                    self.tblView.layoutIfNeeded()
                    self.resetUI()
                }
                
                break
            case .failure:
                print("failure")
                self.array = NSMutableArray()
                self.tblView.reloadData()
                self.tblView.layoutIfNeeded()
                self.resetUI()
                SVProgressHUD.showError(withStatus: response.result.error?.localizedDescription)
                break
                
            }
        }
        
        
    }
    func addDefaultValue ()
    {
        //Update Edited Objects
        let arrEdit : NSArray = UserDefaults.standard.array(forKey: "currentEditMedicationArray")! as [Any] as NSArray
        let editMedArray = NSMutableArray(array: arrEdit)
        for data1 in editMedArray{
            
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            obj.name = dict.value(forKey: "name") as! String
            if let medtype = dict.value(forKey: "type"){
                obj.type =  medtype as! String
            }
            else{
                obj.type =  ""
            }
            obj.isNew = false
            obj.isEdit = false
            
            for data in dictMedicationList {
                if let medication = data as? medicationObj {
                    if(medication.medicineName == obj.name)
                    {
                        let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                        obj.strImageURL = imagePath
                        
                    }
                }
            }
            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                for timing in timingArray{
                    let tempDict: NSDictionary = timing as! NSDictionary
                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                }
            }
            for i in 0..<self.array.count {
                let objCarPlan = (self.array[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.array.replaceObject(at: i, with: obj)
                        self.repoMedArray.replaceObject(at: i, with: dict)
                    break
                }
            }
        }
        
        //Add Medication Data From the cache
        let tempAddArray : NSArray = UserDefaults.standard.array(forKey: "currentAddNewMedicationArray")! as [Any] as NSArray
        let addMedArray = NSMutableArray(array: tempAddArray)
        
        for data1 in addMedArray{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            obj.name = dict.value(forKey: "name") as! String
            if let medtype = dict.value(forKey: "type"){
                obj.type =  medtype as! String
            }
            else{
                obj.type =  ""
            }
            obj.isNew = false
            obj.isEdit = false
            
            for data in dictMedicationList {
                if let medication = data as? medicationObj {
                    if(medication.medicineName == obj.name)
                    {
                        let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                        obj.strImageURL = imagePath
                        
                    }
                }
            }
            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                for timing in timingArray{
                    let tempDict: NSDictionary = timing as! NSDictionary
                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                }
            }
            self.array.add(obj)
             self.repoMedArray.add(dict)
        }
        
        //Delete Medication Data From the cache
        let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
        let deleteMedArray = NSMutableArray(array: tempDeleteArray)
        for data1 in deleteMedArray{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.array.count {
                let objCarPlan = (self.array[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.array.remove(objCarPlan)
                    self.repoMedArray.removeObject(at: i)
                    break
                }
            }
        }
    }
    
    fileprivate func configureSimpleSearchTextField(medicationTextField: AutocompleteSearchTextField) {
        // Start visible - Default: false
        medicationTextField.startVisible = true
        // Set data source
        medicationTextField.filterStrings(dictMedicationName)
    }
    
    //MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
            self.tblView.layoutIfNeeded()
            self.tblView.setNeedsDisplay()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell") as! CarePlanMedicationTableViewCell
        
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        cell.tag = indexPath.row
        
        
        if let obj: CarePlanObj = self.array [indexPath.row] as? CarePlanObj {
            
            cell.medNameLbl.text = obj.name.capitalized
            var vwDetailY = cell.vwDetail.frame.origin.y
            let vwDetailHeight = cell.vwDetail.frame.size.height
            var imgConditionBg: UIImageView!
            var conditionNameLbl: UILabel!
            var dosageTxtFld: UITextField!
            
            var indexDosage = 0
            
            let medicationType = obj.type
            let bounds = UIScreen.main.bounds.size.width - 44
            
            
            cell.addMedicationView.subviews.forEach({ $0.removeFromSuperview() })
            vwDetailY = 0
            for dosage in obj.dosage{
                let vwDetailNew = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(vwDetailY), width: CGFloat(bounds), height: CGFloat(vwDetailHeight)))
                
                vwDetailNew.subviews.forEach({ $0.removeFromSuperview() })
                vwDetailNew.backgroundColor = UIColor.white
                vwDetailNew.isUserInteractionEnabled = false
                vwDetailNew.tag = 300000 + indexDosage
                
                //Set Left Side condition Background
                let vwWidth = Double(vwDetailNew.frame.size.width)
                
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    
                    dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(0), y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat((vwWidth*36)/100), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                    
                    imgConditionBg = UIImageView(frame: CGRect(x: CGFloat((dosageTxtFld.frame.origin.x + dosageTxtFld.frame.size.width + 2)), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*60)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    
                    conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(imgConditionBg.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*57)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    
                }
                else
                {
                    
                    imgConditionBg = UIImageView(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*60)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x + 10), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*59)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    
                    dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(imgConditionBg.frame.origin.x + imgConditionBg.frame.size.width+2), y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat((vwWidth*36)/100), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                    
                }
                
                
                imgConditionBg.backgroundColor = Colors.DHConditionBg
                imgConditionBg.clipsToBounds = true
                let maskPath : UIBezierPath
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    maskPath = UIBezierPath(roundedRect: imgConditionBg.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: kButtonRadius , height: kButtonRadius))
                    
                }
                else
                {
                    maskPath = UIBezierPath(roundedRect: imgConditionBg.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: kButtonRadius, height: kButtonRadius))
                    
                }
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.view.bounds
                maskLayer.path = maskPath.cgPath
                imgConditionBg.layer.mask = maskLayer
                //  imgConditionBg.layer.masksToBounds = true
                
                
                //Set Left Side condition Text Lable
                
                conditionNameLbl.font = UIFont(name:cell.conditionNameLbl.font.fontName, size: 17)
                conditionNameLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
                conditionNameLbl.numberOfLines = 0
                conditionNameLbl.textColor = UIColor.white
                conditionNameLbl.text = obj.condition[indexDosage]
                conditionNameLbl.tag = 200000 + indexDosage
                conditionNameLbl.backgroundColor = UIColor.clear
                //  conditionNameLbl.backgroundColor = Colors.DHTabBarGreen
                conditionNameLbl.clipsToBounds = true
                
                //Set Left Side dosage TextField with Background
                
                // print("Object")
                //print(obj.type)
                if(dosage == 0)
                {
                    dosageTxtFld.text = ""
                }
                else
                {
                    if medicationType == "Oral Agent"{
                        dosageTxtFld.text = String(dosage) + " mg"
                    }
                    else
                    {
                        dosageTxtFld.text = String(dosage) + " units"
                    }
                    
                }
                dosageTxtFld.font = cell.dosageTxtFld.font
                dosageTxtFld.textColor = cell.dosageTxtFld.textColor
                dosageTxtFld.backgroundColor = Colors.DHConditionBg
                dosageTxtFld.delegate = self
                dosageTxtFld.tag = indexDosage
                dosageTxtFld.clipsToBounds = true
                let maskPath1 : UIBezierPath
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    maskPath1 = UIBezierPath(roundedRect: dosageTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(10.0), height: CGFloat(10.0)))
                }
                else
                {
                    maskPath1 = UIBezierPath(roundedRect: dosageTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(10.0), height: CGFloat(10.0)))
                }
                
                let maskLayer1 = CAShapeLayer()
                maskLayer1.frame = self.view.bounds
                maskLayer1.path = maskPath1.cgPath
                dosageTxtFld.layer.mask = maskLayer1
                // dosageTxtFld.layer.masksToBounds = true
                dosageTxtFld.keyboardType = UIKeyboardType.numberPad
                
                
                if(dosageTxtFld.text?.length == 0)
                {
                    dosageTxtFld.attributedPlaceholder = NSAttributedString(string: "Dose",
                                                                            attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor])
                }
                else
                {
                    dosageTxtFld.attributedPlaceholder = NSAttributedString(string: "",
                                                                            attributes: [NSForegroundColorAttributeName: UIColor.gray])
                }
                
                setleftpadding(textfield: dosageTxtFld)
                
                //add view to Detail View
                vwDetailNew.addSubview(dosageTxtFld)
                vwDetailNew.addSubview(imgConditionBg)
                vwDetailNew.addSubview(conditionNameLbl)
                
                
                indexDosage += 1
                vwDetailNew.clipsToBounds = true
                cell.addMedicationView .addSubview(vwDetailNew)
                vwDetailY = vwDetailY + vwDetailHeight + 10
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let obj: CarePlanObj =  array [indexPath.row] as? CarePlanObj {
            let addHeight = (obj.dosage.count-1) * 45
            return CGFloat(105 + addHeight)
        }
        else
        {
            return 105
        }
    }
    
    func setleftpadding(textfield: UITextField)
    {
        //textfield.layer.cornerRadius = 5
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.clear.cgColor
        
        textfield.leftViewMode = UITextFieldViewMode.always
        let leftView = UIView()
        leftView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        textfield.leftView = leftView
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
    
    func firstResponder(cell: CarePlanMedicationTableViewCell?) {
        //cell?.medicineNameTxtFld .becomeFirstResponder()
    }
    
    func listSubviewsOf(_ view: UIView) {
        
        let subviews = view.subviews
        if subviews.count == 0 {
            return
        }
        for subview: UIView in subviews {
            print("\(subview)")
            if view is UIButton {
                let btn = view as! UIButton
                let strTitle = btn.currentTitle
                if(strTitle == "Edit".localized )
                {
                    btn.setImage(UIImage(named: "save_icon"), for: .normal)
                    btn.setImage(UIImage(named: "save_icon"), for: .highlighted)
                    btn.setTitle("".localized,for: .normal)
                    btn.setTitle("".localized,for: .highlighted)
                    break
                }
            }
            self.listSubviewsOf(subview)
        }
    }
    
    // MARK: - Editable TableView TextField
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if(textField.tag < 100000 && textField.tag != 1001)
        {
            // Create an `NSCharacterSet` set which includes everything *but* the digits
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            // At every character in this "inverseSet" contained in the string,
            // split the string up into components which exclude the characters
            // in this inverse set
            let components = string.components(separatedBy: inverseSet)
            
            
            // Rejoin these components
            let filtered = components.joined(separator: "") // use join("", components) if you are using Swift 1.2
            
            // If the original string is equal to the filtered string, i.e. if no
            // inverse characters were present to be eliminated, the input is valid
            // and the statement returns true; else it returns false
            return string == filtered
        }
        else
        {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(GIntakeViewController.dismissKeyboard(_:))))
        let cell = self.parentCellFor(view: textField)
        if !cell.isViewEmpty {
            let indexPath = self.tblView.indexPathForRow(at: cell.center)!
            selectedIndex = indexPath as NSIndexPath
            self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 280 , 0)
            self.tblView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        textField.tintColor = UIColor.black
        if(textField.tag >= 100000)
        {
            textField.tintColor = UIColor.white
            let indexPos=textField.tag + 100000
            if let theLabel = cell.viewWithTag(indexPos) as? UILabel {
                textField.text = theLabel.text
                textField.backgroundColor = UIColor.clear
                theLabel.text = ""
            }
        }
        else
        {
            var strVal = textField.text
            strVal = strVal?.replacingOccurrences(of: " mg", with: "")
            strVal = strVal?.replacingOccurrences(of: " units", with: "")
            textField.text = strVal
        }
        
        textField.becomeFirstResponder()
    }
    
    private func textFieldDidEndEditing(textField: UITextField, inRowAtIndexPath indexPath: NSIndexPath) {
        let obj: CarePlanObj = (self.array[indexPath.row] as? CarePlanObj)!
        if(textField.tag == 1001)
        {
            obj.name = textField.text!
        }
        else
        {
            if(textField.tag >= 100000)
            {
                let indexPos=textField.tag - 100000
                obj.condition .remove(at: indexPos)
                obj.condition .insert(textField.text! , at: indexPos)
            }
            else
            {
                obj.dosage.remove(at: textField.tag)
                if(textField.text?.length == 0)
                {
                    obj.dosage .insert(0 , at: textField.tag)
                    textField.attributedPlaceholder = NSAttributedString(string: "Dose",
                                                                         attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor])
                }
                else
                {
                    obj.dosage .insert(Int(textField.text!)! , at: textField.tag)
                    textField.attributedPlaceholder = NSAttributedString(string: "",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.gray])
                }
                
                if obj.type == "Oral Agent"{
                    textField.text = String(describing: obj.dosage[textField.tag] ) + " mg"
                }
                else
                {
                    textField.text = String(describing: obj.dosage[textField.tag]) + " units"
                }
            }
            
        }
        array.removeObject(at: indexPath.row)
        array.insert(obj, at: indexPath.row)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField .resignFirstResponder()
        let cell = self.parentCellFor(view: textField)
        
        if !cell.isViewEmpty {
            let indexPath = self.tblView.indexPathForRow(at: cell.center)!
            self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
            self.tblView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        let cell = self.parentCellFor(view: textField)
        
        if !cell.isViewEmpty {
            let indexPath = self.tblView.indexPathForRow(at: cell.center)!
            self.textFieldDidEndEditing(textField: textField, inRowAtIndexPath: indexPath as NSIndexPath)
        }
        if(textField.tag >= 100000)
        {
            let indexPos=textField.tag + 100000
            if let theLabel = cell.viewWithTag(indexPos) as? UILabel {
                theLabel.text = textField.text
                
                if(textField.text?.length == 0)
                {
                    textField.attributedPlaceholder = NSAttributedString(string: "Timing",
                                                                         attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor] )
                }
                else
                {
                    textField.attributedPlaceholder = NSAttributedString(string: "",
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.lightGray] )
                }
                
                textField.text = ""
                textField.background = UIImage(named: "")
            }
        }
    }
    
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        view.removeGestureRecognizer(sender)
    }
}
extension ReportMedicationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let indx = picker.view.tag
        if let obj: CarePlanObj = array[indx] as? CarePlanObj {
            obj.carePlanImageURL =  image
            array.removeObject(at: indx)
            array.insert(obj, at: indx)
            self.tblView .reloadData()
            self.tblView .layoutIfNeeded()
            self.resetUI()
        }
        dismiss(animated: true, completion: {
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
