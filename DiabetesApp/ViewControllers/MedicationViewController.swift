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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setNavBarUI()
        getMedicationsData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func setNavBarUI(){
        
        let editBtn: UIBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItem = editBtn
    }
    
    // MARK: - IBAction Methods
    @IBAction func AddBtn_Click(_ sender: Any) {
        let editViewController: EditMedicationViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.editMedicationViewController) as! EditMedicationViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(editViewController, animated: true)
    }
    
    
    @IBAction func EditMedication_Click(_ sender: Any) {
        
        let index: Int = (sender as AnyObject).tag
        if let obj: CarePlanObj = array[index] as? CarePlanObj {
            obj.isSelected = true
            array.replaceObject(at: index, with: obj)
            tblView.reloadRows(at: [IndexPath(row: index, section: 0) as IndexPath], with: .none)
        }
        
    }
    
    // MARK: - Api Methods
    func getMedicationsData() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid": patientsID
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
                        obj.dosage = String(describing: dict.value(forKey: "dosage")!)
                        obj.frequency = String(describing: dict.value(forKey: "frequency")!)
                        obj.isSelected = false
                        self.array.add(obj)
                    }
                    
                    self.tblView.reloadData()
                    self.resetUI()
                }
                
                break
            case .failure:
                print("failure")
                
                break
                
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
        if let obj: CarePlanObj = array[indexPath.row] as? CarePlanObj {
            cell.medNameLbl.text = obj.name.capitalized
            cell.dosageTxtFld.text = obj.dosage
            cell.frequencyTxtFld.text = obj.frequency
            
            if obj.isSelected == true {
                cell.dosageTxtFld.isEnabled = true
                cell.frequencyTxtFld.isEnabled = true
                cell.conditionTxtFld.isEnabled = true
                cell.dosageTxtFld.layer.borderColor = UIColor.gray.cgColor
                cell.conditionTxtFld.layer.borderColor = UIColor.gray.cgColor
                cell.frequencyTxtFld.layer.borderColor = UIColor.gray.cgColor
                
            }
            else {
                cell.dosageTxtFld.isEnabled = false
                cell.frequencyTxtFld.isEnabled = false
                cell.conditionTxtFld.isEnabled = false
                cell.dosageTxtFld.layer.borderColor = UIColor.clear.cgColor
                cell.conditionTxtFld.layer.borderColor = UIColor.clear.cgColor
                cell.frequencyTxtFld.layer.borderColor = UIColor.clear.cgColor
            }
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
