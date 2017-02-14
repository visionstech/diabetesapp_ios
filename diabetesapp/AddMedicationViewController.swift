//
//  AddMedicationViewController.swift
//  DiabetesApp
//
//  Created by User on 1/16/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import  SVProgressHUD
import Alamofire
import SDWebImage

class AddMedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
   // @IBOutlet weak var tblView: UITableView!
    
    
    @IBOutlet weak var tblView: UITableView!
    //@IBOutlet weak var tblView: UITableView!
    
    let picker = UIImagePickerController()
    var array = NSMutableArray()
    var addBtn = UIBarButtonItem()
    var topBackView:UIView = UIView()
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var selectedIndex : NSIndexPath = NSIndexPath()
    var formInterval: GTInterval!
    var addMedArray = NSMutableArray()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.allowsEditing = false
        picker.delegate = self
        
        self.array = NSMutableArray()
        let obj = CarePlanObj()
        obj.id = ""
        obj.name = ""
        obj.isNew = true
        obj.isEdit = true
        obj.dosage.append(0)
        obj.condition.append("")
        obj.carePlanImageURL = UIImage (named: "uploadImage")!
        obj.type = ""
        
        array.add(obj)
         NotificationCenter.default.addObserver(self, selector: #selector(self.readingMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.selectMedicationNotification), object: nil)
        // addBtn = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(AddBtn_Click))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kAddMedicationScreenName)
        //--------Google Analytics Finish-----
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavBarUI()
    }
    
    func readingMedicationNotification(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo else { return }
        let cell = self.tblView.cellForRow(at: selectedIndex as IndexPath) as! CarePlanMedicationTableViewCell
        
        //print("Add mediction reading notification")
        if let medicationname = userInfo["medicationname"] as? String {
            for data in dictMedicationList {
                print("Data")
                print(data)
                if let medication = data as? medicationObj {
                    if(medication.medicineName == medicationname)
                    {
                        if let obj: CarePlanObj = array[selectedIndex.row] as? CarePlanObj {
                            obj.type = medication.type
                            let imagePath = "http://54.212.229.198:3000/upload/" + medication.medicineImage
                            
                            let manager:SDWebImageManager = SDWebImageManager.shared()
                            obj.carePlanImageURL =   UIImage(named:"user.png")!
                            
                            manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                                  options: SDWebImageOptions.highPriority,
                                                  progress: nil,
                                                  completed: {[weak self] (image, error, cached, finished, url) in
                                                    if (error == nil && (image != nil) && finished) {
                                                        obj.carePlanImageURL = image!
                                                        cell.medImg.image = image!
                                                    }
                            })
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        self.navigationController? .setNavigationBarHidden(false, animated: true)
        self.tabBarController?.navigationItem.title = "\("CARE_PLAN".localized)"
        self.title = "\("CARE_PLAN".localized)"
        self.navigationItem.leftBarButtonItem = nil
        
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        
        self.navigationItem.hidesBackButton = true
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            if selectedUserType == userType.doctor {
                self.navigationItem.leftBarButtonItem = addBtn
            }
            else{
                self.navigationItem.leftBarButtonItem = nil
            }
        }
        else {
            if selectedUserType == userType.doctor {
                self.navigationItem.rightBarButtonItem = addBtn
            }
            else{
                self.navigationItem.rightBarButtonItem = nil
            }
        }
        createCustomTopView()
    }
    
    // MARK: - Custom Top View
    func createCustomTopView() {
        
        topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
        topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
        let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
        userImgView.image = UIImage(named: "user.png")
        topBackView.addSubview(userImgView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
        topBackView.addGestureRecognizer(tapGesture)
        topBackView.isUserInteractionEnabled = true
        
        self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
        self.navigationController?.navigationBar.addSubview(topBackView)
    }
    
    // MARK: - IBAction Methods
    
    @IBAction func btnClose_Clicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.closeAddNewMedication), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnAdd_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add medication field Clicked" , label:"Add care plan medication field")
        
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let cell = self.parentCellFor(view: btn)
        self.listSubviewsOf(cell)
        if let obj: CarePlanObj = array[index] as? CarePlanObj {
            if obj.dosage.contains(0) {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                
                SVProgressHUD.dismiss()
            }
            else if (obj.condition.contains(""))
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else
            {
                obj.dosage.append(0)
                obj.condition.append("")
                obj.isEdit = true
                array.removeObject(at: index)
                array.insert(obj, at: index)
                self.tblView .reloadData()
            }
        }
    }
    func BackBtn_Click(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func SaveNewMedicine_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Save medication Clicked" , label:"Save care plan medication")
        self.view.endEditing(true)
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        let index: Int = (sender as AnyObject).tag
        
        if let obj: CarePlanObj = array[index] as? CarePlanObj {
            if(obj.name .isEmpty)
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else if (obj.condition.count  < 1)
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else if(obj.dosage.count < 1)
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else if obj.dosage.contains(0) {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else if (obj.condition.contains(""))
            {
                self.present(UtilityClass.displayAlertMessage(message: "Please enter the missing fields", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please enter the missing fields")
                SVProgressHUD.dismiss()
            }
            else
            {
                var is_error = true
                for data in dictMedicationList {
                    if let medication = data as? medicationObj {
                        if(medication.medicineName == obj.name)
                        {
                            is_error = false
                            break
                        }
                    }
                }
                if(is_error)
                {
                    self.present(UtilityClass.displayAlertMessage(message: "Please Select Medication Name from the list".localized, title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Please Select Medication Name from the list")
                }
                else
                {
                    self.addcareplanData(careObj: obj)
                }
            }
        }
    }
    
    @IBAction func btndeleteCondtion_Click(_ sender: Any) {
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"delete medication Clicked" , label:"Delete care plan medication")
        self.view.endEditing(true)
        let index: Int = (sender as AnyObject).tag
        let btn = sender as! UIButton
        let cell = self.parentCellFor(view: btn)
        
        if !cell.isViewEmpty {
            let indexPath = self.tblView.indexPathForRow(at: cell.center)!
            if let obj: CarePlanObj = array[indexPath.row] as? CarePlanObj {
                if(obj.dosage.count<=1)
                {
                    self.present(UtilityClass.displayAlertMessage(message: "Medication must have atlease one condition and one dosage", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                    //Google Analytic
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Add Medication", action:"Add Medication" , label:"Medication must have atlease one condition and one dosage")
                    SVProgressHUD.dismiss()
                }
                else
                {
                    obj.dosage.remove(at: index)
                    obj.condition.remove(at: index)
                    array.removeObject(at: indexPath.row)
                    array.insert(obj, at: indexPath.row)
                    self.tblView .reloadData()
                }
            }
        }
    }
    @IBAction func selectMedicineImage_Click(_ sender: Any) {
//        self.view.endEditing(true)
//        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
//        let index: Int = (sender as AnyObject).tag
//        picker.view.tag = index
//        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func configureSimpleSearchTextField(medicationTextField: AutocompleteSearchTextField) {
        // Start visible - Default: false
        medicationTextField.startVisible = true
        // Set data source
        medicationTextField.filterStrings(dictMedicationName)
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell") as! CarePlanMedicationTableViewCell
        
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        cell.btnAdd.tag = indexPath.row
        cell.medImgBtn.tag = indexPath.row
        cell.saveBtn.tag = indexPath.row
        
        
        if let obj: CarePlanObj = self.array[indexPath.row] as? CarePlanObj {
            // Check Card is new or Old based on that set View
            
            cell.medImg.image = obj.carePlanImageURL
            
            cell.medicineNameTxtFld.text = obj.name
            cell.medicineNameTxtFld.tag = 1001
            cell.medicineNameTxtFld.backgroundColor = Colors.DHAddConditionBg
            cell.medicineNameTxtFld.layer.cornerRadius = 8.0
            
            cell.medImg.layer.borderColor = Colors.DHAddConditionBg.cgColor
            cell.medImg.layer.borderWidth = 1.0
            cell.medImg.layer.cornerRadius = 8.0
            
            
            //Set Default View and Value
            var vwDetailY = cell.vwDetail.frame.origin.y
            //let vwDetailX = cell.vwDetail.frame.origin.x
            let vwDetailHeight = cell.vwDetail.frame.size.height
            var imgConditionBg: UIImageView!
            var conditionNameLbl: UILabel!
            var dosageTxtFld: UITextField!
            var conditionTxtFld: UITextField!
            var btnDeleteCondition: UIButton!
            var indexDosage = 0
            let bounds = UIScreen.main.bounds.size.width
            
            cell.addMedicationView.subviews.forEach({ $0.removeFromSuperview() })
            vwDetailY = 0
            for dosage in obj.dosage{
                let vwDetailNew = UIView(frame: CGRect(x: CGFloat(0), y: CGFloat(vwDetailY), width: CGFloat(bounds-(cell.medImgView.frame.width+45)), height: CGFloat(vwDetailHeight)))
                
                vwDetailNew.subviews.forEach({ $0.removeFromSuperview() })
                vwDetailNew.backgroundColor = UIColor.white
                
                vwDetailNew.tag = 300000 + indexDosage
                let vwWidth = Double(vwDetailNew.frame.size.width)
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    if selectedUserType != userType.patient && obj.isEdit {
                        dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(cell.btnConditionDelete.frame.size.width), y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat(((vwWidth*40)/100) ), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                        
                        imgConditionBg = UIImageView(frame: CGRect(x: CGFloat((dosageTxtFld.frame.origin.x + dosageTxtFld.frame.size.width)-10), y: CGFloat(cell.imgCarBg.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.imgCarBg.frame.size.height)))
                        imgConditionBg.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(M_PI)) / 180.0)
                        conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(imgConditionBg.frame.origin.x+10), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*45)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                        
                        
                        conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*45)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    }
                    else
                    {
                        dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(0), y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat((vwWidth*40)/100), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                        imgConditionBg = UIImageView(frame: CGRect(x: CGFloat((dosageTxtFld.frame.origin.x + dosageTxtFld.frame.size.width)-10), y: CGFloat(cell.imgCarBg.frame.origin.y), width: CGFloat((vwWidth*60)/100), height: CGFloat(cell.imgCarBg.frame.size.height)))
                        imgConditionBg.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(M_PI)) / 180.0)
                        conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(imgConditionBg.frame.origin.x+10), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                        
                        conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    }
                }
                else
                {
                    imgConditionBg = UIImageView(frame: CGRect(x: CGFloat(cell.imgCarBg.frame.origin.x), y: CGFloat(cell.imgCarBg.frame.origin.y), width: CGFloat((vwWidth*56)/100), height: CGFloat(cell.imgCarBg.frame.size.height)))
                    conditionNameLbl = UILabel(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionNameLbl.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionNameLbl.frame.size.height)))
                    
                    dosageTxtFld = UITextField(frame: CGRect(x: CGFloat(imgConditionBg.frame.size.width-10)+12, y: CGFloat(cell.dosageTxtFld.frame.origin.y), width:  CGFloat(((vwWidth*40)/100) - Double(cell.btnConditionDelete.frame.size.width)), height: CGFloat(cell.dosageTxtFld.frame.size.height)))
                    
                    conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(cell.conditionNameLbl.frame.origin.x), y: CGFloat(cell.conditionTxtFld.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionTxtFld.frame.size.height)))
                    
                }
                
                imgConditionBg.backgroundColor = Colors.DHAddConditionBg
                imgConditionBg.clipsToBounds = true
                let maskPath = UIBezierPath(roundedRect: imgConditionBg.bounds, byRoundingCorners: ([.topLeft, .bottomLeft]), cornerRadii: CGSize(width: CGFloat(10.0), height: CGFloat(10.0)))
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.view.bounds
                maskLayer.path = maskPath.cgPath
                imgConditionBg.layer.mask = maskLayer
//                let vwWidth = Double(vwDetail.frame.size.width)
                
                
                //Set Left Side condition Text Lable

                conditionNameLbl.font = UIFont(name:cell.conditionNameLbl.font.fontName, size: 13)
                conditionNameLbl.lineBreakMode = NSLineBreakMode.byWordWrapping
                conditionNameLbl.numberOfLines = 0
                conditionNameLbl.textColor = UIColor.white
                conditionNameLbl.text = obj.condition[indexDosage]
                 conditionNameLbl.backgroundColor = UIColor.clear
                conditionNameLbl.tag = 200000 + indexDosage
                conditionNameLbl.clipsToBounds = true
                
                
                //Set Left Side dosage TextField with Background
                
                if(dosage == 0)
                {
                    dosageTxtFld.text = ""
                }
                else
                {
                    dosageTxtFld.text = String(dosage)
                }
                
                dosageTxtFld.font = cell.dosageTxtFld.font
                dosageTxtFld.textColor = cell.dosageTxtFld.textColor
                dosageTxtFld.backgroundColor = Colors.DHAddConditionBg
                dosageTxtFld.delegate = self
                dosageTxtFld.tag = indexDosage
                let maskPath1 = UIBezierPath(roundedRect: dosageTxtFld.bounds, byRoundingCorners: ([.topRight, .bottomRight]), cornerRadii: CGSize(width: CGFloat(10.0), height: CGFloat(10.0)))
                let maskLayer1 = CAShapeLayer()
                maskLayer1.frame = self.view.bounds
                maskLayer1.path = maskPath1.cgPath
                dosageTxtFld.layer.mask = maskLayer1
                
                dosageTxtFld.keyboardType = UIKeyboardType.numberPad
                dosageTxtFld.clipsToBounds = true
                
                if(dosageTxtFld.text?.length == 0)
                {
                    dosageTxtFld.attributedPlaceholder = NSAttributedString(string: "Dose",
                                                                            attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor])
                }
                else
                {
                    dosageTxtFld.attributedPlaceholder = NSAttributedString(string: "",
                                                                            attributes: [NSForegroundColorAttributeName: UIColor.white])
                }
                
                setleftpadding(textfield: dosageTxtFld)
                
//                conditionTxtFld = UITextField(frame: CGRect(x: CGFloat(cell.conditionTxtFld.frame.origin.x), y: CGFloat(cell.conditionTxtFld.frame.origin.y), width: CGFloat((vwWidth*50)/100), height: CGFloat(cell.conditionTxtFld.frame.size.height)))
                
                conditionTxtFld.font = cell.conditionTxtFld.font
                conditionTxtFld.textColor = cell.conditionTxtFld.textColor
     
                conditionTxtFld.delegate = self
                conditionTxtFld.tag = 100000 + indexDosage
                conditionTxtFld.clipsToBounds = true
                conditionTxtFld.minimumFontSize = 7
                 conditionTxtFld.backgroundColor = UIColor.clear
                if(obj.condition[indexDosage].length == 0)
                {
                    conditionTxtFld.attributedPlaceholder = NSAttributedString(string: "Timing",
                                                                               attributes: [NSForegroundColorAttributeName: Colors.placeHolderColor] )
                }
                else
                {
                    conditionTxtFld.attributedPlaceholder = NSAttributedString(string: "",
                                                                               attributes: [NSForegroundColorAttributeName: UIColor.white] )
                }
                
                
                //add view to Detail View
                vwDetailNew .addSubview(dosageTxtFld)
                vwDetailNew .addSubview(imgConditionBg)
                vwDetailNew .addSubview(conditionNameLbl)
                vwDetailNew .addSubview(conditionTxtFld)
                
                cell.medicineNameTxtFld.isHidden = false
                
                if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                    btnDeleteCondition = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(cell.btnConditionDelete.frame.origin.y), width: CGFloat(cell.btnConditionDelete.frame.size.width), height: CGFloat(cell.btnConditionDelete.frame.size.height)))
                }
                else
                {
                    btnDeleteCondition = UIButton(frame: CGRect(x: CGFloat(vwDetailNew.frame.size.width - (cell.btnConditionDelete.frame.size.width + 8)), y: CGFloat(cell.btnConditionDelete.frame.origin.y), width: CGFloat(cell.btnConditionDelete.frame.size.width), height: CGFloat(cell.btnConditionDelete.frame.size.height)))
                }
                btnDeleteCondition.tag = indexDosage
                btnDeleteCondition.titleLabel?.font = cell.btnConditionDelete.titleLabel?.font
                btnDeleteCondition.backgroundColor = UIColor.white
                btnDeleteCondition .setTitleColor(UIColor.red, for: UIControlState.normal)
                btnDeleteCondition .setTitleColor(UIColor.red, for: UIControlState.highlighted)
                btnDeleteCondition .setTitle("X", for: UIControlState.normal)
                btnDeleteCondition .setTitle("X", for: UIControlState.highlighted)
                btnDeleteCondition.addTarget(self, action: #selector(btndeleteCondtion_Click(_:)), for: .touchUpInside)
                vwDetailNew.addSubview(btnDeleteCondition)
                
                indexDosage += 1
                vwDetailNew.clipsToBounds = true
                cell.addMedicationView .addSubview(vwDetailNew)
                vwDetailY = vwDetailY + vwDetailHeight + 10
            }
            
            if obj.isEdit{
                let customView = UIView(frame: CGRect(x: 0, y:vwDetailY, width:CGFloat(bounds-(cell.medImgView.frame.width+45)), height:vwDetailHeight))
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: CGFloat(bounds-(cell.medImgView.frame.width+45)), height: vwDetailHeight))
                button.titleLabel?.font = cell.saveBtn.titleLabel?.font
                button.contentHorizontalAlignment = .left
                button.setImage(UIImage(named: "add_more_field"), for: .normal)
                button.setImage(UIImage(named: "add_more_field"), for: .highlighted)
                button.tag = indexPath.row
                button.addTarget(self, action: #selector(btnAdd_Click(_:)), for: .touchUpInside)
                customView.addSubview(button)
                cell.addMedicationView .addSubview(customView)
                cell.addMedicationView .bringSubview(toFront: customView)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let obj: CarePlanObj = self.array[indexPath.row] as? CarePlanObj {
            if(obj.dosage.count>=3)
            {
                let addHeight = (obj.dosage.count-2) * 45
                return CGFloat(200 + addHeight)
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
    }
    
    func setleftpadding(textfield: UITextField)
    {
       // textfield.layer.cornerRadius = 5
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
        cell?.medicineNameTxtFld .becomeFirstResponder()
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
                if(strTitle?.lowercased() == "edit" )
                {
                    btn.setTitle("",for: .normal)
                    btn.setTitle("",for: .highlighted)
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
            self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 100 , 0)
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
                obj.dosage .remove(at: textField.tag)
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
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.white])
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
                                                                         attributes: [NSForegroundColorAttributeName: UIColor.white] )
                }
                
                textField.text = ""
                textField.background = UIImage(named: "")
            }
        }
    }
    //MARK: - Helpers
    func dismissKeyboard(_ sender: UIGestureRecognizer) {
        self.view.endEditing(true)
        
        self.tblView.contentInset = UIEdgeInsetsMake(0, 0, 0 , 0)
        self.tblView.scrollToNearestSelectedRow(at: .top, animated: true)
    
        view.removeGestureRecognizer(sender)
    }
    // MARK: - web service calling
    func addcareplanData(careObj : CarePlanObj)
    {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userID": patientsID,
            "medname": careObj.name,
            "mednameAr" : "",
            "arrayCondition" : careObj.condition,
            "arrayDosage" : careObj.dosage,
            "medType": careObj.type
        ]
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        self.formInterval = GTInterval.intervalWithNowAsStartDate()
        
        //"\(baseUrl)\(ApiMethods.addcareplan)"
        Alamofire.request("\(baseUrl)\(ApiMethods.addcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.formInterval.end()
          
            
            switch response.result {
            case .success:
                //Google Analytic
                
                
                
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.addcareplan) Calling", action:"Success -Add Care Plan Data" , label:"Add Care Plan Data added Successfully", value : self.formInterval.intervalAsSeconds())
                print("Checking mededitbool")
                print(UserDefaults.standard.bool(forKey: "MedEditBool"))
                  if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    if  UserDefaults.standard.bool(forKey: "MedEditBool") {
                        let arr : NSArray = UserDefaults.standard.array(forKey: "currentAddMedicationArray")! as [Any] as NSArray
                            self.addMedArray = NSMutableArray(array: arr)
                
                        let pid: String = JSON.value(forKey:"patientID") as! String
                        self.addMedArray.add(pid)
                       
                        UserDefaults.standard.setValue(self.addMedArray, forKey: "currentAddMedicationArray")
                        UserDefaults.standard.synchronize()
                       // print("Checking here")
                        //print(UserDefaults.standard.array(forKey: "currentAddMedicationArray")!)
                    }
                    
                    
                  }
                  
                SVProgressHUD.showSuccess(withStatus: "Medication Added", maskType: SVProgressHUDMaskType.clear)
                
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.addNewMedication), object: nil)
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
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "\(ApiMethods.addcareplan) Calling", action:"Fail - Web API Calling" , label:String(describing: strError), value : self.formInterval.intervalAsSeconds())
                
                SVProgressHUD.dismiss()
                break
                
            }
        }
        
    }
    
    
}
extension AddMedicationViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
            
        }
        dismiss(animated: true, completion: {
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
