//
//  CarePlanReadingViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 03/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire

class CarePlanReadingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    
    var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        getReadingsData()
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
    
    // MARK: - Api Methods
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
        
        let cell : CarePlanReadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! CarePlanReadingTableViewCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        if let obj: CarePlanReadingObj = array[indexPath.row] as? CarePlanReadingObj {
            cell.goalLbl.text = obj.goal
            cell.conditionLbl.text = obj.frequency
            cell.frequencyLbl.text = obj.time
            cell.numberLbl.text = "\(indexPath.row+1)."
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 140
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
