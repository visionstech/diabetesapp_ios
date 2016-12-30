//
//  CarePlanViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 26/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire

class CarePlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet weak var notAvailableLbl: UILabel!
    
    var array = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
            notAvailableLbl.text = "No \((segmentControl.selectedSegmentIndex == 0 ? "Medications" : "Readings")) Available."
            
        }
    }
    
    // MARK: - Segment Control Methods
    @IBAction func SegmentControl_ValueChanged(_ sender: Any) {
       
        array.removeAllObjects()
        self.resetUI()
        (segmentControl.selectedSegmentIndex == 0 ? getMedicationsData() : getReadingsData())
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
                        self.array.add(obj)
                    }
                    
                    print(self.array)
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
    
    func getReadingsData() {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            //"userid": patientsID
         "userid": "58563eb4d9c776ad70491b7b"
            
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getcareplanReadings)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print(response)
            
            switch response.result {
            case .success:
                print("Validation Successful")
                if let JSON: NSArray = response.result.value as? NSArray {
                    print(JSON)
                    for data in JSON {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanReadingObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.goal = dict.value(forKey: "goal") as! String
                        obj.time = dict.value(forKey: "time") as! String
                        obj.frequency = dict.value(forKey: "frequency") as! String
                        self.array.add(obj)
                    }
                    
                    print(self.array)
                    self.tblView.reloadData()
                    self.resetUI()
                }
                break
                
            case .failure:
                print("failure")
                
                break
                
            }
        }
        tblView.reloadData()
        
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentControl.selectedSegmentIndex == 0 {
            let cell : CarePlanMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "medicationCell")! as! CarePlanMedicationTableViewCell
            if let obj: CarePlanObj = array[indexPath.row] as? CarePlanObj {
                cell.medNameLbl.text = obj.name.capitalized
                cell.dosageTxtFld.text = obj.dosage
                cell.frequencyTxtFld.text = obj.frequency
            }
            
            return cell
        }
        
        else {
            
            let cell : CarePlanReadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! CarePlanReadingTableViewCell
            if let obj: CarePlanReadingObj = array[indexPath.row] as? CarePlanReadingObj {
                cell.conditionTxtFld.text = obj.goal
                cell.goalTxtFld.text = obj.time
                cell.frequencyTxtFld.text = obj.frequency
                cell.numberLbl.text = "\(indexPath.row+1)."
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return (segmentControl.selectedSegmentIndex == 0 ? 210 : 174)
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
