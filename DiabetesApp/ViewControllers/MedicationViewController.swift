//
//  MedicationViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire

class MedicationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    
    var array = NSMutableArray()
    
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
        getMedicationsData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
    }
    
    //MARK: - Custom Methods
    func resetUI() {
        if self.array.count > 0 {
            tblView.isHidden = false
        }
        else {
            
            tblView.isHidden = true
        }
    }
    
    func addNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.medicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.medicationView), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addMedicationNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.addMedication), object: nil)
    }
    
    //MARK: - Notifications Methods
    func medicationNotification(notification: NSNotification) {
        
    }
    
    func addMedicationNotification(notification: NSNotification) {
        
        let editViewController: EditMedicationViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.editMedicationViewController) as! EditMedicationViewController
        editViewController.selectedObj = CarePlanObj()
        editViewController.isEditMode = false
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
    
    // MARK: - IBAction Methods
    @IBAction func EditMedication_Click(_ sender: Any) {
        
        let index: Int = (sender as AnyObject).tag
        if let obj: CarePlanObj = array[index] as? CarePlanObj {
            print(obj)
            let editViewController: EditMedicationViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.editMedicationViewController) as! EditMedicationViewController
            editViewController.selectedObj = obj
            editViewController.isEditMode = true
            self.navigationController?.pushViewController(editViewController, animated: true)
            
        }
        
    }
    
    @IBAction func DeleteMedication_Click(_ sender: Any) {
        
        let index: Int = (sender as AnyObject).tag
        array.removeObject(at: index)
        tblView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        for i in index..<array.count {
            self.tblView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
        }
        
        self.resetUI()
        
    }
    
    // MARK: - Api Methods
    func getMedicationsData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
//            "userid": patientsID
            "userid": "58563eb4d9c776ad70491b7b"
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getcareplan)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let JSON: NSArray = response.result.value as? NSArray {
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                        
                        obj.dosage = String(describing: dict.value(forKey: "dosage"))
                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.array.add(obj)
                    }
                }
                self.tblView.reloadData()
                self.resetUI()
                
                break
            case .failure:
                print("failure")
                self.tblView.reloadData()
                self.resetUI()
                
                break
                
            }
        }
       
     }
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell")! as! CarePlanMedicationTableViewCell
        cell.selectionStyle = .none
        cell.isUserInteractionEnabled = true
        cell.tag = indexPath.row
        cell.editBtn.tag = indexPath.row
        cell.deleteBtn.tag = indexPath.row
        
        if selectedUserType == userType.patient {
            cell.editBtn.isHidden = true
            cell.editBtn.isUserInteractionEnabled = false
            cell.deleteBtn.isHidden = true
            cell.deleteBtn.isUserInteractionEnabled = false
        }
        else {
            cell.editBtn.isHidden = false
            cell.editBtn.isUserInteractionEnabled = true
            
            if selectedUserType == userType.doctor {
                cell.deleteBtn.isHidden = false
                cell.deleteBtn.isUserInteractionEnabled = true
            }
            else {
                cell.deleteBtn.isHidden = true
                cell.deleteBtn.isUserInteractionEnabled = false
            }
            
        }
        
        if let obj: CarePlanObj = array[indexPath.row] as? CarePlanObj {
            cell.medNameLbl.text = obj.name.capitalized
            cell.dosageTxtFld.text = obj.dosage
            cell.frequencyTxtFld.text = obj.frequency
            
        }
        return cell
        
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 210
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
