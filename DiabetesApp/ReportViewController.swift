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


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
var keyboardModifier: CGFloat = 0
class ReportViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    //@IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var patientImage: UIImageView!
    @IBOutlet weak var summaryTextLabel: UILabel!
    
    @IBOutlet weak var summaryView: UIView!
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
    
     @IBOutlet weak var currentMedicationsLabelHeightConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var actionLabel: UILabel!
    
   // @IBOutlet weak var actionSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var commentEducatorLabel: UILabel!
    @IBOutlet weak var doctorActionView: UIView!
    @IBOutlet weak var addCommentsLabel: UILabel!
    
    @IBOutlet weak var educatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var educatorActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var commentEducatorLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorCommentTextView: UITextView!
    @IBOutlet weak var declineLabel: UIButton!
    @IBOutlet weak var approveLabel: UIButton!
    //@IBOutlet weak var doctorAcionView: UIView!
    @IBOutlet weak var reportEmergencyLabel: UIButton!
    @IBOutlet weak var sendRequestLabel: UIButton!
    @IBOutlet weak var educatorCommentTxtViw: UITextView!
    
    @IBOutlet weak var vwMedicationContainer: UIView!
    @IBOutlet weak var vwMedicationContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var vwMedicationContainerTopConstraint: NSLayoutConstraint!
    
    //Summary Top Constraint
    @IBOutlet weak var csSummaryViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csSummaryHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var btnSummarayOpen: UIButton!
    
    //Glucose Top Constraint
    @IBOutlet weak var csGlucoseViewHeight: NSLayoutConstraint!
    @IBOutlet weak var csGlucoseHeaderHeight: NSLayoutConstraint!
    @IBOutlet weak var btnGlucoseOpen: UIButton!
    
    //Medication Top Constraint
    @IBOutlet weak var btnMedicationOpen: UIButton!
    
    //Reading Top Constraint
    @IBOutlet weak var btnReadingOpen: UIButton!
    
    var sections = Int()
    var editButton: UIButton!
    var approveTextView = UITextView()
    
    var topBackView:UIView = UIView()
    var summaryArray = NSArray()
    var summaryTxtArray = NSMutableArray()
    var medicationArray = NSMutableArray()
    var readingArr = NSMutableArray()
    var newMedicationArray = NSMutableArray()
    var currentMedEditBool = Bool()
    var currentReadEditBool = Bool()
    
    var editCurrentMedDict = NSDictionary()
    //var editCurrentMedArray = NSMutableArray()
    //var editCurrentMedDict = NSDictionary()
    var addCurrentMedArray = NSArray()
    var addNewCurrentMedArray = NSArray()
    var deleteNewCurrentMedArray = NSArray()
    var editMedArray = NSMutableArray()
    var editCurrentMedArray = NSArray()
   // var editCurrentReadArray = NSArray()
    var oldCurrentMedArray = NSMutableArray()
    
    var editCurrentReadArray = NSArray()
    var addNewCurrentReadArray = NSArray()
    var deleteNewCurrentReadArray = NSArray()

   // let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    
    //var taskID = String()
    var reportUser = String()
    var totalBadgeCounter =  Int()
    var newImageView : UIImageView = UIImageView()
    
    var medicationHeight =  Int()
    var readingViewHeight =  Int()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  print(taskID)
        self.setDefaultValue()
        self.hideKeyboardWhenTappedAround()
        self.addDoneButtonOnKeyboard()
        
        if selectedUserType == userType.doctor && !UserDefaults.standard.bool(forKey: "groupChat"){
            btnSummarayOpen.isSelected = false
        }
        
       //Keyboard Appear and disappear
        NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.keyboardWillAppear(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.keyboardWillDisappear(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.MedicationHeight(notification:)), name: NSNotification.Name(rawValue: "MedicationHeightReportView"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(ReportViewController.readingHeight(notification:)), name: NSNotification.Name(rawValue: "ReadingHeightReportView"), object: nil)
        
        
        
        newReadingViewContainer.isHidden = true
        educatorCommentTxtViw.text = "Please add comments to justify your decision".localized
        educatorCommentTxtViw.textColor = UIColor.lightGray
        
        approveLabel.setTitle("Approve".localized, for: .normal)
        declineLabel.setTitle("Decline".localized, for: .normal)
        sendRequestLabel.setTitle("Send Request to Doctor".localized, for: .normal)
        reportEmergencyLabel.setTitle("Report Emergency".localized, for: .normal)
        
        summaryTextLabel.text = "  "+"Summary".localized
        summaryTextLabel.layer.cornerRadius = kButtonRadius
        summaryTextLabel.layer.masksToBounds = true
        
        glucoseReadingLabel.text = "  "+"Glucose Readings".localized
        glucoseReadingLabel.layer.cornerRadius = kButtonRadius
        glucoseReadingLabel.layer.masksToBounds = true
        
        currentReadingTitleLabel.text = "  "+"Current Reading Schedule".localized
        currentReadEdit.setTitle("Edit".localized, for: .normal)
        currentReadingTitleLabel.layer.cornerRadius = kButtonRadius
        currentReadingTitleLabel.layer.masksToBounds = true

        currentMedicationsLabel.text = "  "+"Current Medications".localized
        currentMedEdit.setTitle("Edit".localized, for: .normal)
        currentMedicationsLabel.layer.cornerRadius = kButtonRadius
        currentMedicationsLabel.layer.masksToBounds = true
        
        
        if selectedUserType == userType.doctor{
            commentEducatorLabel.text = "  "+"Comments By Educator".localized
            commentEducatorLabel.layer.cornerRadius = kButtonRadius
            commentEducatorLabel.layer.masksToBounds = true
        }
        else{
            commentEducatorLabel.text = "  "+"Comments By Doctor".localized
            commentEducatorLabel.layer.cornerRadius = kButtonRadius
            commentEducatorLabel.layer.masksToBounds = true
        }

//        actionLabel.text = "  "+"Action".localized
//        actionLabel.layer.cornerRadius = kButtonRadius
//        actionLabel.layer.masksToBounds = true
        
         if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if selectedUserType == userType.doctor {
                sections = 1
                
               
                
                summaryArray = ["Patient".localized,"Educator".localized,"HC#".localized,"Diabetes".localized]
                //doctorReportAPI()
                educatorActionViewHeight.constant = 0
                let rect = CGRect(x: 0, y: 0, width: 100, height: 0)
                educatorActionView.frame = rect
                educatorActionView.isHidden = true
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = false
                self.currentReadEdit.isHidden = false
                self.readNewEdit.isHidden = false
                lbl.isHidden = false
                
            }
            else {
                sections = 1
               // doctorSingleReportAPI()
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
                doctorActionViewHeight.constant =  commentsByEducatorHeightConstraint.constant + doctorCommentTextView.frame.origin.y
//                let rect = CGRect(x: 0, y: 0, width: 100, height: doctorActionViewHeight.constant)
//                doctorActionView.frame = rect
                doctorActionView.isHidden = false
                let rect1 = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect1
                educatorActionView.isHidden = true
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = true
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = true
                self.readNewEdit.isHidden = true
                lbl.isHidden = true
                
                updateReadByEducator()
                
            }
            
        }
        else {
            
            if selectedUserType == userType.doctor {
                sections = 1
               // doctorSingleReportAPI()
               // doctorCommentTextView.isHidden = true
                
                approveLabel.isEnabled = false
                approveLabel.alpha = 0.25
                
                approveLabel.setTitle("Save Changes".localized, for: .normal)
                declineLabel.setTitle("REPORT_CANCEL".localized, for: .normal)
               
                doctorCommentTextView.isHidden = true
                commentEducatorLabelHeight.constant = 0
                commentsByEducatorHeightConstraint.constant = 0
                educatorActionViewHeight.constant = 0
                commentEducatorLabel.isHidden = true
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
                let rect1 = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect1
                educatorActionView.isHidden = true
                doctorActionViewHeight.constant = 161
                
                self.currentMedEdit.isHidden = false
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = false
                lbl.isHidden = true
            }
            else {
                sections = 1
               // getEducatorReportAPI()
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
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
        segmentControl.selectedSegmentIndex = 2
        
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
                                else{
                                    self?.patientImage.layer.cornerRadius =
                                        (self?.patientImage.frame.size.width)!/2
                                    
                                    self?.patientImage.clipsToBounds = true
                                    
                                    self?.patientImage.image = UIImage(named:"placeholder.png")
                                    
                                    let tapGestureImage = UITapGestureRecognizer(target: self, action: #selector(self?.imageTapped))
                                    self?.patientImage.addGestureRecognizer(tapGestureImage)
                                    self?.patientImage.isUserInteractionEnabled = true
                                }
        })
    }
    
    func updateReadByEducator(){
        
        let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
        let educatorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let parameters: Parameters = [
            "taskid": taskID,
            "userid":educatorID]

        
        Alamofire.request("\(baseUrl)\(ApiMethods.updateReadBy)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                SVProgressHUD.dismiss()
                
                break
                
            case .failure:
                print("failure")
                SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                break
                
            }
        }

    }
    
    func addDoneButtonOnKeyboard()
    {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "DONE".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneButtonAction))]
        toolBar.sizeToFit()
       
        self.educatorCommentTxtViw.inputAccessoryView = toolBar
        
    }
    
    
    func doneButtonAction()
    {
        self.educatorCommentTxtViw.resignFirstResponder()
        self.educatorCommentTxtViw.resignFirstResponder()
    }
    
    
    func imageTapped(_ sender: UITapGestureRecognizer) {
        let scrollV:UIScrollView = UIScrollView()
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
        sender.view?.removeFromSuperview()
    }
    
    override func viewDidLayoutSubviews() {
        
        //        viewDidLayoutSubviews()
        
        //scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2900)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
        //setDefaultValue()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setBackgroundColor()
        oldCurrentMedArray.removeAllObjects()
        let defaults = UserDefaults.standard
        editCurrentMedArray = defaults.array(forKey: "currentEditMedicationArray")! as [Any] as NSArray
       // editCurrentReadArray = defaults.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
        addNewCurrentMedArray = defaults.array(forKey: "currentAddNewMedicationArray")! as [Any] as NSArray
        deleteNewCurrentMedArray = defaults.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
        print("delted medication")
        print(deleteNewCurrentMedArray.count)
        
        editCurrentReadArray = defaults.array(forKey: "currentEditReadingCareArray")! as [Any] as NSArray
        addNewCurrentReadArray = defaults.array(forKey: "currentAddReadingArray")! as [Any] as NSArray
        deleteNewCurrentReadArray = defaults.array(forKey: "currentDeleteReadingArray")! as [Any] as NSArray
        //segmentControl.selectedSegmentIndex = 2
        if UserDefaults.standard.bool(forKey: "groupChat")  {
            if selectedUserType == userType.doctor{
                if editCurrentMedArray.count > 0 || editCurrentReadArray.count > 0 || addNewCurrentMedArray.count > 0 ||
                     deleteNewCurrentMedArray.count > 0 || deleteNewCurrentReadArray.count > 0 || addNewCurrentReadArray.count > 0
                {
                    approveLabel.isEnabled = true
                    approveLabel.alpha = 1.0
                }
            }
        }
        addCurrentMedArray = defaults.array(forKey: "currentAddMedicationArray")! as [Any] as NSArray
        UserDefaults.standard.set(NSArray(), forKey: "updateReadingCareArray")
        
//        if UserDefaults.standard.bool(forKey: "CurrentReadEditBool") {
//            
//        currentReadingContainerHeight.constant   = CGFloat(((editCurrentReadArray.count * 50) + 130)) ;
//        newReadingContainerHeight.constant = 0.0
//        newRedEditConstraint.constant = 0.0
//        readingScheduleHeightConstraint.constant = CGFloat(((editCurrentReadArray.count * 50) + 130)) ;
//        self.doctorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
//        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorActionView.frame.origin.y + doctorActionView.frame.size.height)
//        print( doctorActionView.frame.origin.y)
//        }
        
//UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
        //UserDefaults.standard.set(NSArray(), forKey:"currentEditReadingArray")
        //below one is when the doctor adds a new med. the med needs to be deleted if the doctor presses cancel.
        //this happens only when the doctor goes thrugh  group chat
        //UserDefaults.standard.set(NSArray(), forKey:"currentAddMedicationArray")
        //below one is when the educator adds a new array. this will be saved with the task
      //  UserDefaults.standard.setValue(NSArray(), forKey: "currentAddNewMedicationArray")
        UserDefaults.standard.synchronize()
        
        setNavBarUI()
        
        if !UserDefaults.standard.bool(forKey: "groupChat")  {
            if selectedUserType == userType.doctor {
                sections = 1
                summaryArray = ["Patient".localized,"Educator".localized,"HC#".localized,"Diabetes".localized]
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
                doctorReportAPI()
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
                doctorActionViewHeight.constant =  commentsByEducatorHeightConstraint.constant + doctorCommentTextView.frame.origin.y
//                let rect = CGRect(x: 0, y: 0, width: 100, height: doctorActionViewHeight.constant)
//                doctorActionView.frame = rect
                doctorActionView.isHidden = false
                let rect1 = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
                educatorActionView.frame = rect1
                educatorActionView.isHidden = true
                newReadingViewContainer.isHidden = true
                self.currentMedEdit.isHidden = true
                self.readNewEdit.isHidden = true
                self.currentReadEdit.isHidden = true
                self.readNewEdit.isHidden = true
                lbl.isHidden = true
                
            }
        }
        else {
            
            if selectedUserType == userType.doctor {
                sections = 1
                doctorSingleReportAPI()
                doctorCommentTextView.isHidden = true
                
                commentsByEducatorHeightConstraint.constant = 0
                commentEducatorLabel.isHidden = true
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
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
                summaryArray = ["Patient".localized,"Doctor".localized,"HC#".localized,"Diabetes".localized]
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
    }
    
    @IBAction func sendRequestToDoctor(_ sender: Any) {
        
        editEducatorReportAPI()
        
    }
    func setDefaultValue()
    {
        UserDefaults.standard.setValue(NSArray(), forKey: "currentEditMedicationArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "currentAddNewMedicationArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "currentDeleteMedicationArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "currentAddMedicationArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "updateReadingCareArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "repoMediArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "repoOldMediArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "repoReadiArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "repoOldReadiArray")
        
        UserDefaults.standard.setValue(NSArray(), forKey: "currentDeleteReadingArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "currentAddReadingArray")
        UserDefaults.standard.setValue(NSArray(), forKey: "currentEditReadingCareArray")
        UserDefaults.standard.set(false, forKey: "NewReadEditBool")
        UserDefaults.standard.set(false, forKey: "MedEditBool")
        UserDefaults.standard.set(false, forKey: "CurrentReadEditBool")
        UserDefaults.standard.synchronize()
    }
    // MARK: - Keyboard Modifier 
    func keyboardWillAppear(notification: NSNotification) {
    
        keyboardResize(notification: notification)
        scrollToBottom()
    }
    
    func keyboardWillDisappear(notification: NSNotification) {

        keyboardResize(notification: notification)
    }
    func MedicationHeight(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
        let height  = userInfo["height"] as? CGFloat else{
            return
        }
        
        self.medicationHeight =  Int(CGFloat(height + 49))
        self.setViewExpanable()
    }
    func readingHeight(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let height  = userInfo["height"] as? CGFloat else{
                return
        }
        
        self.readingViewHeight =  Int(CGFloat(height + 49))
        self.setViewExpanable()
    }
    
    func keyboardResize(notification: NSNotification) {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            let userInfo = notification.userInfo!
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            let kbFrameEnd = self.view.convert(keyboardEndFrame, to: nil)
            let kbFrameBegin = self.view.convert(keyboardBeginFrame, to: nil)
            
            keyboardModifier = kbFrameBegin.origin.y - kbFrameEnd.origin.y
            
            self.scrollView.frame.size.height -= keyboardModifier
        })
    }
    
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    // MARK: - SetExpanable View
    func setViewExpanable()
    {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            if(self.btnSummarayOpen.isSelected)
            {
                self.csSummaryViewHeight.constant = 216
            }
            else
            {
                self.csSummaryViewHeight.constant = 42
            }
            self.glucoseReadingView.setY(y: self.csSummaryViewHeight.constant + self.summaryView.frame.origin.y)
            if(self.btnGlucoseOpen.isSelected)
            {
                self.glucoseReadingLayoutConstraint.constant = 660
            }
            else
            {
                self.glucoseReadingLayoutConstraint.constant = 42
            }
            self.medicationView.setY(y: self.glucoseReadingLayoutConstraint.constant + self.glucoseReadingView.frame.origin.y)
            if(self.btnMedicationOpen.isSelected)
            {
                self.medicationViewHeight.constant = CGFloat(self.medicationHeight)
            }
            else
            {
                self.medicationViewHeight.constant = 44
            }
            self.readingScheduleView.setY(y: self.medicationViewHeight.constant + self.medicationView.frame.origin.y
            )
            
            if(self.btnReadingOpen.isSelected)
            {
                self.currentReadingContainerHeight.constant = CGFloat(self.readingViewHeight + 10)
                self.readingScheduleHeightConstraint.constant = CGFloat(self.readingViewHeight  + 10)
           
            }
            else
            {
                self.readingScheduleHeightConstraint.constant = 44
                 self.currentReadingContainerHeight.constant =  44
            }
            
            if !UserDefaults.standard.bool(forKey: "groupChat")  {
                self.educatorViewHeightConstraint.constant = 0.0
                
                self.doctorActionView.setY(y: self.readingScheduleView.frame.origin.y + self.readingScheduleHeightConstraint.constant + 10)
                self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.doctorActionView.frame.origin.y + self.doctorActionView.frame.size.height + 15)
                print( self.doctorActionView.frame.origin.y)
            }
            else
            {
                if self.selectedUserType == userType.doctor {
                    self.educatorViewHeightConstraint.constant = 0.0
                    
                    self.doctorActionView.setY(y: self.readingScheduleView.frame.origin.y + self.readingScheduleHeightConstraint.constant + 10)
                    self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.doctorActionView.frame.origin.y + self.doctorActionView.frame.size.height + 15)
                    print( self.doctorActionView.frame.origin.y)
                }
                else
                {
                    self.educatorActionView.setY(y: self.readingScheduleView.frame.origin.y + self.readingScheduleHeightConstraint.constant + 10)
                    
                    self.scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: self.educatorActionView.frame.origin.y + self.educatorActionView.frame.size.height + 15)
                }
            }
          
            
        })
    }
    func setBackgroundColor()
    {
        if(self.btnSummarayOpen.isSelected)
        {
            self.summaryTextLabel.backgroundColor = Colors.DHTabBarGreen
        }
        else
        {
            self.summaryTextLabel.backgroundColor =  Colors.PrimaryColor
        }
        
        if(self.btnGlucoseOpen.isSelected)
        {
            self.glucoseReadingLabel.backgroundColor = Colors.DHTabBarGreen
        }
        else
        {
             self.glucoseReadingLabel.backgroundColor =  Colors.PrimaryColor
        }
        
        if(self.btnMedicationOpen.isSelected)
        {
           self.currentMedicationsLabel.backgroundColor = Colors.DHTabBarGreen
        }
        else
        {
             self.currentMedicationsLabel.backgroundColor =  Colors.PrimaryColor
        }
        
        if(self.btnReadingOpen.isSelected)
        {
            self.currentReadingTitleLabel.backgroundColor = Colors.DHTabBarGreen
        }
        else
        {
            self.currentReadingTitleLabel.backgroundColor =  Colors.PrimaryColor
        }
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func btnSummarayOpen_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        if(btn.isSelected)
        {
            btn.isSelected = false
            
        }
        else
        {
            btn.isSelected = true
        }
        setViewExpanable()
        setBackgroundColor()
    }
    @IBAction func btnGlucoseOpen_Clicked(_ sender: Any) {
       let btn = sender as! UIButton
        if(btn.isSelected)
        {
            btn.isSelected = false
            
        }
        else
        {
          btn.isSelected = true
        }
        setViewExpanable()
        setBackgroundColor()
    }
    
    @IBAction func btnMedicationOpen_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        if(btn.isSelected)
        {
            btn.isSelected = false
            
        }
        else
        {
            btn.isSelected = true
        }
        setViewExpanable()
        setBackgroundColor()
    }
    @IBAction func btnReadingOpen_Clicked(_ sender: Any) {
        let btn = sender as! UIButton
        if(btn.isSelected)
        {
            btn.isSelected = false
            
        }
        else
        {
            btn.isSelected = true
        }
        setViewExpanable()
        setBackgroundColor()
    }
    
    @IBAction func currentMedEditActon(_ sender: UIButton) {
        
        currentMedEditBool = true
        UserDefaults.standard.set(true, forKey:"MedEditBool")
        UserDefaults.standard.synchronize()
        let carePlanViewController: CarePlanMainViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.carePlanViewController) as! CarePlanMainViewController
        carePlanViewController.currentMedEditBool = true
        carePlanViewController.currentReadEditBool = false
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(carePlanViewController, animated: true)
    }
    
    @IBAction func currentReadEditAction(_ sender: UIButton) {
        
        currentReadEditBool = true
        UserDefaults.standard.set(true, forKey:"CurrentReadEditBool")
        UserDefaults.standard.set(true, forKey: "NewReadEditBool")
        UserDefaults.standard.synchronize()
        
        let carePlanViewController: CarePlanMainViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.carePlanViewController) as! CarePlanMainViewController
        carePlanViewController.currentMedEditBool = false
        carePlanViewController.currentReadEditBool = true
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationItem.hidesBackButton = true
        self.navigationController?.pushViewController(carePlanViewController, animated: true)
    }
    
    @IBAction func readNewEditAction(_ sender: UIButton) {
        
        if readNewEdit.titleLabel!.text == "Edit".localized {
            UserDefaults.standard.set(true, forKey: "NewReadEditBool")
            readNewEdit.setTitle("Done".localized, for: .normal)
        }
        else {
            UserDefaults.standard.set(false, forKey: "NewReadEditBool")
            readNewEdit.setTitle("Edit".localized, for: .normal)
        }
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.newReadingView), object: nil)
        
    }
    
    
  
    @IBAction func ViewModeButtons_Click(_ sender: UISegmentedControl) {
  
        let currentCondition =  UserDefaults.standard.string(forKey: "currentHistoryCondition");
        let myDict = ["current": currentCondition]

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
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: myDict)
                
            }
            else {
                
              //  chartBtn.setTitleColor(UIColor.white, for: .normal)
               // listBtn.setTitleColor(UIColor.gray, for: .normal)
                
                //chartBtn.backgroundColor = Colors.historyHeaderColor
                //listBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = true
                chartViewContainer.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportChartHistoryView), object: myDict)
                
            }
        }
    }
    
    //MARK: - Approve & Decline Button Methods
    
    
    @IBAction func declineBtn_Click(_ sender: Any) {
        
        
        
        // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        //print(self.declineLabel.titleLabel!.text)
        if self.declineLabel.titleLabel!.text != "REPORT_CANCEL".localized
        {   //"\(baseUrl)\(ApiMethods.doctorDecline)"
           
            let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
            
            let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height:100.0)
            //let rect = 100.0//CGRect(margin, margin, alertController.view.bounds.size.width - margin * 4.0, 100.0)
            approveTextView = UITextView(frame: rect)
            
            approveTextView.backgroundColor = UIColor.clear
            approveTextView.font = Fonts.NavBarBtnFont
            approveTextView.textColor = UIColor.lightGray
            // approveTextView.lineB
            approveTextView.text  = "Please add comments to justify your decision".localized
            approveTextView.delegate = self
            approveTextView.clipsToBounds = true
            
            
            //  customView.backgroundColor = UIColor.greenColor()
            alertController.view.addSubview(approveTextView)
            
            let somethingAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("something")
                print(self.approveTextView.text)
                
                SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
                
                var commentFromDoctor: String = ""
                if self.approveTextView.text == "Any comment".localized
                {
                    commentFromDoctor = ""
                }
                else{
                    commentFromDoctor = self.approveTextView.text
                }
            
                
                let parameters: Parameters = [
                    "taskid": taskID,
                    "comment" : commentFromDoctor]

                
                Alamofire.request("\(baseUrl)\(ApiMethods.doctorDecline)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    print("Validation Successful ")
                    
                    switch response.result {
                        
                    case .success:
                        
                        SVProgressHUD.dismiss()
                        if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                            SVProgressHUD.dismiss()
                            
                            let status : String = JSON.value(forKey: "message") as! String
                            if status == "Success" {
                                let alert = UIAlertController(title:"Message".localized, message: "Request Decline. Please inform the educator using group chat".localized, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                    //self.popToViewController()
                                    
                                    UserDefaults.standard.set(false, forKey:"NewReadEditBool")
                                    UserDefaults.standard.set(false, forKey:"MedEditBool")
                                    UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
                                    UserDefaults.standard.synchronize()

                                    
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }) )
                                self.present(alert, animated: true, completion: nil)
                            }
                            else {
                                self.present(UtilityClass.displayAlertMessage(message:status, title: "Message".localized), animated: true, completion: nil)
                            }
                            
                            if let badgeCounter = (UserDefaults.standard.value(forKey: userDefaults.totalBadgeCounter) as! String?){
                                let NewCounter = Int(badgeCounter )
                                let StringCounter = String(NewCounter! - 1 )
                                
                                UserDefaults.standard.set((StringCounter as! String), forKey:userDefaults.totalBadgeCounter)
                                
                            }
                            
                        }
                        break
                        
                    case .failure:
                        print("failure")
                        SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                        break
                        
                    }
                }
                
            })
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
            
            alertController.addAction(somethingAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion:{})
        }
        else{
            
            //let arr : NSArray = UserDefaults.standard.array(forKey: "currentAddMedicationArray")! as [Any] as NSArray
            
            
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            
            var commentFromDoctor: String = ""
            if self.approveTextView.text == "Any comment".localized
            {
                commentFromDoctor = ""
            }
            else{
                commentFromDoctor = self.approveTextView.text
            }

            
            let declineParams: Parameters = [
                "MedArraylength": self.addCurrentMedArray.count ,
                "patientID":patientsID,
                "comment" : commentFromDoctor]
            
            Alamofire.request("\(baseUrl)\(ApiMethods.canceleMeds)", method: .post, parameters: declineParams, encoding: JSONEncoding.default).responseJSON { response in
                
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    
                    SVProgressHUD.dismiss()
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        SVProgressHUD.dismiss()
                        
                        UserDefaults.standard.set(false, forKey:"NewReadEditBool")
                        UserDefaults.standard.set(false, forKey:"MedEditBool")
                        UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
                        UserDefaults.standard.synchronize()
                        self.setDefaultValue()
                        self.navigationController?.popViewController(animated: true)
                    }
                    break
                    
                case .failure:
                    print("failure")
                    SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                    break
                    
                }
            }
            
            
            
            
            /*  let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
             
             alertController.addAction(somethingAction)
             alertController.addAction(cancelAction)
             
             self.present(alertController, animated: true, completion:{})*/
        }
        
        
        
    }
    
    @IBAction func approveBtn_Click(_ sender: Any) {
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let margin:CGFloat = 8.0
        let rect = CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height:100.0)
        //let rect = 100.0//CGRect(margin, margin, alertController.view.bounds.size.width - margin * 4.0, 100.0)
        approveTextView = UITextView(frame: rect)
        
        approveTextView.backgroundColor = UIColor.clear
        approveTextView.font = Fonts.NavBarBtnFont
        approveTextView.textColor = UIColor.lightGray
        approveTextView.text  = "Any comment".localized
        approveTextView.delegate = self
        
        
        //  customView.backgroundColor = UIColor.greenColor()
        alertController.view.addSubview(approveTextView)
        
        
        let somethingAction = UIAlertAction(title: "Send".localized, style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in print("something")
            
            print(self.approveTextView.text)
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
            
            // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            
            
            if self.approveLabel.titleLabel?.text?.lowercased() == "save changes".localized{
                let selectedPatient: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
                let doctorID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
                let doctorName: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserFullname)!
                
                var commentFromDoctor : String = "";
                if self.approveTextView.text == "Any comment".localized
                {
                    commentFromDoctor = ""
                }
                else{
                    commentFromDoctor = self.approveTextView.text
                }
                let parameters: Parameters = [
                    "patientid": selectedPatient,
                    "doctorid": doctorID,
                    "editMedArray": self.editCurrentMedArray,
                    "editReadArray":self.editCurrentReadArray,
                    "newmedadd": self.addNewCurrentMedArray,
                    "deletedmeds" : self.deleteNewCurrentMedArray,
                    "newreadarray":self.addNewCurrentReadArray,
                    "readdeleted":self.deleteNewCurrentReadArray,
                    "comment" : commentFromDoctor,
                    "doctorname":doctorName]

                //"\(baseUrl)\(ApiMethods.saveDoctorChanges)"
                Alamofire.request("\(baseUrl)\(ApiMethods.saveDoctorChanges)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    switch response.result {
                        
                    case .success:
                        print("Validation Successful")
                        SVProgressHUD.dismiss()
                        if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                            SVProgressHUD.dismiss()
                            
                            let status : String = JSON.value(forKey: "message") as! String
                            if status == "Success" {
                                let alert = UIAlertController(title:"Message".localized, message: "Changes saved. Please inform the patient through group chat".localized, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                    // self.popToViewController()
                                    
                                    UserDefaults.standard.set(false, forKey:"NewReadEditBool")
                                    UserDefaults.standard.set(false, forKey:"MedEditBool")
                                    UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
                                    UserDefaults.standard.synchronize()
                                    self.setDefaultValue()
                                    self.navigationController?.popViewController(animated: true)
                                    
                                }) )
                                self.present(alert, animated: true, completion: nil)
                            }
                            else {
                                self.present(UtilityClass.displayAlertMessage(message:status, title: "Message".localized), animated: true, completion: nil)
                            }
                            
                            if let badgeCounter = (UserDefaults.standard.value(forKey: userDefaults.totalBadgeCounter) as! String?){
                                let NewCounter = Int(badgeCounter )
                                let StringCounter = String(NewCounter! - 1 )
                                
                                UserDefaults.standard.set((StringCounter as! String), forKey:userDefaults.totalBadgeCounter)
                                
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
            else{
                
                 var commentFromDoctor : String = "";
                if self.approveTextView.text == "Any comment".localized
                {
                    commentFromDoctor = ""
                }
                else{
                    commentFromDoctor = self.approveTextView.text
                }
                
                let taskID: String = UserDefaults.standard.string(forKey: userDefaults.taskID)!
                let parameters: Parameters = [
                    "taskid": taskID,
                    "editMedArray": self.editCurrentMedArray,
                    "editReadArray":self.editCurrentReadArray,
                    "deletedmeds" : self.deleteNewCurrentMedArray,
                    "newmedadd": self.addNewCurrentMedArray,
                    "newreadarray":self.addNewCurrentReadArray,
                    "readdeleted":self.deleteNewCurrentReadArray,
                    "comment" : commentFromDoctor]
                
                //"\(baseUrl)\(ApiMethods.doctorApprove)"
                
                
                Alamofire.request("\(baseUrl)\(ApiMethods.doctorApprove)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                    
                    
                    
                    switch response.result {
                        
                    case .success:
                        print("Validation Successful")
                        SVProgressHUD.dismiss()
                        if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                            SVProgressHUD.dismiss()
                            
                            let status : String = JSON.value(forKey: "message") as! String
                            if status == "Success" {
                                let alert = UIAlertController(title:"Message".localized, message: "Report Approved. Please inform the respective educator through group chat.".localized, preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                    // self.popToViewController()
                                    
                                    UserDefaults.standard.set(false, forKey:"NewReadEditBool")
                                    UserDefaults.standard.set(false, forKey:"MedEditBool")
                                    UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
                                    UserDefaults.standard.synchronize()

                                     self.setDefaultValue()
                                    self.navigationController?.popViewController(animated: true)
                                    
                                }) )
                                self.present(alert, animated: true, completion: nil)
                            }
                            else {
                                self.present(UtilityClass.displayAlertMessage(message:status, title: "Message".localized), animated: true, completion: nil)
                            }
                            
                            if let badgeCounter = (UserDefaults.standard.value(forKey: userDefaults.totalBadgeCounter) as! String?){
                                let NewCounter = Int(badgeCounter )
                                let StringCounter = String(NewCounter! - 1 )
                                
                                UserDefaults.standard.set((StringCounter as! String), forKey:userDefaults.totalBadgeCounter)
                                
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
        })
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in print("cancel")})
        
        alertController.addAction(somethingAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion:{})
        
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
           // print("obj.answer\(obj.dosage)")
            return true
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
           // obj.dosage  = ((resultString) as NSString) as String
            medicationArray.replaceObject(at:textField.tag, with: obj)
            //print("obj.answer\(obj.dosage)")
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
            
            
            //print("obj.answer\(obj.dosage)")
            
            
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedUserType == userType.doctor {
            let obj: CarePlanObj = newMedicationArray[textField.tag] as! CarePlanObj
            //obj.dosage  = ((textField.text!) as NSString) as String
            newMedicationArray.replaceObject(at:textField.tag, with: obj)
           // print("obj.answer\(obj.dosage)")
            
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
        
        if approveTextView.textColor == UIColor.lightGray {
            approveTextView.text = nil
            educatorCommentTxtViw.textColor = UIColor.darkGray
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if educatorCommentTxtViw.text.isEmpty {
            educatorCommentTxtViw.text = nil
            educatorCommentTxtViw.textColor = UIColor.lightGray
        }
        
        if  approveTextView.text.isEmpty {
            approveTextView.text = nil
            approveTextView.textColor = UIColor.lightGray
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return summaryTxtArray.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell: SummartTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Summ", for:indexPath) as! SummartTableViewCell
            cell.nameTxtLbl.text = summaryArray.object(at: indexPath.row) as? String
            cell.ansTxtLbl.text  = summaryTxtArray.object(at: indexPath.row) as? String
           // cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.backgroundColor = UIColor.clear
            cell.vwCelllBg.layer.borderColor = UIColor.clear.cgColor
            cell.vwCelllBg.layer.cornerRadius = kButtonRadius
            cell.vwCelllBg.layer.borderWidth = 10
            cell.vwCelllBg.layer.masksToBounds = true
           
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return nil
    }
    
    // MARK: - Custom Top View
    func createCustomTopView() {
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            
             topBackView = UIView(frame: CGRect(x: self.view.frame.size.width - 90, y: 0, width: 85, height: 40))
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 45, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topbackArbic")
            topBackView.addSubview(backImg)
            
           // let userImgView: UIImageView = UIImageView(frame: CGRect(x: 0 , y: 3, width: 34, height: 34))
            //userImgView.image = UIImage(named: "user.png")
           // topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
            
            
        }
        else {
            
            topBackView = UIView(frame: CGRect(x: 0, y: 0, width: 84, height: 40))
        
            let backImg : UIImageView = UIImageView(frame:CGRect( x: 0, y: 8, width: 40, height: 25))
            backImg.image = UIImage(named:"topBackBtn")
            topBackView.addSubview(backImg)
            
           // let userImgView: UIImageView = UIImageView(frame: CGRect(x: 40, y: 3, width: 34, height: 34))
           
           // topBackView.addSubview(userImgView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BackBtn_Click))
            topBackView.addGestureRecognizer(tapGesture)
            topBackView.isUserInteractionEnabled = true
            
            self.tabBarController?.navigationController?.navigationBar.addSubview(topBackView)
            self.navigationController?.navigationBar.addSubview(topBackView)
        }
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        self.title = "\("PATIENT REPORT".localized)"
        self.tabBarController?.title = "\("PATIENT REPORT".localized)"
        self.tabBarController?.navigationItem.title = "\("PATIENT REPORT".localized)"
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.hidesBackButton = true
        
        createCustomTopView()
        
        
    }
    
    func getSelectedNoOfDays() -> String {
        
        
        switch segmentControl.selectedSegmentIndex {
        case HistoryDays.days_today:
            
            return "0"
        case HistoryDays.days_7:
            
            return "6"
        case HistoryDays.days_14:
            
            return "13"
        case HistoryDays.days_30:
            
            return "29"
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
      //  UserDefaults.standard.set(false, forKey:"NewReadEditBool")
      //  UserDefaults.standard.set(false, forKey:"MedEditBool")
      //  UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
      //  UserDefaults.standard.synchronize()
        setDefaultValue()
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
                
                self.medicationArray = NSMutableArray()
                self.readingArr = NSMutableArray()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    //print("JSON \(JSON)")
                    
                    self.summaryTxtArray.add(JSON.object(forKey: "name") as! String)
                    if self.selectedUserType == userType.doctor{
                        self.summaryTxtArray.add(JSON.object(forKey: "educatorName") as! String)}
                    else{
                        self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    }
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    print(jsonArr.count)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    //let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    //print(readingArr.count)
                    
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
                        
                        self.medicationArray.add(obj)
                    }
                    
                    self.addDefaultValue()
                    
                    let jsonArrRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    
                    
                    for data in jsonArrRead {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanFrequencyObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.goal = dict.value(forKey: "goal") as! String
                        obj.time = dict.value(forKey: "time") as! String
                        obj.frequency = dict.value(forKey: "frequency") as! String
                        
                        self.readingArr.add(obj)
                    }
                    
                    
                    self.addDefaultValueReading()
                    
                    self.dynamicEducatorViewLayout(medArrCount:(self.medicationArray.count), readingArrcount: self.readingArr.count , glucoseReadingCount:glucoseReadingArr.count)
                //    self.medicationTbl.reloadData()
                    SVProgressHUD.dismiss()
                }
                
                break
            case .failure:
                print("failure")
                self.medicationArray = NSMutableArray()
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
            "condition": "All conditions"
        ]
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getDoctorRequestReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                self.medicationArray = NSMutableArray()
                self.readingArr = NSMutableArray()
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    //print("JSON \(JSON)")
                    var reportStatus: Bool = false
                    
                    if let isApproved = JSON.object(forKey: "isReportApproved"){
                        if isApproved as! Bool == true
                        {
                            reportStatus = true
                        }
                    }
                    
                    if let isDeclined = JSON.object(forKey: "isReportDeclined"){
                        if isDeclined as! Bool == true
                        {
                            reportStatus = true
                        }
                    }
                   /* if(isApproved == true || isDeclined == true){
                        reportStatus = true
                    }*/
                    self.summaryTxtArray.add(JSON.object(forKey: "name") as! String)
                    
                    if let tempEduName = JSON.object(forKey: "educatorsName"){
                         self.summaryTxtArray.add(tempEduName as! String)
                    }
                    else
                    {
                         self.summaryTxtArray.add("")
                    }
                   
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    UserDefaults.standard.setValue(JSON.object(forKey: "patientID") as! String, forKey: userDefaults.selectedPatientID);
                    
                   
                    var comment : String = "";
                    
                    if self.selectedUserType == userType.doctor{
                        let arr : NSArray = JSON.object(forKey: "educatorComment") as! NSArray
                        comment = arr.object(at: 0) as! String
                    }
                    else if self.selectedUserType == userType.educator{
                        let arr : NSArray = JSON.object(forKey: "commentsByDoctor") as! NSArray
                        comment = arr.object(at: 0) as! String
                    }
                    
                    self.doctorCommentTextView.text = comment
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "currentMedication") as! NSArray)
                    let jsonArrNewMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "newMedication") as! NSArray)
                    let jsonArrUpdateMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedMedication") as! NSArray)
                    let jsonArrDeleteNewMed : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "deletedMedication") as! NSArray)
                    
                    
                    if reportStatus{
                        self.approveLabel.isHidden = true
                        self.declineLabel.isHidden = true
                    }
                    
                    if jsonArr.count > 0 {
                        self.medicationArray.removeAllObjects()
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
                            self.medicationArray.add(obj)
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
                            for i in 0..<self.medicationArray.count {
                                let objCarPlan = (self.medicationArray[i] as? CarePlanObj)!
                                if(objCarPlan.id ==  obj.id )
                                {
                                    self.medicationArray.replaceObject(at: i, with: obj)
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
                            if let timingArray: NSArray = dict.value(forKey: "timing") as? NSArray{
                                for timing in timingArray{
                                    let tempDict: NSDictionary = timing as! NSDictionary
                                    obj.dosage.append(tempDict.value(forKey:"dosage") as! Int)
                                    obj.condition.append(tempDict.value(forKey:"condition") as! String)
                                }
                            }
                            self.medicationArray.add(obj)
                        }
                    }
                    
                    //Delete Medication Data From the cashe
              
                    for data1 in jsonArrDeleteNewMed{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "id") as! String
                        for i in 0..<self.medicationArray.count {
                            let objCarPlan = (self.medicationArray[i] as? CarePlanObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.medicationArray.remove(objCarPlan)
                                break
                            }
                        }
                    }
                    
                    
                   // let jsonNewArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedMedication") as! NSArray)
                    //let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    
                    let updateReadingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedReading") as! NSArray)
                    
                    
                    let jsonArrRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "currentReading") as! NSArray)
                    
                    let jsonArrUpdatedRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedReading") as! NSArray)
                    let jsonArrNewRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "newReading") as! NSArray)
                    let jsonArrDeleteNewRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "deletedReading") as! NSArray)
                    
                    if jsonArrRead.count > 0 {
                        self.readingArr.removeAllObjects()
                        for data in jsonArrRead {
                            let dict: NSDictionary = data as! NSDictionary
                            let obj = CarePlanFrequencyObj()
                            obj.id = dict.value(forKey: "_id") as! String
                            obj.goal = dict.value(forKey: "goal") as! String
                            obj.time = dict.value(forKey: "time") as! String
                            obj.frequency = dict.value(forKey: "frequency") as! String
                            
                            self.readingArr.add(obj)
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
                            
                            
                            
                            for i in 0..<self.readingArr.count {
                                let objCarPlan = (self.readingArr[i] as? CarePlanFrequencyObj)!
                                if(objCarPlan.id == obj.id )
                                {
                                    self.readingArr.replaceObject(at: i, with: obj)
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
                            
                            self.readingArr.add(obj)
                        }
                    }
                    
                    //Delete Medication Data From the cashe
                    
                    for data1 in jsonArrDeleteNewRead{
                        let dict: NSDictionary = data1 as! NSDictionary
                        let obj = CarePlanFrequencyObj()
                        obj.id = dict.value(forKey: "id") as! String
                        for i in 0..<self.readingArr.count {
                            let objCarPlan = (self.readingArr[i] as? CarePlanFrequencyObj)!
                            if(objCarPlan.id ==  obj.id )
                            {
                                self.readingArr.remove(objCarPlan)
                                break
                            }
                        }
                    }
                    
                    
                    if updateReadingArr.count == 0 {
                        self.sections = 1
                    }
                
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    
                    self.addDefaultValue()
                    self.addDefaultValueReading()
                    
                    print(jsonArr.count)
                    self.dynamicDoctorViewLayout(medArrCount:(self.medicationArray.count), readingArrcount:self.readingArr.count , updateReadingCount: updateReadingArr.count , glucoseReadingCount: glucoseReadingArr.count)
                 //   self.medicationTbl.reloadData()
                    
                    
                }
                
                break
            case .failure:
                print("failure")
                self.medicationArray = NSMutableArray()
                self.readingArr = NSMutableArray()
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
     
        Alamofire.request("\(baseUrl)\(ApiMethods.getDoctorGroupReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                self.medicationArray = NSMutableArray()
                self.readingArr = NSMutableArray()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    self.summaryTxtArray.add(JSON.object(forKey: "patientName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    print(jsonArr.count)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)
                    //let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    print(self.readingArr.count)
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
                     
                        self.medicationArray.add(obj)
                    }
                    
                    self.addDefaultValue()
                    
                    let jsonArrRead : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    
                    
                    for data in jsonArrRead {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanFrequencyObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.goal = dict.value(forKey: "goal") as! String
                        obj.time = dict.value(forKey: "time") as! String
                        obj.frequency = dict.value(forKey: "frequency") as! String
                        
                        self.readingArr.add(obj)
                    }
                    
                    self.addDefaultValueReading()

                    self.dynamicEducatorDoctorViewLayout(medArrCount:(self.medicationArray.count), readingArrcount: self.readingArr.count, glucoseReadingCount:glucoseReadingArr.count)
                   // self.medicationTbl.reloadData()
                    SVProgressHUD.dismiss()
                }
                
                break
            case .failure:
                print("failure")
                self.medicationArray = NSMutableArray()
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
            //let updateMedData = try JSONSerialization.data(withJSONObject: editCurrentMedArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            //Convert back to string. Usually only do this for debugging
            //let updateMedJSONString : String  = String(data: updateMedData, encoding: String.Encoding.utf8)!
            //let updateReadData = try JSONSerialization.data(withJSONObject: editCurrentReadArray, options: JSONSerialization.WritingOptions.prettyPrinted)
            //Convert back to string. Usually only do this for debugging
            
            let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let educatorID = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)! as String
            let recepientTypes = UserDefaults.standard.array(forKey: userDefaults.recipientTypesArray)! as NSArray
            let recepientIDs = UserDefaults.standard.array(forKey: userDefaults.recipientIDArray)! as NSArray
            
            var doctorID : String = ""
            
            if(recepientTypes.contains("doctor")){
                doctorID = recepientIDs[recepientTypes.index(of: "doctor")] as! String
            }
            
            if let badgeCounter = Int(UserDefaults.standard.value(forKey: userDefaults.totalBadgeCounter) as! String){
                totalBadgeCounter = badgeCounter
            }
            else{
                totalBadgeCounter = 0
            }
            
            var commentFromEducator : String = ""
            if educatorCommentTxtViw.text == "Please add comments to justify your decision".localized
            {
                commentFromEducator = ""
            }
            else{
                commentFromEducator = educatorCommentTxtViw.text
            }
            let parameters: Parameters = [
                "patientid": patientsID,
                "educatorid":educatorID,
                "doctorid": doctorID,
                "isApproved": false,
                "isDeclined" :false,
                "updatedmeds" : editCurrentMedArray,
                "deletedmeds" : deleteNewCurrentMedArray,
                "newmedadd": addNewCurrentMedArray,
                "updatedread" : editCurrentReadArray,
                "newreadarray":addNewCurrentReadArray,
                "readdeleted":deleteNewCurrentReadArray,
                "comment" : commentFromEducator,
                // "action":actionSegment,
                "hcNumber": "",
                "hba":"",
                "badgeCounter": totalBadgeCounter
            ]
           // \(baseUrl)\(ApiMethods.saveEducatorReport)
            Alamofire.request("\(baseUrl)\(ApiMethods.saveEducatorReport)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
           
                
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    
                    SVProgressHUD.dismiss()
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentEditMedicationArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentAddMedicationArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "updateReadingCareArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentAddNewMedicationArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentDeleteReadingArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentAddReadingArray")
                    UserDefaults.standard.setValue(NSArray(), forKey: "currentEditReadingCareArray")
                    UserDefaults.standard.synchronize()

                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print("JSON \(JSON)")
                        let status : String = JSON.value(forKey: "message") as! String
                        if status == "Success" {
                            let alert = UIAlertController(title:"Message".localized, message: "Request sent to doctor".localized, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction)in
                                //self.popToViewController()
                                self.navigationController?.popViewController(animated: true)
                            }) )
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            self.present(UtilityClass.displayAlertMessage(message:status, title: "Message".localized), animated: true, completion: nil)
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
                
                
                
                for i in 0..<self.readingArr.count {
                    let objCarPlan = (self.readingArr[i] as? CarePlanFrequencyObj)!
                    if(objCarPlan.id ==  obj.id )
                    {
                        self.readingArr.replaceObject(at: i, with: obj)
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
                
                self.readingArr.add(obj)
            }
        }
        
        //Delete Medication Data From the cashe
        
        let arrDelete : NSArray = UserDefaults.standard.array(forKey: "currentDeleteReadingArray")! as [Any] as NSArray
        let jsonArrDeleteNewRead = NSMutableArray(array: arrDelete)
        
        for data1 in jsonArrDeleteNewRead{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanFrequencyObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.readingArr.count {
                let objCarPlan = (self.readingArr[i] as? CarePlanFrequencyObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.readingArr.remove(objCarPlan)
                    break
                }
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
            for i in 0..<self.medicationArray.count {
                let objCarPlan = (self.medicationArray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.medicationArray.replaceObject(at: i, with: obj)
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
            self.medicationArray.add(obj)
        }
        
        //Delete Medication Data From the cache
        let tempDeleteArray : NSArray = UserDefaults.standard.array(forKey: "currentDeleteMedicationArray")! as [Any] as NSArray
        let deleteMedArray = NSMutableArray(array: tempDeleteArray)
        for data1 in deleteMedArray{
            let dict: NSDictionary = data1 as! NSDictionary
            let obj = CarePlanObj()
            obj.id = dict.value(forKey: "id") as! String
            for i in 0..<self.medicationArray.count {
                let objCarPlan = (self.medicationArray[i] as? CarePlanObj)!
                if(objCarPlan.id ==  obj.id )
                {
                    self.medicationArray.remove(objCarPlan)
                    break
                }
            }
        }
    }
    func calculateMedHeight() -> CGFloat
    {
        var medHeight = 0
        for i in 0..<self.medicationArray.count {
            if let obj: CarePlanObj = self.medicationArray[i] as? CarePlanObj {
                let addHeight = (obj.dosage.count-1) * 45
                medHeight = Int(CGFloat(medHeight) +  CGFloat(105 + addHeight))
            }
            else
            {
                medHeight = medHeight +  105
            }
        }
        
        return CGFloat(medHeight)
    }
     // MARK: - Dynamic  Constraints Methods
    func dynamicEducatorDoctorViewLayout(medArrCount : Int , readingArrcount: Int , glucoseReadingCount : Int)
    {
        if medArrCount > 0 {
            self.medicationHeight =  Int(CGFloat(self.calculateMedHeight() + 49))
        }
        else {
            self.medicationHeight =  49
        }
        
        if readingArrcount > 0{
            self.readingViewHeight = ((readingArrcount * 50) + 140)
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }
        else {
            self.readingViewHeight = 45
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }
        
        educatorViewHeightConstraint.constant = 0.0
        
        self.doctorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant + 8)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorActionView.frame.origin.y + doctorActionView.frame.size.height)
        print( doctorActionView.frame.origin.y)
        self.setViewExpanable()
    }
    
    func dynamicEducatorViewLayout(medArrCount : Int , readingArrcount: Int , glucoseReadingCount : Int)
    {
        if medArrCount > 0 {
            self.medicationHeight =  Int(CGFloat(self.calculateMedHeight() + 49))
        }
        else {
             self.medicationHeight = 49
        }
        self.vwMedicationContainer.updateConstraintsIfNeeded()
        
        if readingArrcount > 0{
           
            self.readingViewHeight = Int((readingArrcount * 50) + 140)
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }
        else {
            self.readingViewHeight = 45
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }
        
        self.educatorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant + 10)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: educatorActionView.frame.origin.y + educatorActionView.frame.size.height)
        print( educatorActionView.frame.origin.y)
         self.setViewExpanable()
    }
    
    
    func dynamicDoctorViewLayout(medArrCount : Int , readingArrcount: Int , updateReadingCount : Int, glucoseReadingCount : Int)
    {
        if medArrCount > 0 {
            self.medicationHeight =  Int(CGFloat(self.calculateMedHeight() + 49))
        
        }
        else {
                 self.medicationHeight =  49
        }
        if readingArrcount == 0 {
            self.readingViewHeight = 45
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }
        else  {
            self.readingViewHeight = ((readingArrcount * 50) + 140)
            newReadingContainerHeight.constant = 0.0
            newRedEditConstraint.constant = 0.0
        }

        educatorViewHeightConstraint.constant = 0.0
        
        self.doctorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant + 8)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorActionView.frame.origin.y + doctorActionView.frame.size.height)
        print( doctorActionView.frame.origin.y)
         self.setViewExpanable()
        
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
