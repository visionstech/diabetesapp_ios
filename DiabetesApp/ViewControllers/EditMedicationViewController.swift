//
//  EditMedicationViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class EditMedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addMedicineView: UIView!
    @IBOutlet weak var addMedicineBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var array = NSMutableArray()
    var selectedFreqCellIndex = 0
    var selectedObj: CarePlanObj = CarePlanObj()
    var isEditMode: Bool = false
    var topBackView:UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
       // setUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func setUI(){
       
        self.tabBarController?.navigationItem.title = "\("CARE_PLAN".localized)"
        self.title = "\("CARE_PLAN".localized)"
        
        // for Patient Login
        self.tabBarController?.navigationItem.hidesBackButton = true
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        self.tabBarController?.navigationItem.leftBarButtonItem = nil
        
        // for doctor login
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        createCustomTopView()
        
        self.setCorners(view: addMedicineView, createShadow: true)
        self.setCorners(view: saveBtn, createShadow: true)
        self.setCorners(view: addMedicineBtn, createShadow: false)
        tblView.tableFooterView = UIView()
        
        addMedicineView.isHidden = true
        
        if isEditMode == true {
            displaySelectedMedicationData()
        }
        else {
            addMedicineObj()
        }
        
    }
    
    func setCorners(view: UIView, createShadow: Bool)
    {
        // Corner radius
        view.layer.cornerRadius = 8
        view.layer.cornerRadius = 8
        
        if createShadow == true {
            // Shadow on view
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOpacity = 0.5
            view.layer.shadowOffset = CGSize.zero
            view.layer.shadowRadius = 2
        }
    }
    
    func displaySelectedMedicationData() {
        if selectedObj != CarePlanObj() {
            
            array.add(selectedObj)
            tblView.reloadData()
        }
    }
    
    func addMedicineObj(){
        
        let obj = CarePlanObj()
        obj.id = ""
        obj.name = ""
        obj.dosage = ""
        obj.frequency = ""
        array.add(obj)
        
        tblView.insertRows(at: [IndexPath(row: array.count-1, section: 0) as IndexPath], with: .none)
        tblView.scrollToRow(at: IndexPath(row: array.count-1, section: 0) as IndexPath, at: UITableViewScrollPosition.bottom, animated: true)
    }
    
    //MARK: - ToolBarButtons Methods
    @IBAction func ToolBarBtns_Click(_ sender: Any) {
        self.view.endEditing(true)
        if (sender as AnyObject).tag == 0 {
        
          let obj: CarePlanObj = array[selectedFreqCellIndex] as! CarePlanObj
            
            if let cell: CarePlanMedicationTableViewCell = tblView.cellForRow(at: IndexPath(row: selectedFreqCellIndex, section: 0)) as? CarePlanMedicationTableViewCell {
                
                cell.frequencyTxtFld.text = (frequnecyArray[pickerView.selectedRow(inComponent: 0)] as? String)?.localized
                obj.frequency = ((frequnecyArray[pickerView.selectedRow(inComponent: 0)] as? String)?.localized)!
                array.replaceObject(at: selectedFreqCellIndex, with: obj)
                
            }
         
            
        }
    }
    
    // MARK: - IBAction Methods
    @IBAction func AddMedicine_Click(_ sender: Any) {
        addMedicineObj()
    }
    
    
    @IBAction func SaveBtn_Click(_ sender: Any) {
        let obj: CarePlanObj = array[0] as! CarePlanObj
        
        if obj.name.trimmingCharacters(in: CharacterSet.whitespaces).length == 0 {
            self.present(UtilityClass.displayAlertMessage(message: "Medicine Name Required.", title: ""), animated: true, completion: nil)
            return
        }
        
        else if obj.dosage.trimmingCharacters(in: CharacterSet.whitespaces).length == 0 {
            self.present(UtilityClass.displayAlertMessage(message: "Dosage Required.", title: ""), animated: true, completion: nil)
            return
        }
        
        else if obj.frequency.trimmingCharacters(in: CharacterSet.whitespaces).length == 0 {
            self.present(UtilityClass.displayAlertMessage(message: "Frequency Required.", title: ""), animated: true, completion: nil)
            return
        }
        
        else if obj.condition.trimmingCharacters(in: CharacterSet.whitespaces).length == 0 {
            self.present(UtilityClass.displayAlertMessage(message: "Condition Required.", title: ""), animated: true, completion: nil)
            return
        }
        
        if isEditMode == true {
            
            editMedication(medicationObj: obj)
        }
        else {
            addMedication(medicationObj: obj)
        }
    }

    func BackBtn_Click(){
        //self.tabBarController?.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Api Methods
    func addMedication(medicationObj: CarePlanObj) {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid"       : patientsID ,
            "medname"      : medicationObj.name ,
            "meddosage"    : medicationObj.dosage ,
            "medfreq"      : medicationObj.frequency ,
            "medcondition" : medicationObj.condition
        ]
        
        SVProgressHUD.show(withStatus: "Adding Medication...", maskType: SVProgressHUDMaskType.clear)
        Alamofire.request("\(baseUrl)\(ApiMethods.addcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            SVProgressHUD.dismiss()
            print(response)
            switch response.result {
            case .success:
                print("Validation Successful")
                self.present(UtilityClass.displayAlertMessage(message: response.result as! String , title: ""), animated: true, completion: nil)
               
                break
            case .failure:
                print("failure")
                self.present(UtilityClass.displayAlertMessage(message: "Error in adding medication. Please try again." , title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                break
                
            }
        }
    }
    
    func editMedication(medicationObj: CarePlanObj) {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid"       : patientsID ,
            "medid"        : medicationObj.id ,
            "medname"      : medicationObj.name ,
            "meddosage"    : medicationObj.dosage ,
            "medfreq"      : medicationObj.frequency ,
            "medcondition" : medicationObj.condition
        ]
        print("parameters \(parameters)")
        
        SVProgressHUD.show(withStatus: "Updating Medication...", maskType: SVProgressHUDMaskType.clear)
        Alamofire.request("\(baseUrl)\(ApiMethods.updatecareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            SVProgressHUD.dismiss()
            print(response)
            switch response.result {
            case .success:
                print("Validation Successful")
                self.present(UtilityClass.displayAlertMessage(message: response.result as! String , title: ""), animated: true, completion: nil)
                
                break
            case .failure:
                print("failure")
                self.present(UtilityClass.displayAlertMessage(message: "Error in adding medication. Please try again." , title: "Error"), animated: true, completion: nil)
                break
                
            }
        }
    }
    
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj: CarePlanObj = array[indexPath.row] as! CarePlanObj
        
        let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell") as! CarePlanMedicationTableViewCell
        cell.selectionStyle = .none
        cell.frequencyTxtFld.inputView = pickerViewContainer
        
        cell.conditionTxtFld.tag = indexPath.row
        cell.medicineNameTxtFld?.tag = indexPath.row
        cell.dosageTxtFld.tag = indexPath.row
        cell.frequencyTxtFld.tag = indexPath.row
        
        cell.medicineNameTxtFld?.text = String(obj.name)
        cell.conditionTxtFld.text = String(obj.condition)
        cell.dosageTxtFld.text = String(obj.dosage)
        cell.frequencyTxtFld.text = String(obj.frequency)
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 202
    }
    
    // MARK: - TextField Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        selectedFreqCellIndex = textField.tag
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

          let obj: CarePlanObj = array[textField.tag] as! CarePlanObj
        
          let str: NSString = NSString(string: textField.text!)
          let resultString: String = str.replacingCharacters(in: range, with:string)
        
        if let cell: CarePlanMedicationTableViewCell = tblView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as? CarePlanMedicationTableViewCell {
            
            if textField == cell.medicineNameTxtFld {
                obj.name = resultString
            }
            else if textField == cell.dosageTxtFld {
                obj.dosage = resultString
            }
            else if textField == cell.conditionTxtFld {
                obj.condition = resultString
            }
            
            array.replaceObject(at: textField.tag, with: obj)
        }
    
        
        return true
    }
    
    
    //MARK:- PickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return frequnecyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return frequnecyArray[row] as? String
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
