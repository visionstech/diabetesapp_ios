//
//  MedicationViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import  SVProgressHUD
import SDWebImage

extension UIView {
    var isViewEmpty : Bool {
        return  self.subviews.count == 0 ;
    }
}

class MedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var noMedicationsAvailableLabel: UILabel!
    
    @IBOutlet weak var newtblView: UITableView!
    @IBOutlet weak var oldTblView: UITableView!

    @IBOutlet weak var addNewMedicationBtn: UIButton!
    @IBOutlet weak var addNewMedicationView: UIView!
    @IBOutlet weak var imgAddMedicineIcon: UIImageView!
    
    @IBOutlet weak var lblAddMedicineTitle: UILabel!
    
    @IBOutlet weak var csTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csOldTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csMedicaionViewHeight: NSLayoutConstraint!
    
     @IBOutlet weak var csNewViewMediHeight: NSLayoutConstraint!
     @IBOutlet weak var csOldViewMediHeight: NSLayoutConstraint!
    
     @IBOutlet weak var csBottomScrollView: NSLayoutConstraint!
    
    @IBOutlet weak var NewViewMedi: UIView!
    @IBOutlet weak var OldViewMedi: UIView!
    
    @IBOutlet weak var medicaionView: UIView!
    @IBOutlet weak var medicaionScroll: UIScrollView!
    
    @IBOutlet weak var lblNewChangeByDr: UILabel!
    @IBOutlet weak var lblOldChangeByDr: UILabel!
    
    let picker = UIImagePickerController()
    var newMedarray = NSMutableArray()
    var oldMedArray =  NSMutableArray()
    var selectedIndex : NSIndexPath = NSIndexPath()
    var editMedArray = NSMutableArray()
    var isnewConditionAdd : Bool = false
    var isComeFromReport : Bool = false
 
    var addNewCurrentMedArray = NSArray()
    var editNewCurrentMedArray = NSArray()
    var deleteNewCurrentMedArray = NSArray()
    
    
    var formInterval: GTInterval!
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    let loggedInUserID : String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
    
    var newImageView : UIImageView = UIImageView()
    var scrollV : UIScrollView = UIScrollView()
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.allowsEditing = false
        picker.delegate = self
        lblAddMedicineTitle.text = "ADD_MEDICATION_LABEL".localized
        noMedicationsAvailableLabel.text = "No Medications Available".localized
        noMedicationsAvailableLabel.isHidden = true
        addNewMedicationView.backgroundColor = Colors.PrimaryColor

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kMedicationScreenName)
        //--------Google Analytics Finish-----
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            
            self.lblAddMedicineTitle.frame = CGRect(x:self.lblAddMedicineTitle.frame.origin.x - 40 , y:self.lblAddMedicineTitle.frame.origin.y, width: self.lblAddMedicineTitle.frame.size.width , height:self.lblAddMedicineTitle.frame.size.height )
            self.imgAddMedicineIcon.frame = CGRect(x:self.imgAddMedicineIcon.frame.origin.x - 20 , y:self.imgAddMedicineIcon.frame.origin.y, width: self.imgAddMedicineIcon.frame.size.width , height:self.imgAddMedicineIcon.frame.size.height )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            print( UserDefaults.standard.bool(forKey: "MedEditBool"))
            if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                self.groupChatWithEditConfig()
            }
            else{
                getMedicationsData()
            }
        }
        else
        {
            getMedicationsData()
        }
        
        if(selectedUserType == userType.patient)
        {
            self.addNewMedicationView.isHidden = true
            self.newtblView.setNeedsUpdateConstraints()
            self.csBottomScrollView.constant = 0
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        scrollV = UIScrollView()
        scrollV.frame = self.view.frame
        scrollV.minimumZoomScale=1.0
        scrollV.maximumZoomScale=6.0
        scrollV.bounces=false
        scrollV.delegate=self;
        self.view.addSubview(scrollV)
        
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = scrollV.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode =  .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        scrollV.addSubview(newImageView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?
    {
        return newImageView
    }
    
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        scrollV.removeFromSuperview()
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
        if self.newMedarray.count > 0 {
            newtblView.isHidden = false
            noMedicationsAvailableLabel.isHidden = true
            self.lblNewChangeByDr.isHidden = false
        }
        else {
            
            newtblView.isHidden = true
            noMedicationsAvailableLabel.isHidden = false
            self.lblNewChangeByDr.isHidden = true
        }
        if self.oldMedArray.count > 0 {
            oldTblView.isHidden = false
            self.lblOldChangeByDr.isHidden = false
        }
        else {
            oldTblView.isHidden = true
            self.lblOldChangeByDr.isHidden = true
        }
    }
    func resetUIForTable()
    {
        if(self.selectedUserType != userType.patient)
        {
            newtblView.layer.cornerRadius = kButtonRadius
            newtblView.layer.borderWidth = 1
            newtblView.layer.borderColor = Colors.PrimaryColor.cgColor
            
            oldTblView.layer.cornerRadius = kButtonRadius
            oldTblView.layer.borderWidth = 1
            oldTblView.layer.borderColor = Colors.PrimaryColor.cgColor
            
            oldTblView.backgroundColor = Colors.oldMedicationTableBGColor
            
             self.oldTblView.isHidden = false
        }
        
        else
        {
             oldTblView.backgroundColor = UIColor.clear
             newtblView.backgroundColor = UIColor.clear
            
            OldViewMedi.backgroundColor = UIColor.clear
            NewViewMedi.backgroundColor = UIColor.clear
            
            self.oldTblView.isHidden = true
            
        }
    }
    
    func readingMedicationNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let cell = self.newtblView.cellForRow(at: selectedIndex as IndexPath) as! CarePlanMedicationTableViewCell
       
        if let medicationname = userInfo["medicationname"] as? String {
            //if let medicationtype = userInfo["type"] as? String {
            for data in dictMedicationList {
                if let medication = data as? medicationObj {
                    if(medication.medicineName == medicationname)
                    {
                        if let obj: CarePlanObj = self.newMedarray[selectedIndex.row] as? CarePlanObj {
                            
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

                                                        
                                                        self?.newMedarray.removeObject(at: (self?.selectedIndex.row)!)
                                                        self?.newMedarray.insert(obj, at: (self?.selectedIndex.row)!)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.editMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.editMedicationNotification), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.closeAddNewMedication(notification:)), name: NSNotification.Name(rawValue: Notifications.closeAddNewMedication), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        
    }
    
    func groupChatWithEditConfig()
    {
        self.newMedarray = NSMutableArray()
        self.oldMedArray = NSMutableArray()
        var totalHeightForTableNew = 0
        var totalHeightForTableOld = 0
        
        let repoMedArray : NSArray = UserDefaults.standard.array(forKey: "repoMediArray")! as [Any] as NSArray
        let repoOldMediArray : NSArray = UserDefaults.standard.array(forKey: "repoOldMediArray")! as [Any] as NSArray
        
        let repoMediArray = NSMutableArray(array: repoMedArray)
        
        
        for data in repoOldMediArray {
            let dict: NSDictionary = data as! NSDictionary
            let obj = CarePlanObj()
            //                    if (dict.value(forKey: "_id") == nil)
            //                    {
            //                        obj.id = dict.value(forKey: "id") as! String
            //                    }
            //                    else
            //                    {
            //                        obj.id = dict.value(forKey: "_id") as! String
            //                    }
            
            obj.name = dict.value(forKey: "name") as! String
            
            if let medIndex = dict.value(forKey: "medindex"){
                obj.tempIndex = medIndex as! Int
            }
            
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
            if(self.selectedUserType == userType.patient)
            {
                if(obj.dosage.count>=3)
                {
                    let addHeight = (obj.dosage.count-3) * 45
                    totalHeightForTableOld = totalHeightForTableOld +  (230 + addHeight)
                }
                else
                {
                    totalHeightForTableOld = totalHeightForTableOld +  210
                }
                
            }else
            {
                totalHeightForTableOld = totalHeightForTableOld + ((obj.dosage.count * 45) + 35)
            }
            
            self.oldMedArray.add(obj)
        }
        
        for data in repoMediArray {
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
            
            if let medIndex = dict.value(forKey: "medindex"){
                obj.tempIndex = medIndex as! Int
            }
            
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
            
            if let updatedName = dict.value(forKey: "updatedByName"){
                obj.updatedBy = updatedName as! String
            }
            
            if self.selectedUserType != userType.patient{
                self.lblNewChangeByDr.text = "Updated by \(obj.updatedBy )"
            }
            else{
                self.lblNewChangeByDr.text = ""
            }
            
            self.newMedarray.add(obj)
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
            for i in 0..<self.newMedarray.count {
                let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.newMedarray.replaceObject(at: i, with: obj)
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
            self.newMedarray.add(obj)
        }
        
        //Delete Medication Data From the cashe
        let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
        self.deleteNewCurrentMedArray = NSMutableArray(array: tempDeleteArray)
        for data1 in self.deleteNewCurrentMedArray{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.newMedarray.count {
                let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.newMedarray.remove(objCarPlan)
                    break
                }
            }
        }
        
        //calculateheight
        for indexNew in 0..<self.newMedarray.count{
            let objNew = self.newMedarray[indexNew] as! CarePlanObj
            if(self.selectedUserType == userType.patient)
            {
                if(objNew.dosage.count>3)
                {
                    let addHeight = (objNew.dosage.count-3) * 45
                    totalHeightForTableNew = totalHeightForTableNew +  (210 + addHeight)
                }
                else
                {
                    totalHeightForTableNew = totalHeightForTableNew +  210
                }
                
            }else
            {
                totalHeightForTableNew = totalHeightForTableNew + ((objNew.dosage.count * 45) + 35)
            }
        }
        
        if self.selectedUserType != userType.patient{
            self.oldTblView.reloadData()
            self.oldTblView.layoutIfNeeded()
        }
        self.resetUI()
        
        self.newtblView.updateConstraintsIfNeeded()
        
        self.resetUIForTable()
        
        self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
        self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
        
        self.csNewViewMediHeight.constant = CGFloat(totalHeightForTableNew + 40)
        self.csOldViewMediHeight.constant = CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
        
        self.csMedicaionViewHeight.constant = CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
        
        self.medicaionScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40))
        
        self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)
    }
    //MARK: - Notifications Methods
    func medicationNotification(notification: NSNotification) {
        
    }
    
    func addNewMedicationNotification(notification: NSNotification) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                
              self.groupChatWithEditConfig()
                
            }
            else
            {
                  self.getMedicationsData()
            }
        }
        else
        {
             self.getMedicationsData()
        }
      
    }
    func editMedicationNotification(notification: NSNotification) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                
                self.newMedarray = NSMutableArray()
                self.oldMedArray = NSMutableArray()
                var totalHeightForTableNew = 0
                var totalHeightForTableOld = 0
                
                let repoMedArray : NSArray = UserDefaults.standard.array(forKey: "repoMediArray")! as [Any] as NSArray
                let repoOldMediArray : NSArray = UserDefaults.standard.array(forKey: "repoOldMediArray")! as [Any] as NSArray
                
                let repoMediArray = NSMutableArray(array: repoMedArray)
                
                for data in repoOldMediArray {
                    let dict: NSDictionary = data as! NSDictionary
                    let obj = CarePlanObj()
                  
                    obj.name = dict.value(forKey: "name") as! String
                    
                    if let medIndex = dict.value(forKey: "medindex"){
                        obj.tempIndex = medIndex as! Int
                    }
                    
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
                    if(self.selectedUserType == userType.patient)
                    {
                        if(obj.dosage.count>=3)
                        {
                            let addHeight = (obj.dosage.count-3) * 45
                            totalHeightForTableOld = totalHeightForTableOld +  (230 + addHeight)
                        }
                        else
                        {
                            totalHeightForTableOld = totalHeightForTableOld +  210
                        }
                        
                    }else
                    {
                        totalHeightForTableOld = totalHeightForTableOld + ((obj.dosage.count * 45) + 35)
                    }
                    
                    self.oldMedArray.add(obj)
                }
                
                for data in repoMediArray {
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
                    
                    if let medIndex = dict.value(forKey: "medindex"){
                        obj.tempIndex = medIndex as! Int
                    }
                    
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
                    
                    if let updatedName = dict.value(forKey: "updatedByName"){
                        obj.updatedBy = updatedName as! String
                    }
                    
                    if self.selectedUserType != userType.patient{
                        self.lblNewChangeByDr.text = "Updated by \(obj.updatedBy )"
                    }
                    else{
                        self.lblNewChangeByDr.text = ""
                    }
                    
                    self.newMedarray.add(obj)
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
                    for i in 0..<self.newMedarray.count {
                        let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                        if(objCarPlan.id ==  obj.id )
                        {
                            self.newMedarray.replaceObject(at: i, with: obj)
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
                    self.newMedarray.add(obj)
                }
                
                //Delete Medication Data From the cashe
                let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
                self.deleteNewCurrentMedArray = NSMutableArray(array: tempDeleteArray)
                for data1 in self.deleteNewCurrentMedArray{
                    let dict: NSDictionary = data1 as! NSDictionary
                    let obj = CarePlanObj()
                    obj.id = dict.value(forKey: "id") as! String
                    for i in 0..<self.newMedarray.count {
                        let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                        if(objCarPlan.id ==  obj.id )
                        {
                            self.newMedarray.remove(objCarPlan)
                            break
                        }
                    }
                }
                
                //calculateheight
                for indexNew in 0..<self.newMedarray.count{
                    let objNew = self.newMedarray[indexNew] as! CarePlanObj
                    if(self.selectedUserType == userType.patient)
                    {
                        if(objNew.dosage.count>3)
                        {
                            let addHeight = (objNew.dosage.count-3) * 45
                            totalHeightForTableNew = totalHeightForTableNew +  (210 + addHeight)
                        }
                        else
                        {
                            totalHeightForTableNew = totalHeightForTableNew +  210
                        }
                        
                    }else
                    {
                        totalHeightForTableNew = totalHeightForTableNew + ((objNew.dosage.count * 45) + 35)
                    }
                }
                
                if self.selectedUserType != userType.patient{
                    self.oldTblView.reloadData()
                    self.oldTblView.layoutIfNeeded()
                }
                self.resetUI()
                
                self.newtblView.updateConstraintsIfNeeded()
                
                self.resetUIForTable()
                
                self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
                self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
                
                self.csNewViewMediHeight.constant = CGFloat(totalHeightForTableNew + 40)
                self.csOldViewMediHeight.constant = CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
                
                self.csMedicaionViewHeight.constant = CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
                
                self.medicaionScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40))
                
                self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)
                
            }
            else
            {
                self.getMedicationsData()
            }
        }
        else
        {
            self.getMedicationsData()
        }
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
        self.newtblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
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
        let index: Int = (sender as AnyObject).tag
        
        let objCopy: CarePlanObj = (self.newMedarray[index] as? CarePlanObj)!
        objCopy.isEdit = true
        let viewController = self.storyboard!.instantiateViewController(withIdentifier: "editmedication") as! EditMedicationViewController
        viewController.editableObjCopy = self.setEditableValue(careObj: (self.newMedarray[index] as? CarePlanObj)!)
        
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        let popupHeight =  ((objCopy.dosage.count * 45) + 150)
        formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: CGFloat(popupHeight) > CGFloat(self.view.bounds.height) ? self.view.bounds.height - 100 : CGFloat(popupHeight) )
        formSheetController.presentationController?.containerView?.layer.cornerRadius = kButtonRadius
         formSheetController.presentationController?.containerView?.layer.borderWidth = 1
        formSheetController.presentationController?.containerView?.layer.borderColor =  Colors.PrimaryColor.cgColor
        
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        self.present(formSheetController, animated: true, completion: nil)
        
    }
    func setEditableValue (careObj : CarePlanObj) -> CarePlanObj
    {
        let objCarePlanObj = CarePlanObj()
        objCarePlanObj.id = careObj.id
        objCarePlanObj.dosage = careObj.dosage
        objCarePlanObj.condition = careObj.condition
        objCarePlanObj.name = careObj.name
        objCarePlanObj.nameAr = careObj.nameAr
        objCarePlanObj.isNew = careObj.isNew
        objCarePlanObj.carePlanImageURL = careObj.carePlanImageURL
        objCarePlanObj.isEdit = careObj.isEdit
        objCarePlanObj.strImageURL = careObj.strImageURL
        objCarePlanObj.type = careObj.type
        objCarePlanObj.updatedBy = careObj.updatedBy
        objCarePlanObj.tempIndex = careObj.tempIndex
        objCarePlanObj.wasUpdated = careObj.wasUpdated
        objCarePlanObj.updatedDate = careObj.updatedDate
        objCarePlanObj.dosageNew = careObj.dosageNew
        objCarePlanObj.medNew = careObj.medNew
        objCarePlanObj.deletedCondition = careObj.deletedCondition
        objCarePlanObj.deletedDosage = careObj.deletedDosage
        objCarePlanObj.timingID = careObj.timingID
        return objCarePlanObj
    }
    @IBAction func btnAdd_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add medication Clicked" , label:"Add care plan medication condition")
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let cell = self.parentCellFor(view: btn)
        self.listSubviewsOf(cell)
        if let obj1: CarePlanObj = self.newMedarray[index] as? CarePlanObj {
            
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
                self.newMedarray.removeObject(at: index)
                self.newMedarray.insert(obj1, at: index)
                self.resetUI()
                self.newtblView .reloadData()
                self.newtblView .layoutIfNeeded()
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
            let indexPath = self.newtblView.indexPathForRow(at: cell.center)!
            if let obj: CarePlanObj = self.newMedarray[indexPath.row] as? CarePlanObj {
                /*if(obj.dosage.count<=1)
                {
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"delete Card Medication Field" , label:"Medication must have one condition and dosage")
                     showAlert(title: "Data missing", message: "Please input atleast one condition value".localized)
                }
                else
                {*/
                    obj.dosage.remove(at: index)
                    obj.condition.remove(at: index)
                    self.newMedarray.removeObject(at: indexPath.row)
                    self.newMedarray.insert(obj, at: indexPath.row)
                    self.newtblView .reloadData()
                    self.newtblView .layoutIfNeeded()
                    self.resetUI()
                //}
                
            }
        }
    }

    @IBAction func DeleteMedication_Click(_ sender: Any) {
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        
        if let obj: CarePlanObj = self.newMedarray[index] as? CarePlanObj {
            
            
            if  UserDefaults.standard.bool(forKey: "MedEditBool") {
               
                let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                let mainDict: NSMutableDictionary = NSMutableDictionary()
                
                mainDict.setValue(obj.id, forKey: "id")
                mainDict.setValue(obj.name, forKey: "name")
                mainDict.setValue(obj.dosage, forKey: "dosage")
                mainDict.setValue(obj.condition, forKey: "condition")
                mainDict.setValue(loggedInUserID, forKey: "updatedBy")
                mainDict.setValue(loggedInUserName, forKey: "updatedByName")
                
                let addTiming = NSMutableArray()
                for i in 0..<obj.dosage.count {
                    let mainDictTiming: NSMutableDictionary = NSMutableDictionary()
                    mainDictTiming.setValue(obj.dosage[i], forKey: "dosage")
                    mainDictTiming.setValue(obj.condition[i] ,  forKey:"condition")
                    addTiming.add(mainDictTiming)
                }
                mainDict.setValue(addTiming, forKey: "timing")

                UserDefaults.standard.synchronize()
            }
            else
            {
               self.deleteMedications(careObj: obj)
            }
            
            self.newMedarray.removeObject(at: index)
            self.newtblView.reloadData()
//            tblView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
//            for i in index..<array.count {
//                self.newtblView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
//            }
            
            self.resetUI()
        }
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Delete Medication Click" , label:"User Click on delete Medication Click")
       
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
        //"\(baseUrl)\(ApiMethods.updatecareplan)"
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            switch response.result {
            case .success:
                careObj.isEdit = false
                SVProgressHUD.showSuccess(withStatus: "Medication Updated".localized, maskType: SVProgressHUDMaskType.clear)
                //Google Analytic
                  GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplan) Calling", action:"Success -Update care Plan" , label:"Care Plan Data Updated Successfully", value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                self.newtblView.reloadData()
                self.newtblView .layoutIfNeeded()
                
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
        
        //\(baseUrl)\(ApiMethods.deletecareplan)
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
            "userid": patientsID,
            "loggedInUser": loggedInUserID
        ]
        UIApplication.shared.endIgnoringInteractionEvents()
        //self.view.isUserInteractionEnabled = true
        SVProgressHUD.show(withStatus: "Loading Medications".localized)
         self.formInterval = GTInterval.intervalWithNowAsStartDate()
        //"\(baseUrl)\(ApiMethods.getcareplan)"
        Alamofire.request("\(baseUrl)\(ApiMethods.getcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            SVProgressHUD.dismiss()
            switch response.result {
            case .success:
                
                print("Validation Successful")
                self.newMedarray = NSMutableArray()
                self.oldMedArray = NSMutableArray()
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getcareplanUpdated Calling", action:"Success - get Medications List" , label:"get Medications Listed Successfully", value : self.formInterval.intervalAsSeconds())
                
                var totalHeightForTableNew = 0
                var totalHeightForTableOld = 0
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    //if let jsonOldMeds : NSDictionary = JSON.value(forKey: "oldMedicineList") as? NSDictionary
                   // {
                        if let jsonOldMedsArray : NSArray = JSON.value(forKey: "oldMedicineList") as? NSArray {
                                for dataOld in jsonOldMedsArray {
                                let dictOld: NSDictionary = dataOld as! NSDictionary
                                let objOld = CarePlanObj()
                                if dictOld.value(forKey: "id") != nil{
                                    objOld.id = dictOld.value(forKey: "id") as! String
                                }
                                else if dictOld.value(forKey: "_id") != nil{
                                        objOld.id = dictOld.value(forKey: "_id") as! String
                                }
                                //objOld.id = dictOld.value(forKey: "id") as! String
                                objOld.name = dictOld.value(forKey: "name") as! String
                                if let medtype = dictOld.value(forKey: "medType"){
                                    objOld.type =  medtype as! String
                                }
                                else{
                                    objOld.type =  ""
                                }
                                
                                //obj.type = dict.value(forKey: "medType") as! String
                                objOld.isNew = false
                                //objOld.isEdit = false
                                // objOld.wasUpdated = dictOld.value(forKey: "isNew") as! Bool
                                if let updatedName = dictOld.value(forKey: "updatedByName"){
                                        objOld.updatedBy = updatedName as! String
                                }
                                objOld.updatedDate = dictOld.value(forKey: "lastUpdatedDate") as! String
                                
                                if self.selectedUserType != userType.patient{
                                    let updatedByString : String = JSON.value(forKey: "oldMedsUpdatedBy") as! String
                                    let updatedDate : String = JSON.value(forKey: "oldMedsLastUpdated") as! String
                                    
                                    self.lblOldChangeByDr.text = "Updated by \(updatedByString) \(updatedDate)"
                                }
                                else{
                                     self.lblOldChangeByDr.text = ""
                                }
                               
                                //obj.type = dict.value(forKey: "name") as! String
                                // obj.carePlanImageURL =   UIImage(named:"med.png")!
                                
                                
                                if let timingArrayOld: NSArray = dictOld.value(forKey: "timing") as? NSArray{
                                    for timingOld in timingArrayOld{
                                        let tempDict: NSDictionary = timingOld as! NSDictionary
                                        objOld.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                        objOld.condition.append(tempDict.value(forKey:"condition") as! String)
                                        if tempDict.value(forKey: "id") != nil{
                                           objOld.timingID.append(tempDict.value(forKey:"id") as! String)
                                        }
                                        else if dictOld.value(forKey: "_id") != nil{
                                            objOld.timingID.append(tempDict.value(forKey:"_id") as! String)
                                        }
                                        else if dictOld.value(forKey: "medid") != nil{
                                            objOld.timingID.append(tempDict.value(forKey:"medid") as! String)
                                        }
                                       
                                        //objOld.condition.append(tempDict.value(forKey:"condition") as! String)
                                    }
                                }
                                    if(self.selectedUserType == userType.patient)
                                    {
                                        if(objOld.dosage.count>=3)
                                        {
                                            let addHeight = (objOld.dosage.count-3) * 45
                                            totalHeightForTableOld = totalHeightForTableOld +  (230 + addHeight)
                                        }
                                        else
                                        {
                                            totalHeightForTableOld = totalHeightForTableOld +  210
                                        }
                                        
                                    }else
                                    {
                                        totalHeightForTableOld = totalHeightForTableOld + ((objOld.dosage.count * 45) + 35)
                                    }
                                self.oldMedArray.add(objOld)
                                
                            }
                            
                        }
                    //}

                    if  let JSONNew :  NSArray = JSON.value(forKey: "medicineList") as? NSArray{
                        
                        //                    self.newMedarray = NSMutableArray()
                        for data in JSONNew {
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
                            
                            //obj.type = dict.value(forKey: "medType") as! String
                            obj.isNew = false
                            obj.isEdit = false
                            obj.wasUpdated = dict.value(forKey: "isNew") as! Bool
                            obj.updatedBy = dict.value(forKey: "updatedByName") as! String
                            obj.updatedDate = dict.value(forKey: "lastUpdatedDate") as! String
                            obj.dosageNew = dict.value(forKey: "conDosBoolArray") as! [Bool]
                            
                            if self.selectedUserType != userType.patient{
                                let updatedByStringNew : String = JSON.value(forKey: "currentMedsUpdatedBy") as! String
                                let updatedDateNew : String = JSON.value(forKey: "currentMedsLastUpdated") as! String
                                
                                self.lblNewChangeByDr.text = "Updated by \(updatedByStringNew) \(updatedDateNew)"
                            }
                            else{
                                 self.lblNewChangeByDr.text = ""
                            }
                            
                            //obj.type = dict.value(forKey: "name") as! String
                            // obj.carePlanImageURL =   UIImage(named:"med.png")!
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
                                    obj.timingID.append(tempDict.value(forKey:"_id") as! String)
                                }
                            }
                            
                            self.newMedarray.add(obj)
                            
                        }
                    }
                }
                
                
                 if  UserDefaults.standard.bool(forKey: "MedEditBool") {
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
                    for i in 0..<self.newMedarray.count {
                        let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                        if(objCarPlan.id ==  obj.id )
                        {
                            self.newMedarray.replaceObject(at: i, with: obj)
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
                    self.newMedarray.add(obj)
                }
                
                //Delete Medication Data From the cashe
                let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
                self.deleteNewCurrentMedArray = NSMutableArray(array: tempDeleteArray)
                for data1 in self.deleteNewCurrentMedArray{
                    let dict: NSDictionary = data1 as! NSDictionary
                    let obj = CarePlanObj()
                    obj.id = dict.value(forKey: "id") as! String
                    for i in 0..<self.newMedarray.count {
                        let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                        if(objCarPlan.id ==  obj.id )
                        {
                            self.newMedarray.remove(objCarPlan)
                            break
                        }
                    }
                }
                    
            }
                var badgeIconCarePlanCount : Int = 0
                for indexNew in 0..<self.newMedarray.count{
                    var objNew = self.newMedarray[indexNew] as! CarePlanObj
                    if objNew.wasUpdated
                    {
                        badgeIconCarePlanCount = badgeIconCarePlanCount + 1
                    }
                    
                }
                
                if badgeIconCarePlanCount > 0
                {
                    careplanTabBarItem.badgeValue = String(badgeIconCarePlanCount)
                }
                else{
                    careplanTabBarItem.badgeValue = nil
                }
                
                //print("Object medication array")
               // print(self.newMedarray)
                self.newtblView.reloadData()
                self.newtblView.layoutIfNeeded()
                
                //var deleted
                /*for indexNew in 0..<self.newMedarray.count-1{
                    let objNew = self.newMedarray[indexNew] as! CarePlanObj
                    for indexOld in 0..<self.oldMedArray.count-1{
                        let objOld = self.oldMedArray[indexOld] as! CarePlanObj
                        
                        if objOld.id == objNew.id{
                            if objOld.timingID.count > objNew.timingID.count{
                                for tempIDOldIndex in 0..<objOld.timingID.count{
                                    var isPresent: Bool = true
                                    for tempIDNewIndex in 0..<objNew.timingID.count
                                    {
                                        if objOld.timingID[tempIDOldIndex] == objNew.timingID[tempIDNewIndex]{
                                            isPresent = false
                                        }
                                    }
                                    
                                    if !isPresent{
                                        objNew.deletedDosage.append(objOld.dosage[tempIDOldIndex])
                                        objNew.deletedCondition.append(objOld.condition[tempIDOldIndex])
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                }*/
                
                //calculateheight
                for indexNew in 0..<self.newMedarray.count{
                    let objNew = self.newMedarray[indexNew] as! CarePlanObj
                    if(self.selectedUserType == userType.patient)
                    {
                        if(objNew.dosage.count>3)
                        {
                            let addHeight = (objNew.dosage.count-3) * 45
                            totalHeightForTableNew = totalHeightForTableNew +  (210 + addHeight)
                        }
                        else
                        {
                            totalHeightForTableNew = totalHeightForTableNew +  210
                        }
                        
                    }else
                    {
                        totalHeightForTableNew = totalHeightForTableNew + ((objNew.dosage.count * 45) + 35)
                    }
                }
                
                
                if self.selectedUserType != userType.patient{
                    self.oldTblView.reloadData()
                    self.oldTblView.layoutIfNeeded()
                }
                self.resetUI()
        
                self.newtblView.updateConstraintsIfNeeded()
            
                self.resetUIForTable()
                
                totalHeightForTableOld = self.selectedUserType == userType.patient ? 0 : totalHeightForTableOld
                
                self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
                self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
                
                self.csNewViewMediHeight.constant = CGFloat(totalHeightForTableNew + 40)
                self.csOldViewMediHeight.constant = CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
                
                self.csMedicaionViewHeight.constant = CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40)
                
                self.medicaionScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 40) +  CGFloat(totalHeightForTableOld == 0 ? 0 : totalHeightForTableOld + 40))
                
                self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)
                break
            case .failure(let error):
                print("failure")
                var strError = ""
                if(error.localizedDescription.length>0)
                {
                    strError = error.localizedDescription
                }
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "getcareplanUpdated Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                self.newMedarray = NSMutableArray()
                self.oldMedArray = NSMutableArray()
                self.newtblView.reloadData()
                self.newtblView.layoutIfNeeded()
                if self.selectedUserType != userType.patient{
                    self.oldTblView.reloadData()
                    self.oldTblView.layoutIfNeeded()
                }
                self.resetUI()
                
                SVProgressHUD.dismiss()
                break
                
            }
        }
        
    }
    
    fileprivate func configureSimpleSearchTextField(medicationTextField: AutocompleteSearchTextField) {
        // Start visible - Default: false
        medicationTextField.startVisible = true
        // Set data source
        medicationTextField.filterStrings(dictMedicationName)
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
            for i in 0..<self.newMedarray.count {
                let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.newMedarray.replaceObject(at: i, with: obj)
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
            obj.tempIndex = dict.value(forKey: "medindex") as! Int
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
            self.newMedarray.add(obj)
        }
        
        //Delete Medication Data From the cache
        let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
        let deleteMedArray = NSMutableArray(array: tempDeleteArray)
        for data1 in deleteMedArray{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.newMedarray.count {
                let objCarPlan = (self.newMedarray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.newMedarray.remove(objCarPlan)
                    break
                }
            }
        }
    }

    
    //MARK: - TableView Delegate Methods
    func reloadTable()
    {
        self.newtblView.reloadData()
        self.newtblView.layoutIfNeeded()
        self.oldTblView.reloadData()
        self.oldTblView.layoutIfNeeded()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.newtblView
        {
            if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
                self.newtblView.layoutIfNeeded()
                self.newtblView.setNeedsDisplay()
            }
        }
        else
        {
            if indexPath.row == (tableView.indexPathsForVisibleRows!.last! as NSIndexPath).row {
                self.oldTblView.layoutIfNeeded()
                self.oldTblView.setNeedsDisplay()
            }
        }
      
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(selectedUserType == userType.patient)
        {
            // For New Medication Table Row
            if tableView == self.newtblView
            {
               return self.newMedarray.count;
               
            }
            //For Old Medication Table Row
            else
            {
               return 0;
            }
        }
        else
        {
            // For New Medication Table Row
            if tableView == self.newtblView
            {
                if let obj: CarePlanObj = self.newMedarray[section] as? CarePlanObj {
                    return obj.dosage.count;
                }
                else
                {
                    return 0;
                }
            }
                //For Old Medication Table Row
            else
            {
                if let obj: CarePlanObj = self.oldMedArray[section] as? CarePlanObj {
                    return obj.dosage.count;
                }
                else
                {
                    return 0;
                }
            }
        }
       
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(selectedUserType == userType.patient)
        {
            return 0;
        }
        else
        {
            // For New Medication Table height For Header
            if tableView == self.newtblView
            {
                return 35
            }
                // For Old Medication Table height For Header
            else
            {
                return 21
            }
        }
       
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView: UIView = UIView(frame: CGRect(x: 80, y: 0, width: (tableView.frame.size.width-20), height: 35))
        headerView.backgroundColor = UIColor.clear
        let lbl: UILabel = UILabel(frame: CGRect(x: 11, y: 0, width: headerView.frame.size.width, height: 35))
        lbl.textColor =  Colors.historyHeaderColor
        
        // Only Show Edit button for New Medication Table And if user not patient
        if tableView == self.newtblView && selectedUserType != userType.patient
        {
            lbl.textColor = Colors.historyHeaderColor
            var xpost = tableView.frame.size.width - 40
            if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                xpost = 11
            }
            else
            {
                xpost = tableView.frame.size.width - 40
            }
            let btnEdit: UIButton = UIButton(frame: CGRect(x: xpost, y: 0, width: 35, height: 35))
            btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
            btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
            btnEdit.tag = section
            btnEdit.addTarget(self, action: #selector(EditMedication_Click(_:)), for: .touchUpInside)
            headerView.addSubview(btnEdit)
        }
        
        lbl.font = Fonts.HistoryHeaderFont
        //Assgin Medicaition Name based on New and Old medication Data table
        if let obj: CarePlanObj = tableView == self.newtblView ? self.newMedarray[section] as? CarePlanObj : self.oldMedArray[section] as? CarePlanObj {
            lbl.text = obj.name.capitalized
        }
        
        headerView.addSubview(lbl)
        headerView.tag = section
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(selectedUserType == userType.patient)
        {
            return 1;
        }
        else
        {
            if tableView == self.newtblView
            {
                return self.newMedarray.count
            }
            else
            {
                return self.oldMedArray.count
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(selectedUserType == userType.patient)
        {
           
            let cell : CarePlanMedicationPatientCell = tableView.dequeueReusableCell(withIdentifier: "medicationPatientCell") as! CarePlanMedicationPatientCell
            
            cell.selectionStyle = .none
            cell.isUserInteractionEnabled = true
            cell.tag = indexPath.row
            cell.editBtn.tag = indexPath.row
            cell.deleteBtn.tag = indexPath.row
            cell.medImgBtn.tag = indexPath.row
            cell.closeBtn.tag = indexPath.row
            
            cell.deleteBtn.isHidden = true
            cell.deleteBtn.isUserInteractionEnabled = false
            
            cell.closeBtn.isHidden = true
            cell.closeBtn.isUserInteractionEnabled = false
        
            cell.editBtn.isHidden = true
            cell.editBtn.isUserInteractionEnabled = false
            
            cell.medImgView.isHidden = true
            cell.medImageView.isHidden = false
            
           
            
            if let obj: CarePlanObj = tableView == self.newtblView ? self.newMedarray[indexPath.row] as? CarePlanObj : self.oldMedArray[indexPath.row] as? CarePlanObj {
                // Check Card is new or Old based on that set View
                cell.medNameLbl.isHidden = false
                
                cell.medNameLbl.text = obj.name.capitalized
                //Set Default View and Value
                var vwDetailY = cell.vwDetail.frame.origin.y
                let vwDetailHeight = cell.vwDetail.frame.size.height
                var imgConditionBg: UIImageView!
                var conditionNameLbl: UILabel!
                var dosageTxtFld: UITextField!
                var conditionTxtFld: UITextField!
                var indexDosage = 0
                
                let medicationType = obj.type
                let bounds = UIScreen.main.bounds.size.width

                cell.medImageView.image = obj.carePlanImageURL
                
                let manager:SDWebImageManager = SDWebImageManager.shared()
                
                manager.downloadImage(with: NSURL(string: obj.strImageURL) as URL!,
                                      options: SDWebImageOptions.highPriority,
                                      progress: nil,
                                      completed: {[weak self] (image, error, cached, finished, url) in
                                        if (error == nil && (image != nil) && finished) {
                                            cell.medImageView.image = image!
                                        }
                })
                let tapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                cell.medImageView.isUserInteractionEnabled = true
                cell.medImageView.addGestureRecognizer(tapGestureRecognizer)
                
                
                cell.addMedicationView.subviews.forEach({ $0.removeFromSuperview() })
                vwDetailY = 0
                for dosage in obj.dosage{
                    let vwDetailNew = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(vwDetailY), width: CGFloat(bounds-(cell.medImgView.frame.width+45)), height: CGFloat(vwDetailHeight)))
                    
                    vwDetailNew.subviews.forEach({ $0.removeFromSuperview() })
                    
                    var trueCount = 0;
                    let boolArray : [Bool] = obj.dosageNew
                    
                    for index in 0..<boolArray.count{
                        if boolArray[index]
                        {
                            trueCount = trueCount + 1
                        }
                    }
                    
                    if trueCount == boolArray.count{
                        //cell.mainView.layer.backgroundColor = UIColor.orange.cgColor
                        //cell.addMedicationView.layer.backgroundColor = UIColor.orange.cgColor
                        cell.updateMedicationSticker.isHidden = false
                        
                    }
                    else if trueCount == 0 && obj.wasUpdated{
                      /*  cell.mainView.layer.backgroundColor = UIColor.orange.cgColor
                        cell.addMedicationView.layer.backgroundColor = UIColor.orange.cgColor*/
                        cell.updateMedicationSticker.isHidden = false
                    }
                    else{
                        cell.mainView.layer.backgroundColor = UIColor.white.cgColor
                        cell.addMedicationView.layer.backgroundColor = UIColor.white.cgColor
                        cell.updateMedicationSticker.isHidden = true
                    }
                    

                    
                    vwDetailNew.tag = 300000 + indexDosage
                    //Set Left Side condition Background
                    
                    let vwWidth = Double(vwDetailNew.frame.size.width)
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        
                            dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(10), y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat((vwWidth*38)/100), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                            imgConditionBg = UIImageView(frame: CGRect(x: CGFloat((dosageTxtFld.frame.origin.x + dosageTxtFld.frame.size.width + 3)), y: CGFloat(cell.imgCarBg.frame.origin.y), width: CGFloat((vwWidth*58)/100), height: CGFloat(cell.imgCarBg.frame.size.height)))
                            
                            conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(imgConditionBg.frame.origin.x+10), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                            
                            conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    }
                    else
                    {
                        
                            imgConditionBg = UIImageView(frame: CGRect(x: CGFloat(cell.imgCarBg.frame.origin.x), y: CGFloat(cell.imgCarBg.frame.origin.y), width: CGFloat((vwWidth*60)/100), height: CGFloat(cell.imgCarBg.frame.size.height)))
                            conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                            
                            dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(imgConditionBg.frame.size.width-10)+12, y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat((vwWidth*36)/100), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                            
                            conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionTxtFld.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionTxtFld.frame.size.height)))
                    }
                    
                    
                    imgConditionBg.backgroundColor = Colors.DHConditionBg
                    imgConditionBg.clipsToBounds = true
                    let maskPath : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath = UIBezierPath(roundedRect: imgConditionBg.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    else
                    {
                        maskPath = UIBezierPath(roundedRect: imgConditionBg.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.cgPath
                    imgConditionBg.layer.mask = maskLayer
                    
                    
                    //Set Left Side condition Text Lable
                    
                    conditionNameLbl.font = UIFont(name:cell.conditionNameLbl.font.fontName, size: 17)
                    conditionNameLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
                    conditionNameLbl.numberOfLines = 0
                    conditionNameLbl.textColor = UIColor.white
                    conditionNameLbl.text = obj.condition[indexDosage]
                    conditionNameLbl.tag = 200000 + indexDosage
                    //conditionNameLbl.backgroundColor = UIColor.clear
                    if obj.dosageNew[indexDosage]
                    {
                       
                        imgConditionBg.backgroundColor = UIColor.orange
                    }
                    else{
                        
                        imgConditionBg.backgroundColor = Colors.DHConditionBg
                    }
                    
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
                    if obj.dosageNew[indexDosage]
                    {
                        dosageTxtFld.backgroundColor = UIColor.orange
                    }
                    else{
                        dosageTxtFld.backgroundColor = Colors.DHConditionBg
                    }
                    
                    dosageTxtFld.delegate = self
                    dosageTxtFld.tag = indexDosage
                    dosageTxtFld.clipsToBounds = true
                    let maskPath1 : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath1 = UIBezierPath(roundedRect: dosageTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath1 = UIBezierPath(roundedRect: dosageTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer1 = CAShapeLayer()
                    maskLayer1.frame = self.view.bounds
                    maskLayer1.path = maskPath1.cgPath
                    dosageTxtFld.layer.mask = maskLayer1
                    // dosageTxtFld.layer.masksToBounds = true
                    dosageTxtFld.keyboardType = UIKeyboardType.numberPad
                    dosageTxtFld.isUserInteractionEnabled = false
                    
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
                    
                    conditionTxtFld.font = cell.conditionTxtFld.font
                    conditionTxtFld.textColor = cell.conditionTxtFld.textColor
                    conditionTxtFld.delegate = self
                    conditionTxtFld.tag = 100000 + indexDosage
                    conditionTxtFld.clipsToBounds = true
                    conditionTxtFld.backgroundColor = UIColor.clear
                    conditionTxtFld.isUserInteractionEnabled = false
                    if(obj.condition[indexDosage].length == 0)
                    {
                        conditionTxtFld.attributedPlaceholder = NSAttributedString(string: "Timing",
                                                                                   attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor] )
                    }
                    else
                    {
                        conditionTxtFld.attributedPlaceholder = NSAttributedString(string: "",
                                                                                   attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor] )
                    }
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        conditionTxtFld.textAlignment = .right
                        dosageTxtFld.textAlignment = .right
                    }
                    
                    //add view to Detail View
                    vwDetailNew.addSubview(dosageTxtFld)
                    vwDetailNew.addSubview(imgConditionBg)
                    vwDetailNew.addSubview(conditionNameLbl)
                    vwDetailNew.addSubview(conditionTxtFld)
                                        indexDosage += 1
                    vwDetailNew.clipsToBounds = true
                    cell.addMedicationView .addSubview(vwDetailNew)
                    vwDetailY = vwDetailY + vwDetailHeight + 10
                }
                
            }
            return cell
        }
        else
        {
            //---------------- New medication table cell configuration --------------
            if tableView == self.newtblView
            {
                let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell") as! CarePlanMedicationTableViewCell
                
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = true
                cell.tag = indexPath.row
                
                //Set Condition and Dosage Background Color
                
                cell.conditionTxtFld.backgroundColor = Colors.historyHeaderColor
                cell.dosageTxtFld.backgroundColor = Colors.historyHeaderColor
                
                // Assgin Condition and Dosage value
                if let obj: CarePlanObj = self.newMedarray[indexPath.section] as? CarePlanObj {
                    cell.conditionTxtFld.text = obj.condition[indexPath.row]
                    if(obj.dosage[indexPath.row] == 0)
                    {
                        cell.dosageTxtFld.text = ""
                    }
                    else
                    {
                        if obj.type == "Oral Agent"{
                            cell.dosageTxtFld.text = String(obj.dosage[indexPath.row]) + " mg"
                        }
                        else
                        {
                            cell.dosageTxtFld.text = String(obj.dosage[indexPath.row]) + " units"
                        }
                    }
                    
                   
                    // Put left side padding for Condition and dosage
                    setleftpadding(textfield: cell.dosageTxtFld)
                    setleftpadding(textfield: cell.conditionTxtFld)
                    
                    //Round corner left side for condition lable
                    cell.conditionTxtFld.clipsToBounds = true
                    let maskPath : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath = UIBezierPath(roundedRect: cell.conditionTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    else
                    {
                        maskPath = UIBezierPath(roundedRect: cell.conditionTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.conditionTxtFld.layer.mask = maskLayer
                    
                    //Round corner Right side for dosage lable
                    cell.dosageTxtFld.clipsToBounds = true
                    let maskPath1 : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath1 = UIBezierPath(roundedRect: cell.dosageTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath1 = UIBezierPath(roundedRect: cell.dosageTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    let maskLayer1 = CAShapeLayer()
                    maskLayer1.frame = self.view.bounds
                    maskLayer1.path = maskPath1.cgPath
                    cell.dosageTxtFld.layer.mask = maskLayer1
                    
                    
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        cell.conditionTxtFld.textAlignment = .right
                          cell.dosageTxtFld.textAlignment = .right
                    }
                }
                return cell
            }
                //---------------- End --------------
                //---------------- Old medication table cell configuration --------------
            else
            {
                let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell") as! CarePlanMedicationTableViewCell
                
                cell.selectionStyle = .none
                cell.isUserInteractionEnabled = true
                cell.tag = indexPath.row
                
                //Set Condition and Dosage Background Color
                cell.conditionTxtFld.backgroundColor = Colors.medicationConditionGrayColor
                cell.dosageTxtFld.backgroundColor = Colors.medicationConditionGrayColor
                // Assgin Condition and Dosage value
                if let obj: CarePlanObj = self.oldMedArray[indexPath.section] as? CarePlanObj {
                    cell.conditionTxtFld.text = obj.condition[indexPath.row]
                    if(obj.dosage[indexPath.row] == 0)
                    {
                        cell.dosageTxtFld.text = ""
                    }
                    else
                    {
                        if obj.type == "Oral Agent"{
                            cell.dosageTxtFld.text = String(obj.dosage[indexPath.row]) + " mg"
                        }
                        else
                        {
                            cell.dosageTxtFld.text = String(obj.dosage[indexPath.row]) + " units"
                        }
                    }
                    
                    // Put left side padding for Condition and dosage
                    setleftpadding(textfield: cell.dosageTxtFld)
                    setleftpadding(textfield: cell.conditionTxtFld)
                    
                    //Round corner left side for condition lable
                    cell.conditionTxtFld.clipsToBounds = true
                    let maskPath : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath = UIBezierPath(roundedRect: cell.conditionTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    else
                    {
                        maskPath = UIBezierPath(roundedRect: cell.conditionTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                        
                    }
                    
                    let maskLayer = CAShapeLayer()
                    maskLayer.frame = self.view.bounds
                    maskLayer.path = maskPath.cgPath
                    cell.conditionTxtFld.layer.mask = maskLayer
                    
                    //Round corner Right side for dosage lable
                    cell.dosageTxtFld.clipsToBounds = true
                    let maskPath1 : UIBezierPath
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        maskPath1 = UIBezierPath(roundedRect: cell.dosageTxtFld.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    else
                    {
                        maskPath1 = UIBezierPath(roundedRect: cell.dosageTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(kButtonRadius), height: CGFloat(kButtonRadius)))
                    }
                    
                    let maskLayer1 = CAShapeLayer()
                    maskLayer1.frame = self.view.bounds
                    maskLayer1.path = maskPath1.cgPath
                    cell.dosageTxtFld.layer.mask = maskLayer1
                    if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                        cell.conditionTxtFld.textAlignment = .right
                        cell.dosageTxtFld.textAlignment = .right
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(selectedUserType == userType.patient)
        {
            if let obj: CarePlanObj = tableView == self.newtblView ? self.newMedarray[indexPath.row] as? CarePlanObj : self.oldMedArray[indexPath.row] as? CarePlanObj {
                if(obj.dosage.count>3)
                {
                    let addHeight = (obj.dosage.count-3) * 45
                    return CGFloat(210 + addHeight)
                }
                else
                {
                    return 210
                }
            }
            else
            {
                return 210
            }
        }else
        {
            return 45
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
            let indexPath = self.newtblView.indexPathForRow(at: cell.center)!
            selectedIndex = indexPath as NSIndexPath
            self.newtblView.contentInset = UIEdgeInsetsMake(0, 0, 280 , 0)
            self.newtblView.scrollToRow(at: indexPath, at: .top, animated: true)
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
        let obj: CarePlanObj = (self.newMedarray[indexPath.row] as? CarePlanObj)!
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
        newMedarray.removeObject(at: indexPath.row)
        newMedarray.insert(obj, at: indexPath.row)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField .resignFirstResponder()
        let cell = self.parentCellFor(view: textField)
        
        if !cell.isViewEmpty {
            let indexPath = self.newtblView.indexPathForRow(at: cell.center)!
            self.newtblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
            self.newtblView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
        let cell = self.parentCellFor(view: textField)
        
        if !cell.isViewEmpty {
            let indexPath = self.newtblView.indexPathForRow(at: cell.center)!
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
extension MedicationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        let indx = picker.view.tag
        if let obj: CarePlanObj = self.newMedarray[indx] as? CarePlanObj {
            obj.carePlanImageURL =  image
            self.newMedarray.removeObject(at: indx)
            self.newMedarray.insert(obj, at: indx)
            self.newtblView .reloadData()
            self.newtblView .layoutIfNeeded()
            self.resetUI()
        }
        dismiss(animated: true, completion: {
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
