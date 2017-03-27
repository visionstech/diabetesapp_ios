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
    
    @IBOutlet weak var newTblView: UITableView!
     @IBOutlet weak var oldTblView: UITableView!
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    let loggedInUserID : String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
    @IBOutlet weak var pickerDoneButton: UIBarButtonItem!
    @IBOutlet weak var pickerCancelButton: UIBarButtonItem!
    @IBOutlet var pickerViewContainer: UIView!
    static let kTableheight = 41
    //@IBOutlet weak var addReadingLabel: UILabel!
    @IBOutlet weak var addReadingLabel: UILabel!
    var objCarePlanFrequencyObj = CarePlanFrequencyObj()
    var newArray = NSMutableArray()
    var oldArray = NSMutableArray()
    var currentLocale : String = ""
    var formInterval: GTInterval!
    var isEdit: Bool = false
    var editReadArray = NSMutableArray()
    //var readDeletedArray = NSMutableArray()
    var tempReadArray = NSMutableArray()
    
    @IBOutlet weak var csTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csOldTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnHeaderEdit: UIButton!
    @IBOutlet weak var costAddReadingButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var costheaderEditButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var constHeaderLastViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var csNewHeaderEditSpaceWidth: NSLayoutConstraint!
    @IBOutlet weak var csOldHeaderEditSpaceWidth: NSLayoutConstraint!
  
    @IBOutlet weak var csBottomScrollView: NSLayoutConstraint!
    
    
    @IBOutlet weak var imgAddReadingIcon: UIImageView!
    @IBOutlet weak var vmHeaderSpaceLast: UIView!
    @IBOutlet weak var vmNewHeader: UIView!
    @IBOutlet weak var vmoldHeader: UIView!
    @IBOutlet weak var vmPatientHeader: UIView!
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
    
    var newReadingAddedTemp = NSArray()
    var editedReadTempArray = NSArray()
    var readingDeletedTemp = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentLocale = NSLocale.current.languageCode!
        
        addReadingView.backgroundColor = Colors.PrimaryColor
        
        noreadingsLabel.isHidden = true
        addReadingLabel.text = "ADD_READING_LABEL".localized
        
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
        
        self.vmNewHeader.isHidden = true
        self.vmoldHeader.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                self.configReadingdata()
                
            }
            else
            {
                getReadingsData()
            }
           
        }
        else{
            getReadingsData()
        }
        
        let selectedUser: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        self.csOldHeaderEditSpaceWidth.constant = 8
        if(selectedUser == userType.patient)
        {
            self.csNewHeaderEditSpaceWidth.constant = 8
            self.addReadingView.setNeedsUpdateConstraints()
            
            self.addReadingView.isHidden = true
            self.csBottomScrollView.constant = 0
        }
        
        
       // if selectedUser == userType.educator{
         //   addReadingView.isHidden = true
          //  addNewReadingButton.isUserInteractionEnabled = false
       // }
        
        pickerViewInner.layer.cornerRadius = kButtonRadius
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
        UIApplication.shared.endIgnoringInteractionEvents()
        //Setup Round corners to Header View for new and old
        vmNewHeader.roundCorners(corners: [.topLeft, .topRight], radius: kButtonRadius)
        vmoldHeader.roundCorners(corners: [.topLeft, .topRight], radius: kButtonRadius)
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            
            self.addReadingLabel.frame = CGRect(x:self.addReadingLabel.frame.origin.x - 40 , y:self.addReadingLabel.frame.origin.y, width: self.addReadingLabel.frame.size.width , height:self.addReadingLabel.frame.size.height )
            self.imgAddReadingIcon.frame = CGRect(x:self.imgAddReadingIcon.frame.origin.x - 20 , y:self.imgAddReadingIcon.frame.origin.y, width: self.imgAddReadingIcon.frame.size.width , height:self.imgAddReadingIcon.frame.size.height )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
    }
    
    //MARK: - Custom Methods
    func resetUI() {
        
        if self.newArray.count > 0 {
            newTblView.isHidden = false
            self.lblNewChangeByDr.isHidden = false
            noreadingsLabel.isHidden = false
            self.vmNewHeader.isHidden = false
        }
        else {
            newTblView.isHidden = true
            self.lblNewChangeByDr.isHidden = true
            noreadingsLabel.isHidden = true
            self.vmNewHeader.isHidden = true
        }
        if self.oldArray.count > 0 {
            oldTblView.isHidden = false
            self.lblOldChangeByDr.isHidden = false
            self.vmoldHeader.isHidden = false
        }
        else {
            oldTblView.isHidden = true
            self.lblOldChangeByDr.isHidden = true
            self.vmoldHeader.isHidden = true
        }
        
        if(self.selectedUserType != userType.patient)
        {
            oldTblView.isHidden = false
        }
        else
        {
            oldTblView.isHidden = true
            self.lblOldChangeByDr.isHidden = true
            self.vmoldHeader.isHidden = true
        }
        
    }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNewReadingNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.addNewReading), object: nil)
    }
    func configReadingdata()
    {
        self.newArray = NSMutableArray()
        self.oldArray = NSMutableArray()
        var totalHeightForTableNew = 0
        var totalHeightForTableOld = 0
        
        
        let repoReadArray : NSArray = UserDefaults.standard.array(forKey: "repoReadiArray")! as [Any] as NSArray
        let repoOldReadArray : NSArray = UserDefaults.standard.array(forKey: "repoOldReadiArray")! as [Any] as NSArray
        
        let repoReadiArray = NSMutableArray(array: repoReadArray)
        let repoOldReadiArray = NSMutableArray(array: repoOldReadArray)
        
        self.oldArray.removeAllObjects()
        for data in repoOldReadiArray {
            let dict: NSDictionary = data as! NSDictionary
            let obj1 = CarePlanFrequencyObj()
            if (dict.value(forKey: "_id") == nil)
            {
                obj1.id = dict.value(forKey: "id") as! String
            }
            else
            {
                obj1.id = dict.value(forKey: "_id") as! String
            }
            let goalStr: String = dict.value(forKey: "goal") as! String
            obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
            obj1.time = dict.value(forKey: "time") as! String
            obj1.frequency = dict.value(forKey: "frequency") as! String
            
            obj1.isEdit = false
            self.oldArray.add(obj1)
        }
        
        for data in repoReadiArray {
            let dict: NSDictionary = data as! NSDictionary
            let obj1 = CarePlanFrequencyObj()
            if (dict.value(forKey: "_id") == nil)
            {
                obj1.id = dict.value(forKey: "id") as! String
            }
            else
            {
                obj1.id = dict.value(forKey: "_id") as! String
            }
            let goalStr: String = dict.value(forKey: "goal") as! String
            obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
            obj1.time = dict.value(forKey: "time") as! String
            obj1.frequency = dict.value(forKey: "frequency") as! String
            
            obj1.isEdit = false
            self.newArray.add(obj1)
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
        // }
        // if newReadingAddedTemp.count > 0
        //{
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
        //}
        
        // if readingDeletedTemp.count > 0{
        for data2 in self.readingDeletedTemp{
            let dict: NSDictionary = data2 as! NSDictionary
            let obj = CarePlanFrequencyObj()
            obj.id = dict.value(forKey: "id") as! String
            
            for i in 0..<self.newArray.count{
                let obj1 : CarePlanFrequencyObj = self.newArray[i] as! CarePlanFrequencyObj
                
                //let obj1 = CarePlanFrequencyObj()
                
                if obj1.id == obj.id{
                    
                    self.newArray.removeObject(at: i)
                    break
                }
                
            }
        }
        
        totalHeightForTableNew = totalHeightForTableNew + ((self.newArray.count * CarePlanReadingViewController.kTableheight))
        totalHeightForTableOld = totalHeightForTableOld + ((self.oldArray.count * CarePlanReadingViewController.kTableheight))
        self.csvmReadingMainHeight.constant = CGFloat(totalHeightForTableNew + 80) +  CGFloat(totalHeightForTableOld + 80)
        self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
        self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
        
        self.csvmNewReadingHeight.constant = CGFloat(totalHeightForTableNew + 80)
        self.csvmOldReadingHeight.constant = CGFloat(totalHeightForTableOld + 80)
        
        self.vmReadingMain.updateConstraintsIfNeeded()
        self.vmOldReading.updateConstraintsIfNeeded()
        self.vmNewReading.updateConstraintsIfNeeded()
        
        self.readingScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 80) +  CGFloat(totalHeightForTableOld + 80))
        
        
        //  ---- End ----
        self.newTblView.reloadData()
        self.oldTblView.reloadData()
        
        self.resetUI()
        self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)
    }
    //MARK: - Notifications Methods
    func readingNotification(notification: NSNotification) {
        
    }
    
    func addNewReadingNotification(notification: NSNotification) {
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if  UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
                self.configReadingdata()
            }
            else
            {
                self.getReadingsData()
            }
        }
        else
        {
            self.getReadingsData()
        }
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
        let viewController : AddReadingViewController = self.storyboard!.instantiateViewController(withIdentifier: "addreading") as! AddReadingViewController
        viewController.isEditReading = false
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: 210)
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        self.present(formSheetController, animated: true, completion: nil)
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
    func roundCornersFotterView() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: newTblView.bounds.width, height: 10))
        
        let bounds = view.bounds
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii:CGSize(width: 10.0, height: 10.0)  )
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        newTblView.layer.mask = maskLayer
        let frameLayer = CAShapeLayer()
        frameLayer.frame = bounds
        frameLayer.path = maskPath.cgPath
        frameLayer.lineWidth = 2.0
        frameLayer.strokeColor = Colors.PrimaryColor.cgColor
        frameLayer.fillColor = nil
        view.layer.addSublayer(frameLayer)
        
        return view
    }
    // MARK: - UIButton Event Methods
    
    @IBAction func EditReading_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        let btn = sender as! UIButton
        
       // let cell = self.parentCellFor(view: btn) as! CarePlanReadingTableViewCell
        
        self.objCarePlanFrequencyObj = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        self.objCarePlanFrequencyObj.isEdit = true
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Reading", action:"Add reading Clicked" , label:"Add care plan reading")
        let viewController : AddReadingViewController = self.storyboard!.instantiateViewController(withIdentifier: "addreading") as! AddReadingViewController
        viewController.isEditReading = true
        viewController.objCarePlanFrequencyObj = self.objCarePlanFrequencyObj
        let formSheetController = MZFormSheetPresentationViewController(contentViewController: viewController)
        formSheetController.presentationController?.contentViewSize = CGSize(width: self.view.bounds.width - 10, height: 210)
        formSheetController.presentationController?.shouldCenterVertically = true
        formSheetController.presentationController?.shouldDismissOnBackgroundViewTap = true
        self.present(formSheetController, animated: true, completion: nil)
        
//        if(!self.objCarePlanFrequencyObj.isEdit)
//        {
//            self.objCarePlanFrequencyObj.isEdit = true
//            cell.btnEdit.setImage(UIImage(named: "save_icon"), for: .normal)
//            cell.btnEdit.setImage(UIImage(named: "save_icon"), for: .highlighted)
//            self.newTblView .reloadData()
//             self.oldTblView.reloadData()
//        }
//        else
//        {
//            
//            let inverseSet = NSCharacterSet(charactersIn:"0123456789-< ").inverted
//            
//            let components = self.objCarePlanFrequencyObj.goal.components(separatedBy: inverseSet)
//            
//            // Rejoin these components
//            let filtered = components.joined(separator: "") // use join("", components) if you are using Swift 1.2
//            if(self.objCarePlanFrequencyObj.goal.length < 1 )
//            {
//                self.present(UtilityClass.displayAlertMessage(message: "Please enter valid range value for Goal".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
//                //Google Analytic
//                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please enter valid range value for Goal")
//                SVProgressHUD.dismiss()
//            }
//            else if( self.objCarePlanFrequencyObj.goal != filtered )
//            {
//                self.present(UtilityClass.displayAlertMessage(message: "Please enter valid range value for Goal".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
//                //Google Analytic
//                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Care Plan", action:"Edit Medication" , label:"Please enter valid range value for Goal")
//                SVProgressHUD.dismiss()
//            }
//                
//            else
//            {
//                if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
//                    self.objCarePlanFrequencyObj.isEdit = false
//                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
//                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
//                    
//                    self.newTblView.reloadData()
//                    self.newTblView .layoutIfNeeded()
//                    
//                    self.oldTblView.reloadData()
//                    self.oldTblView .layoutIfNeeded()
//                    
//                    let arr : NSArray = UserDefaults.standard.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
//                    editReadArray = NSMutableArray(array: arr)
//                    
//                    let mainDict: NSMutableDictionary = NSMutableDictionary()
//                    let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
//                    mainDict.setValue(self.objCarePlanFrequencyObj.id, forKey: "id")
//                    mainDict.setValue(self.objCarePlanFrequencyObj.frequency, forKey: "frequency")
//                    mainDict.setValue(self.objCarePlanFrequencyObj.time, forKey: "time")
//                    mainDict.setValue(self.objCarePlanFrequencyObj.goal, forKey: "goal")
//                    mainDict.setValue(loggedInUserID, forKey: "updatedBy")
//                    mainDict.setValue(loggedInUserName, forKey: "updatedByName")
//                    
//                    if editReadArray.count > 0 {
//                        for i in 0..<self.editReadArray.count {
//                            let id: String = (editReadArray.object(at:i) as AnyObject).value(forKey: "id") as! String
//                            print(id)
//                            if id == self.objCarePlanFrequencyObj.id {
//                                editReadArray.replaceObject(at:i, with: mainDict)
//                                UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
//                                UserDefaults.standard.synchronize()
//                                break
//                            }
//                        }
//                        editReadArray.add(mainDict)
//                    }
//                    else {
//                        editReadArray.add(mainDict)
//                    }
//                    
//                    
//                    UserDefaults.standard.setValue(editReadArray, forKey: "currentEditReadingCareArray")
//                    UserDefaults.standard.synchronize()
//                    
//                }
//                else
//                {
//                    //if self.pickerTimingView.superview == nil && self.pickerFreqView.superview == nil
//                    //  {
//                    self.updatecareplanData()
//                    self.objCarePlanFrequencyObj.isEdit = false
//                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .normal)
//                    cell.btnEdit.setImage(UIImage(named: "edit_icon"), for: .highlighted)
//                    self.newTblView .reloadData()
//                    self.oldTblView.reloadData()
//                    
//                }
//            }
//            
//            
//        }
    }
    
    
    @IBAction func cancelFreqBtn_Clicked(_ sender: Any) {
        hideOverlay(overlayView: pickerViewContainer)
    }
    
    @IBAction func okFreqBtn_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        
        let indexPath = IndexPath(row: btn.tag, section: 0)
        self.objCarePlanFrequencyObj = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        
        let cell = self.newTblView.cellForRow(at: indexPath) as! CarePlanReadingTableViewCell
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
        self.objCarePlanFrequencyObj = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        
        let cell = self.newTblView.cellForRow(at: indexPath) as! CarePlanReadingTableViewCell
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
        let carePlanFrequencyObj = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        
        let index = frequnecyArray.index(of: carePlanFrequencyObj.frequency.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        if(index <= frequnecyArray.count)
        {
            pickerFreqView.selectRow(index, inComponent: 0, animated: true)
        }
        else
        {
            pickerFreqView.selectRow(0, inComponent: 0, animated: true)
        }
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
        
        let carePlanFrequencyObj = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        
        let index = conditionsArrayEng.index(of: carePlanFrequencyObj.time.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        if(index <= conditionsArrayEng.count)
        {
            pickerTimingView.selectRow(index, inComponent: 0, animated: true)
        }
        else
        {
            pickerTimingView.selectRow(0, inComponent: 0, animated: true)
        }
        
        
        showOverlay(overlayView: pickerViewContainer)
        
    }
    @IBAction func btnDelete_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        let btn = sender as! UIButton
        let objcarePlanFreq = (newArray[btn.tag] as? CarePlanFrequencyObj)!
        
        if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
            
            let arr : NSArray = UserDefaults.standard.array(forKey: "currentDeleteReadingArray")! as [Any] as NSArray
            let readDeletedArray = NSMutableArray(array: arr)
            
            let arrNew : NSArray = UserDefaults.standard.array(forKey: "currentAddReadingArray")! as [Any] as NSArray
            let newReadArray = NSMutableArray(array: arrNew)
            
            if let readIndex = objcarePlanFreq.tempIndex as? Int{
                if readIndex > 0 && newReadArray.count > (readIndex - 1){
                    newReadArray.removeObject(at: (readIndex-1));
                }
            }
            
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
            mainDict.setValue(self.objCarePlanFrequencyObj.id, forKey: "id")
            mainDict.setValue(self.objCarePlanFrequencyObj.frequency, forKey: "frequency")
            mainDict.setValue(self.objCarePlanFrequencyObj.time, forKey: "time")
            mainDict.setValue(self.objCarePlanFrequencyObj.goal, forKey: "goal")
            mainDict.setValue(loggedInUserID, forKey: "updatedBy")
            mainDict.setValue(loggedInUserName, forKey: "updatedByName")
            
            
            readDeletedArray.add(mainDict)
            
            UserDefaults.standard.setValue(newReadArray, forKey: "currentAddReadingArray")
            UserDefaults.standard.setValue(readDeletedArray, forKey: "currentDeleteReadingArray")
            UserDefaults.standard.synchronize()
            
            
            
            
            self.newArray.removeObject(at: btn.tag)
            self.newTblView.deleteRows(at: [IndexPath(row: btn.tag, section: 0)], with: .automatic)
            for i in btn.tag..<self.newArray.count {
                self.newTblView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
            }
            
            
            self.dismiss(animated: true)
            //getReadingsData()
            //  })
            
            
        }
        else{
            self.deleteReading(readingID: objcarePlanFreq.id, objectIndex: btn.tag)
        }
    }
    
    //MARK: - Private Overlay Function
    //    private func setRoundLable()
    //    {
    //                let maskPath : UIBezierPath
    //                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
    //                    maskPath = UIBezierPath(roundedRect: cell.conditionLbl.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //
    //                }
    //                else
    //                {
    //                    maskPath = UIBezierPath(roundedRect: cell.conditionLbl.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //
    //                }
    //                let maskLayer = CAShapeLayer()
    //                maskLayer.frame = self.view.bounds
    //                maskLayer.path = maskPath.cgPath
    //                cell.conditionLbl.layer.mask = maskLayer
    //
    //
    //                let maskPath1 : UIBezierPath
    //                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
    //                    maskPath1 = UIBezierPath(roundedRect: cell.goalLbl.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //                }
    //                else
    //                {
    //                    maskPath1 = UIBezierPath(roundedRect: cell.goalLbl.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //                }
    //                let maskLayer1 = CAShapeLayer()
    //                maskLayer1.frame = self.view.bounds
    //                maskLayer1.path = maskPath1.cgPath
    //                cell.goalLbl.layer.mask = maskLayer1
    //
    //                let maskPath2 : UIBezierPath
    //                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
    //                    maskPath2 = UIBezierPath(roundedRect: cell.txtGoal.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //                }
    //                else
    //                {
    //                    maskPath2 = UIBezierPath(roundedRect: cell.txtGoal.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(5.0), height: CGFloat(5.0)))
    //                }
    //
    //                let maskLayer2 = CAShapeLayer()
    //                maskLayer2.frame = self.view.bounds
    //                maskLayer2.path = maskPath2.cgPath
    //
    //                cell.txtGoal.layer.mask = maskLayer2
    //
    //    }
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
            let objCarePlanObj = (newArray[textField.tag] as? CarePlanFrequencyObj)!
            objCarePlanObj.goal = textField.text!
        }
    }
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        view.removeGestureRecognizer(sender)
    }
    // MARK: - Api Methods
    func deleteReading(readingID : String , objectIndex : Int) {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let loggedInUserName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
        let parameters: Parameters = [
            "userid": patientsID,
            "readingid" : readingID,
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
                        //Google Analytic
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.deletecareplan) Calling", action:"Success - Delete care Plan Reading" , label:"Care Plan Data Deleted Successfully", value : self.formInterval.intervalAsSeconds())
                        
                        self.newArray.removeObject(at: objectIndex)
                        self.newTblView.deleteRows(at: [IndexPath(row: objectIndex, section: 0)], with: .automatic)
                        for i in objectIndex..<self.newArray.count {
                            self.newTblView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                        }
                        
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
        SVProgressHUD.show(withStatus: "Loading readings plan".localized, maskType: SVProgressHUDMaskType.clear)
        
        //"\(baseUrl)\(ApiMethods.updatecareplanReadings)"
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
            
            switch response.result {
            case .success:
                SVProgressHUD.showSuccess(withStatus: "Updated Successfully".localized, maskType: SVProgressHUDMaskType.clear)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.updatecareplanReadings) Calling", action:"Success -Update care Plan" , label:"Care Plan Data Updated Successfully", value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                self.newTblView.reloadData()
                self.oldTblView.reloadData()
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
                "userid": patientsID,
                "loggedInUser": loggedInUserID
            ]
            self.formInterval = GTInterval.intervalWithNowAsStartDate()
            Alamofire.request("\(baseUrl)\(ApiMethods.getcareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                self.formInterval.end()
                switch response.result {
                case .success:
                    print("Validation Successful")
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.getcareplanReadings) Calling", action:"Success - Get care plan Readings Data" , label:"Get care plan Readings Data Listed Successfully", value : self.formInterval.intervalAsSeconds())
                    self.newArray = NSMutableArray()
                    self.oldArray = NSMutableArray()
                    var totalHeightForTableNew = 0
                    var totalHeightForTableOld = 0
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                          self.oldArray.removeAllObjects()
                        if  let JSONOldRed :  NSArray = JSON.value(forKey: "oldReadingList") as? NSArray{
                          
                            for data in JSONOldRed {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj1 = CarePlanFrequencyObj()
                                obj1.id = dict.value(forKey: "id") as! String
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                obj1.time = dict.value(forKey: "time") as! String
                                obj1.frequency = dict.value(forKey: "frequency") as! String
                              //  obj1.wasUpdated = dict.value(forKey: "isNew") as! Bool
                                obj1.updatedBy = dict.value(forKey: "updatedByName") as! String
                                obj1.updatedDate = dict.value(forKey: "lastUpdatedDate") as! String
                                
                               
                                
                                if self.selectedUserType != userType.patient
                                {
                                    let updatedByString : String = JSON.value(forKey: "oldReadsUpdatedBy") as! String
                                    let updatedDate : String = JSON.value(forKey: "oldReadsLastUpdated") as! String
                                    self.lblOldChangeByDr.text = "Updated by \(updatedByString) \(updatedDate)"
                                }
                                else{
                                    self.lblOldChangeByDr.text = ""
                                }
                                
                               // self.lblOldChangeByDr.text = "Created by Dr \(obj1.updatedBy) \(obj1.updatedDate)"
                                obj1.isEdit = false
                                self.oldArray.add(obj1)
                            }
                        }
                        
                        if  let JSONNewRead :  NSArray = JSON.value(forKey: "readingList") as? NSArray{
                            self.newArray.removeAllObjects()
                            for data in JSONNewRead {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj1 = CarePlanFrequencyObj()
                                if dict.value(forKey: "id") != nil{
                                    obj1.id.append(dict.value(forKey:"id") as! String)
                                }
                                else if dict.value(forKey: "_id") != nil{
                                    obj1.id.append(dict.value(forKey:"_id") as! String)
                                }
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj1.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                obj1.time = dict.value(forKey: "time") as! String
                                obj1.frequency = dict.value(forKey: "frequency") as! String
                                obj1.wasUpdated = dict.value(forKey: "isNew") as! Bool
                                obj1.updatedBy = dict.value(forKey: "updatedByName") as! String
                                obj1.updatedDate = dict.value(forKey: "lastUpdatedDate") as! String
                                
                                if self.selectedUserType != userType.patient
                                {
                                    let updatedByString : String = JSON.value(forKey: "currentReadsUpdatedBy") as! String
                                    let updatedDate : String = JSON.value(forKey: "currentReadsLastUpdated") as! String
                                
                                    self.lblNewChangeByDr.text = "Updated by \(updatedByString) \(updatedDate)"
                                }
                                else{
                                    self.lblNewChangeByDr.text = ""
                                }
                               // self.lblOldChangeByDr.text = "Created by Dr \(obj1.updatedBy) \(obj1.updatedDate)"
                                obj1.isEdit = false
                                self.newArray.add(obj1)
                               //  self.oldArray.add(obj1)
                            }
                        }
                    }
                   
                    if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
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
                    // }
                    // if newReadingAddedTemp.count > 0
                    //{
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
                    //}
                    
                    // if readingDeletedTemp.count > 0{
                    for data2 in self.readingDeletedTemp{
                        let dict: NSDictionary = data2 as! NSDictionary
                        let obj = CarePlanFrequencyObj()
                        obj.id = dict.value(forKey: "id") as! String
                        
                        for i in 0..<self.newArray.count{
                            let obj1 : CarePlanFrequencyObj = self.newArray[i] as! CarePlanFrequencyObj
                            
                            //let obj1 = CarePlanFrequencyObj()
                            
                            if obj1.id == obj.id{
                                
                                self.newArray.removeObject(at: i)
                                break
                            }
                            
                        }
                    }
                }
                        totalHeightForTableNew = totalHeightForTableNew + ((self.newArray.count * CarePlanReadingViewController.kTableheight))
                        totalHeightForTableOld = totalHeightForTableOld + ((self.oldArray.count * CarePlanReadingViewController.kTableheight))
                        self.csvmReadingMainHeight.constant = CGFloat(totalHeightForTableNew + 80) +  CGFloat(totalHeightForTableOld + 80)
                        self.csTableViewHeight.constant = CGFloat(totalHeightForTableNew)
                        self.csOldTableViewHeight.constant = CGFloat(totalHeightForTableOld)
                        
                        self.csvmNewReadingHeight.constant = CGFloat(totalHeightForTableNew + 80)
                        self.csvmOldReadingHeight.constant = CGFloat(totalHeightForTableOld + 80)
                        
                        self.vmReadingMain.updateConstraintsIfNeeded()
                        self.vmOldReading.updateConstraintsIfNeeded()
                        self.vmNewReading.updateConstraintsIfNeeded()
                        
                        self.readingScroll.contentSize = CGSize(width: self.view.frame.size.width, height: CGFloat(totalHeightForTableNew + 80) +  CGFloat(totalHeightForTableOld + 80))
                        
            
                     //  ---- End ----
                    self.newTblView.reloadData()
                    self.oldTblView.reloadData()
                   
                      self.resetUI()
                     self.perform(#selector(self.reloadTable), with: nil, afterDelay: 0.3)
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
                    self.newTblView.reloadData()
                     self.oldTblView.reloadData()
                    // self.frequencyTblView.reloadData()
                     self.resetUI()
                    
                    break
                    
                }
            }
        }
    }
    func reloadTable()
    {
        self.newTblView.reloadData()
        self.oldTblView.reloadData()
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
                    cell.btnEdit.isHidden = false
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
}
