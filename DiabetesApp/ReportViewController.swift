//
//  ReportViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 1/13/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class ReportViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UITextFieldDelegate{
    
    @IBOutlet weak var newReadingEditView: UIView!
    @IBOutlet weak var medicationView: UIView!
    @IBOutlet weak var medicationTbl: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var medicationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var readingScheduleView: UIView!
    @IBOutlet weak var newReadingContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var glucoseReadingView: UIView!
    @IBOutlet weak var educatorCommentTxtViw: UITextView!
    
    @IBOutlet weak var currentReadingView: UIView!
    @IBOutlet weak var readNewEdit: UIButton!
    @IBOutlet weak var currentReadEdit: UIButton!
    @IBOutlet weak var currentMedEdit: UIButton!
    @IBOutlet weak var glucoseReadingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var educatorViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentReadingContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var readingScheduleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var summaryTbl: UITableView!
    @IBOutlet weak var newRedEditConstraint: NSLayoutConstraint!

    @IBOutlet weak var doctorCommentTextView: UITextView!
    @IBOutlet weak var doctorActionViewHeight: NSLayoutConstraint!
   
    @IBOutlet weak var educatorActionView: UIView!
    
    @IBOutlet weak var educatorActionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var doctorAcionView: UIView!
    var editButton: UIButton!
        /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Outlets
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var newReadingViewContainer: UIView!
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var chartBtn: UIButton!
    @IBOutlet weak var listViewContainer: UIView!
    @IBOutlet weak var chartViewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var topBackView:UIView = UIView()
    var summaryArray = NSArray()
    var summaryTxtArray = NSMutableArray()
    var medicationArray = NSMutableArray()
    var newMedicationArray = NSMutableArray()
    var currentMedEditBool = Bool()
    var editCurrentMedDict = NSDictionary()
    var editCurrentMedArray = NSMutableArray()
    var editCurrentReadArray = NSArray()
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if selectedUserType == userType.doctor {
            doctorReportAPI()
            
            educatorActionViewHeight.constant = 0
           let rect = CGRect(x: 0, y: 0, width: 100, height: educatorActionViewHeight.constant)
            educatorActionView.frame = rect
            educatorActionView.isHidden = true
            newReadingViewContainer.isHidden = false
            self.currentMedEdit.isHidden = true
            self.readNewEdit.isHidden = false
            self.currentReadEdit.isHidden = true
            self.readNewEdit.isHidden = false
            lbl.isHidden = false
            
        }
        else {
            getEducatorReportAPI()
           
            doctorActionViewHeight.constant = 0
            let rect = CGRect(x: 0, y: 0, width: 100, height: doctorActionViewHeight.constant)
            doctorAcionView.frame = rect
            doctorAcionView.isHidden = true
            newReadingViewContainer.isHidden = true
            self.currentMedEdit.isHidden = false
            self.readNewEdit.isHidden = true
            self.currentReadEdit.isHidden = false
            self.readNewEdit.isHidden = true
            lbl.isHidden = true

        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        summaryTbl.tableFooterView = UIView()
        summaryArray = ["Educator","Doctor","HC#","Diabetes"];
        
       // scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2900)
        // Do any additional setup after loading the view.
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:Colors.outgoingMsgColor], for: .normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
       
        
    }
    override func viewDidLayoutSubviews() {
        
//        viewDidLayoutSubviews()
       
        //scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2900)
    }
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        editCurrentMedArray.removeAllObjects()
        UserDefaults.standard.set(false, forKey:"CurrentReadEditBool")
        UserDefaults.standard.set(NSArray(), forKey:"currentEditReadingArray")
        UserDefaults.standard.set(false, forKey: "NewReadEditBool")
        UserDefaults.standard.synchronize()

        setNavBarUI()
        
//        if selectedUserType == userType.doctor {
//                self.readNewEdit.isHidden = true
//                self.currentReadEdit.isHidden = false
//                self.currentMedEdit.isHidden = false
//        }
//        else {
//           
//                self.readNewEdit.isHidden = false
//                self.currentReadEdit.isHidden = true
//                self.currentMedEdit.isHidden = true
//        }

    }
    // MARK: - IBAction Methods
    @IBAction func sendRequestToDoctor(_ sender: Any) {
        
    editEducatorReportAPI()
        
    }
    @IBAction func currentMedEditActon(_ sender: UIButton) {
        if currentMedEdit.titleLabel!.text == "Edit" {
          
            currentMedEditBool = true
            currentMedEdit.setTitle("Done", for: .normal)
            
        }
        else {
            currentMedEditBool = false
            self.view.endEditing(true)
            currentMedEdit.setTitle("Edit", for: .normal)
        }
        print(editCurrentMedArray)
        medicationTbl.reloadData()
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

    
    
    @IBAction func currentReadEditAction(_ sender: UIButton) {
        if currentReadEdit.titleLabel!.text == "Edit" {
            UserDefaults.standard.set(true, forKey: "CurrentReadEditBool")
            
            currentReadEdit.setTitle("Done", for: .normal)
            
        }
        else {
            UserDefaults.standard.set(false, forKey: "CurrentReadEditBool")
            let defaults = UserDefaults.standard
            editCurrentReadArray = defaults.array(forKey: "currentEditReadingArray")! as [Any] as NSArray
            print("readArray\(editCurrentReadArray)")
            
            currentReadEdit.setTitle("Edit", for: .normal)
           
        }
     UserDefaults.standard.synchronize()
     NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
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
    @IBAction func ViewModeButtons_Click(_ sender: UIButton) {
        
        if sender.backgroundColor == Colors.historyHeaderColor {
            return
        }
        else {
            
            if sender == listBtn {
                listBtn.setTitleColor(UIColor.white, for: .normal)
                chartBtn.setTitleColor(UIColor.gray, for: .normal)
                
                listBtn.backgroundColor = Colors.historyHeaderColor
                chartBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = false
                chartViewContainer.isHidden = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportListHistoryView), object: nil)
                
            }
            else {
                
                chartBtn.setTitleColor(UIColor.white, for: .normal)
                listBtn.setTitleColor(UIColor.gray, for: .normal)
                
                chartBtn.backgroundColor = Colors.historyHeaderColor
                listBtn.backgroundColor = UIColor.white
                
                listViewContainer.isHidden = true
                chartViewContainer.isHidden = false
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.ReportChartHistoryView), object: nil)
                
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
        obj.dosage  = ((resultString) as NSString) as String
        newMedicationArray.replaceObject(at:textField.tag, with: obj)
        print("obj.answer\(obj.dosage)")
        return true
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
            obj.dosage  = ((resultString) as NSString) as String
            medicationArray.replaceObject(at:textField.tag, with: obj)
//            let mainDict: NSMutableDictionary = NSMutableDictionary()
//            mainDict.setValue(obj.id, forKey: "id")
//            mainDict.setValue(obj.name, forKey: "name")
//            mainDict.setValue(obj.dosage, forKey: "dosage")
//            editCurrentMedArray.add(mainDict)
            print("obj.answer\(obj.dosage)")
            return true

        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if selectedUserType == userType.doctor {
            let obj: CarePlanObj = newMedicationArray[textField.tag] as! CarePlanObj
            obj.dosage  = ((textField.text!) as NSString) as String
            newMedicationArray.replaceObject(at:textField.tag, with: obj)
            print("obj.answer\(obj.dosage)")
           
        }
        else
        {
            let obj: CarePlanObj = medicationArray[textField.tag] as! CarePlanObj
            obj.dosage  = ((textField.text!) as NSString) as String
            medicationArray.replaceObject(at:textField.tag, with: obj)
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            mainDict.setValue(obj.id, forKey: "id")
            mainDict.setValue(obj.name, forKey: "name")
            mainDict.setValue(obj.dosage, forKey: "dosage")
            if self.editCurrentMedArray.count > 0 {
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

            print("obj.answer\(obj.dosage)")
            
            
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
            return 36
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
          if selectedUserType == userType.doctor {
            return 2
        }
          else {
        return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   

        if tableView == summaryTbl {
        let cell: SummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Summ", for:indexPath) as! SummaryTableViewCell
        cell.nameTxtLbl.text = summaryArray.object(at: indexPath.row) as? String
        cell.ansTxtLbl.text  = summaryTxtArray.object(at: indexPath.row) as? String
        
        return cell
        }
        else {
            
    let cell: ReportMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for:indexPath) as! ReportMedicationTableViewCell

            
            if selectedUserType == userType.doctor {
                if currentMedEditBool {
               
                if indexPath.section == 0 {
                    cell.dosageTxtFld.isUserInteractionEnabled = false
                }
                else {
                     cell.dosageTxtFld.isUserInteractionEnabled = true
                }
                }
                else {
                    
                    if indexPath.section == 0 {
                        cell.dosageTxtFld.isUserInteractionEnabled = false
                    }
                    else {
                        cell.dosageTxtFld.isUserInteractionEnabled = false
                    }

                }
               
            }
            else {
                
                if currentMedEditBool {
                if indexPath.section == 0 {
                    cell.dosageTxtFld.isUserInteractionEnabled = true
                }
                else {
                    cell.dosageTxtFld.isUserInteractionEnabled = false
                }
                }
                else {
                    if indexPath.section == 0 {
                        cell.dosageTxtFld.isUserInteractionEnabled = false
                    }
                    else {
                        cell.dosageTxtFld.isUserInteractionEnabled = false
                    }

                    
                }

            }
                    cell.selectionStyle = .none
                    cell.dosageTxtFld.delegate = self
                    cell.dosageTxtFld.keyboardType = UIKeyboardType.numberPad
            
            if indexPath.section == 0 {
                if let obj: CarePlanObj = medicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                    let dosageStr  = obj.dosage
                    cell.dosageTxtFld.text = dosageStr
                    cell.dosageTxtFld.tag = indexPath.row
                    
                }
            }
            else {
                if let obj: CarePlanObj = newMedicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                    let dosageStr : String = obj.dosage
                    cell.dosageTxtFld.tag = indexPath.row
                    cell.dosageTxtFld.text = dosageStr
                    
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
    
    func getSelectedNoOfDays() -> String {
        
        
        switch segmentControl.selectedSegmentIndex {
        case HistoryDays.days_today:
          
            return "1"
        case HistoryDays.days_7:
            
            return "7"
        case HistoryDays.days_14:
           
            return "14"
        case HistoryDays.days_30:
           
            return "30"
        default:
            return "1"
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
    // MARK: - Doctor And Educator Report API Methods
    func getEducatorReportAPI()  {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
       // let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "patientid": "58563eb4d9c776ad70491b7b",
            "educatorid":"58563eb4d9c776ad70491b97",
            "numDaysBack": getSelectedNoOfDays(),
            "condition": "All conditions"
        ]

        Alamofire.request("http://54.212.229.198:3000/geteducatorreport", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    print("JSON \(JSON)")
                    self.summaryTxtArray.add(JSON.object(forKey: "educatorName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)

                    let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    print(readingArr.count)
                    for data in jsonArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                       
                        self.dynamicEducatorViewLayout(medArrCount:jsonArr.count, readingArrcount: readingArr.count , glucoseReadingCount:glucoseReadingArr.count)
                        
                        let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                       
                            let timedict:NSDictionary = timingArray[0] as! NSDictionary
                            obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                            
//                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.medicationArray.add(obj)
                    }
                  self.medicationTbl.reloadData()
                    
                    
                }
                
                break
            case .failure:
                print("failure")
                 SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
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

            print("MedJSONString\(updateMedJSONString)")
            print("ReadJSONString\(updateReadJSONString)")
                
                
                
                let parameters: Parameters = [
                    "patientID": "58563eb4d9c776ad70491b7b",
                    "educatorID":"58563eb4d9c776ad70491b97",
                    "doctorID": "58563eb4d9c776ad70491b95",
                    "isApproved": false,
                    "isDeclined" :false,
                    "updatedMedication" : updateMedJSONString,
                    "updatedReading" : updateReadJSONString,
                    "comment" : educatorCommentTxtViw.text,
                    "action":"No change",
                    "hcNumber": "ffrtrtrtr@23423",
                    "hba1c":""
            ]
            print("Parameters \(parameters)")

        Alamofire.request("http://54.212.229.198:3000/savetask", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                  
                    print("JSON \(JSON)")
                    
                    
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

    // DoctorReport Api
    
    func doctorReportAPI() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        print(getSelectedNoOfDays())
        let parameters: Parameters = [
            "taskid": "5878ce306e4778515545c6dc",
            "patientid": "58563eb4d9c776ad70491b7b",
            "numDaysBack": "30",
            "condition": "Post Lunch"
        ]
        print(parameters)
        
        Alamofire.request("http://54.212.229.198:3000/getdoctorreport", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                SVProgressHUD.dismiss()
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    print("JSON \(JSON)")
                    self.summaryTxtArray.add(JSON.object(forKey: "name") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let arr : NSArray = JSON.object(forKey: "educatorComment") as! NSArray
                    self.doctorCommentTextView.text = arr.object(at: 0) as! String
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                
                    if jsonArr.count > 0 {
                        self.medicationArray.removeAllObjects()
                    for data in jsonArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        
                        
                        let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                        
                        let timedict:NSDictionary = timingArray[0] as! NSDictionary
                        obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                        
                        //                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.medicationArray.add(obj)
                      }
                    }
                    
                    let jsonNewArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedMedication") as! NSArray)
                    let readingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "readingsTime") as! NSArray)
                    let updateReadingArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "updatedReading") as! NSArray)
                    let objectArray : NSDictionary = NSDictionary(dictionary: JSON.object(forKey: "glucoseReadings") as! NSDictionary)
                    let glucoseReadingArr: NSArray = NSMutableArray(array: objectArray.object(forKey: "objectArray") as! NSArray)

                    print(jsonNewArr.count , jsonArr.count)
                    self.dynamicDoctorViewLayout(medArrCount:jsonArr.count + jsonNewArr.count , readingArrcount:readingArr.count , updateReadingCount: updateReadingArr.count , glucoseReadingCount: glucoseReadingArr.count)
                   
                    if jsonNewArr.count > 0 {
                    for data in jsonNewArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        
                        
                        let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                        
                        let timedict:NSDictionary = timingArray[0] as! NSDictionary
                        obj.dosage = String(describing: timedict.value(forKey: "dosage")!)
                        
                        //                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.newMedicationArray.add(obj)
                     }
                    }
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
      // MARK: - Dynamic  Constraints Methods
    func dynamicEducatorViewLayout(medArrCount : Int , readingArrcount: Int , glucoseReadingCount : Int)
    {
//        glucoseReadingLayoutConstraint.constant = CGFloat((glucoseReadingCount * 60) + 200)
//        self.medicationView.setY(y:glucoseReadingView.frame.origin.y + glucoseReadingLayoutConstraint.constant)
        self.medicationViewHeight.constant = CGFloat((medArrCount * 63) + 49)
        self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
        currentReadingContainerHeight.constant   = CGFloat((readingArrcount * 160)) ;
        newReadingContainerHeight.constant = 0.0
        newRedEditConstraint.constant = 0.0
        readingScheduleHeightConstraint.constant = CGFloat((readingArrcount * 160)) ;
        self.educatorActionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: educatorActionView.frame.origin.y + educatorActionView.frame.size.height)
        print( educatorActionView.frame.origin.y)
    }
    func dynamicDoctorViewLayout(medArrCount : Int , readingArrcount: Int , updateReadingCount : Int, glucoseReadingCount : Int)
    {
//        glucoseReadingLayoutConstraint.constant = CGFloat((glucoseReadingCount * 60) + 200)
//        self.medicationView.setY(y:glucoseReadingView.frame.origin.y + glucoseReadingLayoutConstraint.constant)
        self.medicationViewHeight.constant = CGFloat((medArrCount * 63) + 98)
        self.readingScheduleView.setY(y: self.medicationView.frame.origin.y +  self.medicationViewHeight.constant)
        currentReadingContainerHeight.constant   = CGFloat((readingArrcount * 160) + 50) ;
        newReadingContainerHeight.constant = CGFloat((updateReadingCount * 160)) ;
        readingScheduleHeightConstraint.constant = CGFloat((readingArrcount * 160) + 50 + Int(newReadingContainerHeight.constant));
        educatorViewHeightConstraint.constant = 0.0
        self.doctorAcionView.setY(y: readingScheduleView.frame.origin.y + readingScheduleHeightConstraint.constant)
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: doctorAcionView.frame.origin.y + doctorAcionView.frame.size.height)
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
