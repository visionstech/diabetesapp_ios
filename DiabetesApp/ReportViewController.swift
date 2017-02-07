//
//  ReportViewController.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SDWebImage

class ReportViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var patientImage: UIImageView!
    @IBOutlet weak var summaryTextLabel: UILabel!
    
    @IBOutlet weak var summaryTbl: UITableView!
    @IBOutlet weak var glucoseReadingView: UIView!
    
    @IBOutlet weak var glucoseReadingLabel: UILabel!
    @IBOutlet weak var listBtn: UIButton!
    
    @IBOutlet weak var chartBtn: UIButton!
    
    @IBOutlet weak var readingTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var listViewContainer: UIView!
    
    @IBOutlet weak var commentsByEducatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var chartViewContainer: UIView!
    @IBOutlet weak var medicationView: UIView!
    @IBOutlet weak var medicationTbl: UITableView!
    @IBOutlet weak var currentMedicationsLabel: UILabel!
    @IBOutlet weak var currentMedEdit: UIButton!
    
    @IBOutlet weak var commentsByEducator: UIView!
    @IBOutlet weak var medicationViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var glucoseReadingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var readingScheduleView: UIView!
    
    @IBOutlet weak var currentReadingTitleLabel: UILabel!
    @IBOutlet weak var currentReadEdit: UIButton!
    
    @IBOutlet weak var currentReadingView: UIView!
    
    @IBOutlet weak var newReadingViewContainer: UIView!
    
    @IBOutlet weak var newReadingEditView: UIView!
    @IBOutlet weak var currentReadingContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var readNewEdit: UIButton!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var newReadingContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var newRedEditConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var educatorActionView: UIView!
    @IBOutlet weak var readingScheduleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var actionLabel: UILabel!
    
    @IBOutlet weak var actionSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var commentEducatorLabel: UILabel!
    @IBOutlet weak var doctorActionView: UIView!
    @IBOutlet weak var addCommentsLabel: UILabel!
    
    @IBOutlet weak var educatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var educatorActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorCommentTextView: UITextView!
    @IBOutlet weak var declineLabel: UIButton!
    @IBOutlet weak var approveLabel: UIButton!
    //@IBOutlet weak var doctorAcionView: UIView!
    @IBOutlet weak var reportEmergencyLabel: UIButton!
    @IBOutlet weak var sendRequestLabel: UIButton!
    @IBOutlet weak var educatorCommentTxtViw: UITextView!
    
    var sections = Int()
    var editButton: UIButton!
    
  
    var topBackView:UIView = UIView()
    var summaryArray = NSArray()
    var summaryTxtArray = NSMutableArray()
    var medicationArray = NSMutableArray()
    var newMedicationArray = NSMutableArray()
    var currentMedEditBool = Bool()
    
    var editCurrentMedDict = NSDictionary()
    //var editCurrentMedArray = NSMutableArray()
    //var editCurrentMedDict = NSDictionary()
    var editMedArray = NSMutableArray()
    var editCurrentMedArray = NSArray()
    var editCurrentReadArray = NSArray()
    var oldCurrentMedArray = NSMutableArray()
   // let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    //var taskID = String()
    var reportUser = String()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  print(taskID)
        
        UserDefaults.standard.setValue(NSArray(), forKey: "currentEditMedicationArray")
        UserDefaults.standard.synchronize()
        
        newReadingViewContainer.isHidden = true
        educatorCommentTxtViw.text = "Please add comments to justify your decision"
        educatorCommentTxtViw.textColor = UIColor.lightGray
        
        approveLabel.setTitle("Approve".localized, for: .normal)
        declineLabel.setTitle("Decline".localized, for: .normal)
        sendRequestLabel.setTitle("Send Request to Doctor".localized, for: .normal)
        reportEmergencyLabel.setTitle("Report Emergency".localized, for: .normal)

         if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if selectedUserType == userType.doctor {
                sections = 1
                summaryArray = ["Patient","Educator","HC#","Diabetes"];
                doctorReportAPI()
                educatorActionViewHeight.constant = 0
                let rect = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect
                educatorActionView.isHidden = true
                //newReadingViewContainer.isHidden = false
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = false
                self.currentReadEdit.isHidden = false
                self.readNewEdit.isHidden = false
                lbl.isHidden = false
                
            }
            else {
                sections = 1
                doctorSingleReportAPI()
                summaryArray = ["Patient","Doctor","HC#","Diabetes"];
                doctorActionViewHeight.constant = 0
                let rect = CGRect(x: 0, y: 0, width: 100, height: doctorActionViewHeight.constant)
                doctorActionView.frame = rect
                doctorActionView.isHidden = true
                let rect1 = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect1
                educatorActionView.isHidden = true
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = false
                self.readNewEdit.isHidden = true
                lbl.isHidden = true
                
            }
            
        }
        else {
            
            if selectedUserType == userType.doctor {
                sections = 1
                doctorSingleReportAPI()
                doctorCommentTextView.isHidden = true
                
                approveLabel.setTitle("Save Changes".localized, for: .normal)
                declineLabel.setTitle("Cancel".localized, for: .normal)
                commentsByEducatorHeightConstraint.constant = 0
                commentEducatorLabel.isHidden = true
                summaryArray = ["Patient","Doctor","HC#","Diabetes"];
                educatorActionViewHeight.constant = 0
                let rect = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect
                educatorActionView.isHidden = true
               // newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = false
                //self.readNewEdit.isHidden = true
                lbl.isHidden = true
            }
            else {
                sections = 1
                getEducatorReportAPI()
                summaryArray = ["Patient","Doctor","HC#","Diabetes"];
                doctorActionViewHeight.constant = 0
                let rect = CGRect(x: 0, y: 0, width: 100, height: doctorActionViewHeight.constant)
                doctorActionView.frame = rect
                doctorActionView.isHidden = true
               
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = false
                self.readNewEdit.isHidden = true
                lbl.isHidden = true
                
                
            }
            
            
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        summaryTbl.tableFooterView = UIView()
       
        
        
        
        // scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2900)
        // Do any additional setup after loading the view.
      //  segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:Colors.outgoingMsgColor], for: .normal)
        //segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        
        
       /* summaryTbl.backgroundColor = UIColor.clear
        summaryTextLabel.backgroundColor = UIColor.clear
        glucoseReadingView.backgroundColor = UIColor.clear
        glucoseReadingLabel.backgroundColor = UIColor.clear
        summaryTbl.backgroundColor = UIColor.clear
        */
        declineLabel.layer.cornerRadius = kButtonRadius
        declineLabel.layer.masksToBounds = true
        
        approveLabel.layer.cornerRadius = kButtonRadius
        approveLabel.layer.masksToBounds = true
        
        reportEmergencyLabel.layer.cornerRadius = kButtonRadius
        reportEmergencyLabel.layer.masksToBounds = true
        
        sendRequestLabel.layer.cornerRadius = kButtonRadius
        sendRequestLabel.layer.masksToBounds = true
        //currentMedicationsLabel.backgroundColor = Colors.DHTabBarItemUnselected
        //currentReadingTitleLabel.backgroundColor = Colors.DHTabBarItemUnselected
        
        medicationTbl.backgroundColor = UIColor.clear
        
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:Colors.PrimaryColor], for: .normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        segmentControl.setTitle("TODAY".localized, forSegmentAt: 0)
        segmentControl.setTitle("SEVEN_DAYS".localized, forSegmentAt: 1)
        segmentControl.setTitle("FOURTEEN_DAYS".localized, forSegmentAt: 2)
        segmentControl.setTitle("THIRTY_DAYS".localized, forSegmentAt: 3)
        segmentControl.layer.cornerRadius = kButtonRadius
        segmentControl.layer.borderColor = Colors.PrimaryColor.cgColor
        segmentControl.layer.borderWidth = 1
        segmentControl.layer.masksToBounds = true
        
        
        readingTypeSegmentControl.setTitle("List View".localized, forSegmentAt: 0)
        readingTypeSegmentControl.setTitle("Chart View".localized, forSegmentAt: 1)
        
        readingTypeSegmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:Colors.PrimaryColor], for: .normal)
        readingTypeSegmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.HistoryHeaderFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        readingTypeSegmentControl.layer.cornerRadius = kButtonRadius
        readingTypeSegmentControl.layer.borderColor = Colors.PrimaryColor.cgColor
        readingTypeSegmentControl.layer.borderWidth = 1
        readingTypeSegmentControl.layer.masksToBounds = true
        
        doctorCommentTextView.backgroundColor = UIColor(white: 1, alpha: 0.7454489489489)
        
        let selectedPatientID = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let imagePath = "http://54.212.229.198:3000/upload/" + selectedPatientID + "image.jpg"
        let manager:SDWebImageManager = SDWebImageManager.shared()
        
        //cell.dialogTypeImage.image =   UIImage(named:"user.png")!
        manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                              options: SDWebImageOptions.highPriority,
                              progress: nil,
                              completed: {[weak self] (image, error, cached, finished, url) in
                                if (error == nil && (image != nil) && finished) {
                                    
                                    //cell.
                                    
                                    self?.patientImage.layer.cornerRadius =
                                        (self?.patientImage.frame.size.width)!/2
                                    
                                    self?.patientImage.clipsToBounds = true
                                    
                                    self?.patientImage.image = image
                                    
                                    let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(self?.imageTapped))
                                    self?.patientImage.addGestureRecognizer(tapGestureImage)
                                    self?.patientImage.isUserInteractionEnabled = true
                                    
                                }
        })
        
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
    
    override func viewDidLayoutSubviews() {
        
        //        viewDidLayoutSubviews()
        
        //scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2900)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
       // editCurrentMedArray.removeAllObjects()
        oldCurrentMedArray.removeAllObjects()
        let defaults = UserDefaults.standard
        editCurrentMedArray = defaults.array(forKey: "currentEditMedicationArray")! as [Any] as NSArray
        UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
        UserDefaults.standard.set(NSArray(), forKey:"currentEditReadingArray")
        UserDefaults.standard.set(false, forKey: "NewReadEditBool")
        UserDefaults.standard.set(false, forKey: "MedEditBool")
        UserDefaults.standard.synchronize()
        
        setNavBarUI()
    }
    
    @IBAction func sendRequestToDoctor(_ sender: Any) {
        
        editEducatorReportAPI()
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func currentMedEditActon(_ sender: UIButton) {
        
        
        
        currentMedEditBool = true
        UserDefaults.standard.set(true, forKey:"MedEditBool")
        UserDefaults.standard.synchronize()
        let carePlanViewController: CarePlanMainViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.carePlanViewController) as! CarePlanMainViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(carePlanViewController, animated: true)
        
        //            currentMedEdit.setTitle("Done", for: .normal)
        
        
        
        //        }
        //        else {
        //            currentMedEditBool = false
        //            self.view.endEditing(true)
        //            currentMedEdit.setTitle("Edit", for: .normal)
        //        }
        //        print("editCurrentMedArray\(editCurrentMedArray)")
        //        print("oldCurrentMedArray\(oldCurrentMedArray)")
        //        medicationTbl.reloadData()
    }
    
    @IBAction func currentReadEditAction(_ sender: UIButton) {
        
        let defaults = UserDefaults.standard
        
        if currentReadEdit.titleLabel!.text == "Edit" {
            UserDefaults.standard.set(true, forKey: "CurrentReadEditBool")
            print("Now it is true")
            currentReadEdit.setTitle("Done", for: .normal)
            
        }
        else {
            UserDefaults.standard.set(false, forKey: "CurrentReadEditBool")
           // let defaults = UserDefaults.standard
            editCurrentReadArray = defaults.array(forKey: "currentEditReadingArray")! as [Any] as NSArray
           //print("readArray\(editCurrentReadArray)")
            print("Now it is false")
            currentReadEdit.setTitle("Edit", for: .normal)
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
        editCurrentReadArray = defaults.array(forKey: "currentEditReadingArray")! as [Any] as NSArray
        UserDefaults.standard.synchronize()
        
        //     add(asChildViewController:reportCarePlanController )
        
    }
    
    @IBAction func readNewEditAction(_ sender: UIButton) {
        
        if readNewEdit.titleLabel!.text == "Edit" {
            UserDefaults.standard.set(true, forKey: "NewReadEditBool")
            readNewEdit.setTitle("Done", for: .normal)
        }
        else {
            UserDefaults.standard.set(false, forKey: "NewReadEditBool")
            readNewEdit.setTitle("Edit", for: .normal)
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.newReadingView), object: nil)
        
    }
    
    
  
    @IBAction func ViewModeButtons_Click(_ sender: UISegmentedControl) {
  
        
        if sender.backgroundColor == Colors.DHTabBarGreen {
            return
        }
        else {
            
            if sender.selectedSegmentIndex == 0 {
                //listBtn.setTitleColor(UIColor.white, for: .normal)
                //chartBtn.setTitleColor(UIColor.gray, for: .normal)
                
               // listBtn.backgroundColor = Colors.historyHeaderColor
                //chartBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = false
                chartViewContainer.isHidden = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: nil)
                
            }
            else {
                
              //  chartBtn.setTitleColor(UIColor.white, for: .normal)
               // listBtn.setTitleColor(UIColor.gray, for: .normal)
                
                //chartBtn.backgroundColor = Colors.historyHeaderColor
                //listBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = true
                chartViewContainer.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportChartHistoryView), object: nil)
                
            }
        }
    }
    
    //MARK: - Approve & Decline Button Methods
    
    @IBAction func declineBtn_Click(_ sender: Any) {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        
        let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
        let parameters: Parameters = [
            "taskid": taskID ]
        
        if declineLabel.titleLabel!.text == "Cancel".localized
        {
            Alamofire.request("\(baseUrl)\(ApiMethods.doctorDecline)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
                print("Validation Successful ")
            
                switch response.result {
                
                case .success:
                
                    SVProgressHUD.dismiss()
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        SVProgressHUD.dismiss()
                        
                        let status : String = JSON.value(forKey: "message") as! String
                        if status == "Success" {
                            let alert = UIAlertController(title:"Message", message: "Request Decline. Please inform the educator using group chat", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                //self.popToViewController()
                                self.navigationController?.popViewController(animated: true)
                            }) )
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.present(UtilityClass.displayAlertMessage(message:status, title: "Message"), animated: true, completion: nil)
                        }

                    }
                    break
                    
                case .failure:
                    print("failure")
                    SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                    break
                
                }
            }
        }
        
    }
    
    @IBAction func approveBtn_Click(_ sender: Any) {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
        // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "taskid": taskID,
            "editMedArray": editCurrentMedArray,
            "editReadArray":editCurrentReadArray]
      
//"\(baseUrl)\(ApiMethods.doctorApprove)"
        Alamofire.request("\(baseUrl)\(ApiMethods.doctorApprove)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    SVProgressHUD.dismiss()
                    
                    let status : String = JSON.value(forKey: "message") as! String
                    if status == "Success" {
                        let alert = UIAlertController(title:"Message", message: "Report Approved. Please inform the respective educator through group chat.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                           // self.popToViewController()
                            self.navigationController?.popViewController(animated: true)

                        }) )
                        self.present(alert, animated: true, completion: nil)
                    }
                    else {
                        self.present(UtilityClass.displayAlertMessage(message:status, title: "Message"), animated: true, completion: nil)
                    }

                }
                
                break
            case .failure:
                print("failure")
                SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                break
                
            }
        }
        
    }
    
    //MARK: - SegmentControl Methods
    @IBAction func SegmentControl_ValueChange(_ sender: Any) {
       
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.noOfDays), object: getSelectedNoOfDays())
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if selectedUserType == userType.doctor {
            let obj: CarePlanObj = newMedicationArray[textField.tag] as! CarePlanObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
           // obj.dosage  = ((resultString) as NSString) as String
            newMedicationArray.replaceObject(at:textField.tag, with: obj)
            print("obj.answer\(obj.dosage)")
            return true
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
           // obj.dosage  = ((resultString) as NSString) as String
            medicationArray.replaceObject(at:textField.tag, with: obj)
            print("obj.answer\(obj.dosage)")
            return true
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectedUserType == userType.doctor {
            //            let obj: CarePlanObj = newMedicationArray[textField.tag] as! CarePlanObj
            //            obj.dosage  = ((textField.text!) as NSString) as String
            //            newMedicationArray.replaceObject(at:textField.tag, with: obj)
            //            print("obj.answer\(obj.dosage)")
            
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            mainDict.setValue(obj.id, forKey: "id")
            mainDict.setValue(obj.name, forKey: "name")
            mainDict.setValue(obj.dosage, forKey: "dosage")
            if self.oldCurrentMedArray.count > 0 {
                for i in 0..<self.oldCurrentMedArray.count {
                    let id: String = (oldCurrentMedArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                    print(id)
                    if id == obj.id {
                        return
                    }
                }
                oldCurrentMedArray.add(mainDict)
                
            }
            else {
                oldCurrentMedArray.add(mainDict)
            }
            
            
            print("obj.answer\(obj.dosage)")
            
            
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedUserType == userType.doctor {
            let obj: CarePlanObj = newMedicationArray[textField.tag] as! CarePlanObj
            //obj.dosage  = ((textField.text!) as NSString) as String
            newMedicationArray.replaceObject(at:textField.tag, with: obj)
            print("obj.answer\(obj.dosage)")
            
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
           // obj.dosage  = ((textField.text!) as NSString) as String
            medicationArray.replaceObject(at:textField.tag, with: obj)
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            mainDict.setValue(obj.id, forKey: "id")
            mainDict.setValue(obj.name, forKey: "name")
            mainDict.setValue(obj.dosage, forKey: "dosage")
           /* if self.editCurrentMedArray.count > 0 {
                for i in 0..<self.editCurrentMedArray.count {
                    let id: String = (editCurrentMedArray.object(at:i) as AnyObject).value(forKey: "id") as! String
                    print(id)
                    if id == obj.id {
                        editCurrentMedArray.replaceObject(at:i, with: mainDict)
                        return
                    }
                }
                editCurrentMedArray.add(mainDict)
                
            }
            else {
                editCurrentMedArray.add(mainDict)
            }
            */
            print("obj.answer\(obj.dosage)")
            
            
        }
        
        
    }
    
    // MARK: - TextView Delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if educatorCommentTxtViw.textColor == UIColor.lightGray {
            educatorCommentTxtViw.text = nil
            educatorCommentTxtViw.textColor = UIColor.darkGray
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if educatorCommentTxtViw.text.isEmpty {
            educatorCommentTxtViw.text = "Please add comments to justify your decision"
            educatorCommentTxtViw.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == summaryTbl {
            return summaryTxtArray.count
        }
        else {
            if section == 1{
                return newMedicationArray.count
            }else {
                return medicationArray.count
            }
        }
        
        
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == summaryTbl {
            return 40
        }
        else {
            return 63
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if tableView == summaryTbl {
            return 1
        }
        else {
            return sections
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tableView == summaryTbl {
            let cell: SummartTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Summ", for:indexPath) as! SummartTableViewCell
            cell.nameTxtLbl.text = summaryArray.object(at: indexPath.row) as? String
            cell.ansTxtLbl.text  = summaryTxtArray.object(at: indexPath.row) as? String
           // cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.backgroundColor = UIColor.clear
            cell.layer.borderColor = UIColor.clear.cgColor
            cell.layer.borderWidth = 3
            return cell
        }
        else {
            
            let cell: ReportMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for:indexPath) as! ReportMedicationTableViewCell
            
            
            //            if selectedUserType == userType.doctor {
            //                if currentMedEditBool {
            //
            //                if indexPath.section == 0 {
            //                    cell.dosageTxtFld.isUserInteractionEnabled = false
            //                }
            //                else {
            //                     cell.dosageTxtFld.isUserInteractionEnabled = true
            //                }
            //                }
            //                else {
            //
            //                    if indexPath.section == 0 {
            //                        cell.dosageTxtFld.isUserInteractionEnabled = false
            //                    }
            //                    else {
            //                        cell.dosageTxtFld.isUserInteractionEnabled = false
            //                    }
            //
            //                }
            //
            //            }
            //            else {
            //
            //                if currentMedEditBool {
            //                if indexPath.section == 0 {
            //                    cell.dosageTxtFld.isUserInteractionEnabled = true
            //                }
            //                else {
            //                    cell.dosageTxtFld.isUserInteractionEnabled = false
            //                }
            //                }
            //                else {
            //                    if indexPath.section == 0 {
            //                        cell.dosageTxtFld.isUserInteractionEnabled = false
            //                    }
            //                    else {
            //                        cell.dosageTxtFld.isUserInteractionEnabled = false
            //                    }
            //
            //
            //                }
            //
            //            }
            cell.selectionStyle = .none
            //                    cell.dosageTxtFld.delegate = self
            //                    cell.dosageTxtFld.keyboardType = UIKeyboardType.numberPad
            
            if indexPath.section == 0 {
                if let obj: CarePlanObj = medicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                    
                    /* this is the dosage to be added */
                   // let dosageStr  = obj.dosage
                    //                    cell.dosageTxtFld.text = dosageStr
                    //                    cell.dosageTxtFld.tag = indexPath.row
                    
                }
            }
            else {
                if let obj: CarePlanObj = newMedicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                     /* this is the dosage to be added */
                    //let dosageStr : String = obj.dosage
                    //                    cell.dosageTxtFld.tag = indexPath.row
                    //                    cell.dosageTxtFld.text = dosageStr
                    
                }
                
            }
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == summaryTbl {
            return 0
        }
        else {
            if section == 1{
                return 50
            }
            else {
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == summaryTbl {
            return nil
        }
        else {
            if section == 1 {
                let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
                headerView.backgroundColor = UIColor.blue
                let lbl: UILabel = UILabel(frame: CGRect(x: 20, y: 5, width: tableView.frame.size.width-80, height: 35))
                editButton = UIButton(frame: CGRect(x:tableView.frame.size.width-80, y: 5, width: 80, height: 35))
                if currentMedEditBool  {
                    editButton.setTitle("Done", for:.normal)
                }
                else {
                    editButton.setTitle("Edit", for:.normal)
                }
                //        editButton.setTitle("Edit", for:.normal)
                editButton.titleLabel?.textColor = UIColor.white
                editButton.addTarget(self, action: #selector(ReportViewController.newMedEditActon(_:)), for: .touchUpInside)
                
                lbl.text = "New Medication"
                lbl.textColor = UIColor.white
                lbl.font = Fonts.HistoryHeaderFont
                headerView.addSubview(editButton)
                headerView.addSubview(lbl)
                headerView.tag = section
                
                return headerView
            }
            else {
                return nil
            }
        }
    }
    
    // MARK: - Custom Top View
    func createCustomTopView() {
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            topBackView = UIView(frame: CGRect(x: self.view.frame.size.width - 80, y: 0, width: 75, height: 40))
            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topbackArbic")!)
            let userImgView: UIImageView = UIImageView(frame: CGRect(x: 5 , y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
            topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
            
            
        }
        else {
            
            topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 40))
            topBackView.backgroundColor = UIColor(patternImage: UIImage(named: "topBackBtn")!)
            let userImgView: UIImageView = UIImageView(frame: CGRect(x: 35, y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
            topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
        }
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        self.title = "\("READING_HISTORY".localized)"
        self.tabBarController?.title = "\("READING_HISTORY".localized)"
        self.tabBarController?.navigationItem.title = "\("READING_HISTORY".localized)"
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        createCustomTopView()
        
        
    }
    
    func newMedEditActon(_ sender: UIButton) {
        if editButton.titleLabel!.text == "Edit" {
            currentMedEditBool = true
            editButton.setTitle("Done", for: .normal)
        }
        else {
            currentMedEditBool = false
            editButton.setTitle("Edit", for: .normal)
        }
        medicationTbl.reloadData()
    }
    
    func getSelectedNoOfDays() -> String {
        
        
        switch segmentControl.selectedSegmentIndex {
        case HistoryDays.days_today:
            
            return "0"
        case HistoryDays.days_7:
            
            return "7"
        case HistoryDays.days_14:
            
            return "14"
        case HistoryDays.days_30:
            
            return "30"
        default:
            return ""
        }
        
        
        
        
    }
    
    
    func callDoctorOrEducatorReportAPI()  {
        if selectedUserType == userType.doctor {
            doctorReportAPI()
        }
        else {
            getEducatorReportAPI()
        }
        
    }
    
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getEducatorReportAPI()  {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)! as String
        let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)! as String
        
        print(patientsID)
        let parameters: Parameters = [
            "patientid": patientsID ,
            "educatorid": educatorID,
            "numDaysBack": getSelectedNoOfDays(),
            "condition": "All conditions"
        ]
        print(parameters) //http://54.212.229.198:3000/geteducatorreport
        Alamofire.request("\(baseUrl)\(ApiMethods.getEducatorGroupReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    //print("JSON \(JSON)")
                    
                    self.summaryTxtArray.add(JSON.object(forKey: "name") as! String)
                    if self.selectedUserType == userType.doctor{
                        self.summaryTxtArray.add(JSON.object(forKey: "educatorName") as! String)}
                    else{
                        self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)}
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    print(jsonArr.count)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    print(readingArr.count)
                    for data in jsonArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        
                        //                        let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                        //                        if timingArray.count > 0 {
                        //                        let timedict:NSDictionary = timingArray[0] as! NSDictionary
                        //                        obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                        //                        }
                        //                        else {
                        //                            obj.dosage = ""
                        //                        }
                        //                      obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.medicationArray.add(obj)
                    }
                    
                    self.dynamicEducatorViewLayout(medArrCount:jsonArr.count, readingArrcount: readingArr.count , glucoseReadingCount:glucoseReadingArr.count)
                    self.medicationTbl.reloadData()
                    SVProgressHUD.dismiss()
                }
                
                break
            case .failure:
                print("failure")
                SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
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
            "numDaysBack": getSelectedNoOfDays(),
            "condition": "Post Lunch"
        ]
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getDoctorRequestReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    //print("JSON \(JSON)")
                    var reportStatus: Bool = false
                    
                    if((JSON.object(forKey: "isReportApproved") != nil) || (JSON.object(forKey: "isReportDeclined") != nil)){
                        reportStatus = true
                    }
                    self.summaryTxtArray.add(JSON.object(forKey: "name") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "educatorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    UserDefaults.standard.setValue(JSON.object(forKey: "patientID") as! String, forKey: userDefaults.selectedPatientID);
                    let arr : NSArray = JSON.object(forKey: "educatorComment") as! NSArray
                    self.doctorCommentTextView.text = arr.object(at: 0) as! String
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    
                    /*if reportStatus{
                        self.approveLabel.isHidden = true
                        self.declineLabel.isHidden = true
                    }*/
                    
                    if jsonArr.count > 0 {
                        self.medicationArray.removeAllObjects()
                        for data in jsonArr {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            obj.name = dict.value(forKey: "name") as! String
                            
                            
                            //let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                            
                            //let timedict:NSDictionary = timingArray[0] as! NSDictionary
                           // obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                            
                            //                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                            self.medicationArray.add(obj)
                        }
                    }
                    
                   // let jsonNewArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedMedication") as! NSArray)
                    let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    
                    let updateReadingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedReading") as! NSArray)
                    
                    
                    if updateReadingArr.count == 0 {
                        self.sections = 1
                    }
                    
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    
                    print(jsonArr.count)
                    self.dynamicDoctorViewLayout(medArrCount:jsonArr.count, readingArrcount:readingArr.count , updateReadingCount: updateReadingArr.count , glucoseReadingCount: glucoseReadingArr.count)
                    
                 /*   if jsonNewArr.count > 0 {
                        for data in jsonNewArr {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            obj.name = dict.value(forKey: "name") as! String
                            
                            
                            let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                            
                            let timedict:NSDictionary = timingArray[0] as! NSDictionary
                           // obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                            
                            //                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                            self.newMedicationArray.add(obj)
                        }
                    }*/
                    self.medicationTbl.reloadData()
                    
                    
                }
                
                break
            case .failure:
                print("failure")
                 SVProgressHUD.showError(withStatus: response.result.error?.localizedDescription)
                break
                
            }
        }
        
        
    }
    
    func doctorSingleReportAPI() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        
        
        let parameters: Parameters = [
            "patientid": patientsID,
            "numDaysBack":  getSelectedNoOfDays(),
            "condition": "All conditions",
            "usertype": selectedUserType
        ]
        print("URL")
       print("\(baseUrl)\(ApiMethods.getDoctorGroupReport)")
        Alamofire.request("\(baseUrl)\(ApiMethods.getDoctorGroupReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                   // print("JSON \(JSON)")
                  /* if self.selectedUserType == userType.doctor{
                    let educatorIndex = self.summaryArray.index(of: "Educator")
                    self.summaryArray.inde

                    }
                    else{
                       
                    }*/
                    
                    self.summaryTxtArray.add(JSON.object(forKey: "patientName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    print(jsonArr.count)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    print(readingArr.count)
                    for data in jsonArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                      //  let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                       // let timedict:NSDictionary = timingArray[0] as! NSDictionary
                        //obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                        //                      obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.medicationArray.add(obj)
                    }
                    
                    self.dynamicEducatorDoctorViewLayout(medArrCount:jsonArr.count, readingArrcount: readingArr.count, glucoseReadingCount:glucoseReadingArr.count)
                    self.medicationTbl.reloadData()
                    SVProgressHUD.dismiss()
                }
                
                break
            case .failure:
                print("failure")
                SVProgressHUD.showError(withStatus: response.result.error?.localizedDescription)
                break
                
            }
        }
        
        
    }
    
    
    func editEducatorReportAPI()  {
        
        // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        do {
            //Convert to Data
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
            let updateMedData = try JSONSerialization.data(withJSONObject: editCurrentMedArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            //Convert back to string. Usually only do this for debugging
            let updateMedJSONString : String  = String(data: updateMedData, encoding: String.Encoding.utf8)!
            let updateReadData = try JSONSerialization.data(withJSONObject: editCurrentReadArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            //Convert back to string. Usually only do this for debugging
            let updateReadJSONString : String  = String(data: updateReadData, encoding: String.Encoding.utf8)!
            
         //   print("MedJSONString\(updateMedJSONString)")
          //  print("ReadJSONString\(updateReadJSONString)")
            
            
            
            var actionSegment = String()
            if actionSegmentControl.selectedSegmentIndex == 0 {
                actionSegment = "No change"
            }
            else {
                actionSegment = "Changes mode"
            }
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let educatorID = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)! as String
            let recepientTypes = UserDefaults.standard.array(forKey: userDefaults.recipientTypesArray)! as NSArray
            let recepientIDs = UserDefaults.standard.array(forKey: userDefaults.recipientIDArray)! as NSArray
            
            var doctorID : String = ""
            
            if(recepientTypes.contains("doctor")){
                doctorID = recepientIDs[recepientTypes.index(of: "doctor")] as! String
            }
            
            //else if(typeUser == userType.patient && recipientTypes.contains("doctor"))
            //                {
            //                    databaseToCheck = "Doctor"
            //                    selectedPatientID = recipientIDs[recipientTypes.index(of: "doctor")!]
            //                }

            
            let parameters: Parameters = [
                "patientid": patientsID,
                "educatorid":educatorID,
                "doctorid": doctorID,
                "isApproved": false,
                "isDeclined" :false,
                "updatedmeds" : editCurrentMedArray,
                "updatedread" : editCurrentReadArray,
                "comment" : educatorCommentTxtViw.text,
                "action":actionSegment,
                "hcNumber": "",
                "hba":""
            ]
            
            print("Parameters \(parameters)")
          //  "http://54.244.176.114:3000/savetask"
            Alamofire.request("\(baseUrl)\(ApiMethods.saveEducatorReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
           
                
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    
                    SVProgressHUD.dismiss()
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentEditMedicationArray")
                    UserDefaults.standard.synchronize()

                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print("JSON \(JSON)")
                        let status : String = JSON.value(forKey: "message") as! String
                        if status == "Success" {
                            let alert = UIAlertController(title:"Message", message: "Request sent to doctor", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                //self.popToViewController()
                                self.navigationController?.popViewController(animated: true)
                            }) )
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.present(UtilityClass.displayAlertMessage(message:status, title: "Message"), animated: true, completion: nil)
                        }
                        
                        
                        
                    }
                    
                    break
                case .failure:
                    print("failure")
                    SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                    break
                    
                }
            }
        }
        catch {
            
        }
    }
    
    func popToViewController()  {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
     // MARK: - Dynamic  Constraints Methods
    func dynamicEducatorDoctorViewLayout(medArrCount : Int , readingArrcount: Int , glucoseReadingCount : Int)
    {
        //        glucoseReadingLayoutConstraint.constant = CGFloat((glucoseReadingCount * 60) + 200)
        //        self.medicationView.setY(y:glucoseReadingView.frame.origin.y + glucoseReadingLayoutConstraint.constant)
        if medArrCount > 0 {
            self.medicationViewHeight.constant = CGFloat((medArrCount * 63) + 49)
        }
        else {
            self.medicationViewHeight.constant = 0.0
        }
        if readingArrcount > 0{
            self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
            currentReadingContainerHeight.constant   = CGFloat((readingArrcount * 160)) ;
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
            readingScheduleHeightConstraint.constant = CGFloat((readingArrcount * 160)) ;
        }
        else {
            self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
            currentReadingContainerHeight.constant   = 0.0 ;
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
            readingScheduleHeightConstraint.constant = 0.0 ;
            
        }
        educatorViewHeightConstraint.constant = 0.0
        
        self.doctorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorActionView.frame.origin.y + doctorActionView.frame.size.height)
        print( doctorActionView.frame.origin.y)
    }
    
    func dynamicEducatorViewLayout(medArrCount : Int , readingArrcount: Int , glucoseReadingCount : Int)
    {
        //        glucoseReadingLayoutConstraint.constant = CGFloat((glucoseReadingCount * 60) + 200)
        //        self.medicationView.setY(y:glucoseReadingView.frame.origin.y + glucoseReadingLayoutConstraint.constant)
        if medArrCount > 0 {
            self.medicationViewHeight.constant = CGFloat((medArrCount * 63) + 49)
        }
        else {
            self.medicationViewHeight.constant = 0.0
        }
        if readingArrcount > 0{
            self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
            currentReadingContainerHeight.constant   = CGFloat((readingArrcount * 160)) ;
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
            readingScheduleHeightConstraint.constant = CGFloat((readingArrcount * 160)) ;
        }
        else {
            self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
            currentReadingContainerHeight.constant   = 0.0 ;
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
            readingScheduleHeightConstraint.constant = 0.0 ;
            
        }
        
        self.educatorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: educatorActionView.frame.origin.y + educatorActionView.frame.size.height)
        print( educatorActionView.frame.origin.y)
    }
    
    
    func dynamicDoctorViewLayout(medArrCount : Int , readingArrcount: Int , updateReadingCount : Int, glucoseReadingCount : Int)
    {
        if medArrCount > 0 {
            self.medicationViewHeight.constant = CGFloat((medArrCount * 63) + 49)
        }
        else {
            self.medicationViewHeight.constant = 0.0
        }
        self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
        if readingArrcount == 0 {
            currentReadingContainerHeight.constant   = 0.0
            
        }
        else  if updateReadingCount == 0 {
            
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0        }
            
        else  {
            
            currentReadingContainerHeight.constant   = CGFloat((readingArrcount * 160) + 50) ;
            newReadingContainerHeight.constant = CGFloat((updateReadingCount * 160)) ;
            
            
        }
        
        readingScheduleHeightConstraint.constant = self.currentReadingContainerHeight.constant + newReadingContainerHeight.constant
        educatorViewHeightConstraint.constant = 0.0
        self.doctorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorActionView.frame.origin.y + doctorActionView.frame.size.height)
        print( educatorActionView.frame.origin.y)
        
    }
    
    
}
extension UIView {
    /**
     Set x Position
     
     :param: x CGFloat
     by DaRk-_-D0G
     */
    func setX(x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    /**
     Set y Position
     
     :param: y CGFloat
     by DaRk-_-D0G
     */
    func setY(y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    /**
     Set Width
     
     :param: width CGFloat
     by DaRk-_-D0G
     */
    func setWidth(width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    /**
     Set Height
     
     :param: height CGFloat
     by DaRk-_-D0G
     */
    func setHeight(height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
}
