//
//  ReportCarePlanController.swift
//  DiabetesApp
//
//  Created by IOS3 on 16/01/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import  Alamofire

 let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
class ReportCarePlanController: UIViewController , UITableViewDelegate, UITableViewDataSource , UITextFieldDelegate {
    
    @IBOutlet weak var tblView: UITableView!
    var selectedIndex = Int()
    var selectedIndexPath = IndexPath()
    var array = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        addNotifications()
         if selectedUserType == userType.doctor {
            getDoctorReadingsData()
         } else{
           getReadingsData()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.readingNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
    }
     //MARK: - textfield  Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.accessibilityValue == "goal" {
            let selectedIndex : Int = Int(textField.accessibilityLabel!)!
            let mainDict: NSMutableDictionary = array[textField.tag] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
            obj.goal  = ((resultString) as NSString) as String
            itemsArray.replaceObject(at:textField.tag, with: obj)
            let mSectioDict = (array[textField.tag] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
         array.replaceObject(at:textField.tag, with: sectionsDict)

        }
        else {
            let selectedIndex : Int = Int(textField.accessibilityLabel!)!
            let mainDict: NSMutableDictionary = array[textField.tag] as! NSMutableDictionary
            let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
            let obj: CarePlanReadingObj = itemsArray[selectedIndex] as! CarePlanReadingObj
            let str: NSString = NSString(string: textField.text!)
            let resultString: String = str.replacingCharacters(in: range, with:string)
            obj.frequency  = ((resultString) as NSString) as String
            itemsArray.replaceObject(at:textField.tag, with: obj)
            let mSectioDict = (array[textField.tag] as AnyObject) as! NSDictionary
            let sectionsDict = NSMutableDictionary(dictionary:mSectioDict)
            array.replaceObject(at: textField.tag, with: sectionsDict)

        }

       
      return true
    }

    //MARK: - Notifications Methods
    func readingNotification(notification: NSNotification) {
        
    }
    
    // MARK: - Api Methods
    func getReadingsData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            
            
          //  let patientsID: String? = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "patientid": "58563eb4d9c776ad70491b7b",
                "educatorid":"58563eb4d9c776ad70491b97",
                "numDaysBack": "1",
                "condition": "All conditions"
            ]
            
            print(parameters)
            
            Alamofire.request("http://54.212.229.198:3000/geteducatorreport", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print(JSON)
                        let arr  = NSMutableArray(array: JSON.object(forKey: "readingsTime")as! NSArray)
                        self.array.removeAllObjects()
                        for time in frequnecyArray {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            mainDict.setValue(String(describing: time), forKey: "frequency")
                            let itemsArray: NSMutableArray = NSMutableArray()
                            for data in arr {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj = CarePlanReadingObj()
                                obj.id = dict.value(forKey: "_id") as! String
                                // Between
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                //obj.goal = dict.value(forKey: "goal") as! String
                                obj.time = dict.value(forKey: "time") as! String
                                obj.frequency = dict.value(forKey: "frequency") as! String
                                print(String(describing: time))
                               if String(describing: time) == obj.time {
                                    itemsArray.add(obj)
                               }
                            }
                            
                            if itemsArray.count > 0{
//                                for i : Int in 0 ..< itemsArray.count {
                                mainDict.setObject(itemsArray, forKey: "data" as NSCopying)
                                self.array.add(mainDict)
                              // }
                            }
                            
                        }
                        
                        print(self.array)
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
    
    func getDoctorReadingsData() {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
            
            
            //  let patientsID: String? = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
            let parameters: Parameters = [
                "taskid": "5878ce306e4778515545c6dc",
                "patientid": "58563eb4d9c776ad70491b7b",
                "numDaysBack": "1",
                "condition": "All conditions"
            ]
            print(parameters)
            
            Alamofire.request("http://54.212.229.198:3000/getdoctorreport", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print(response)
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                        print(JSON)
                        let arr  = NSMutableArray(array: JSON.object(forKey: "readingsTime")as! NSArray)
                        self.array.removeAllObjects()
                        for time in frequnecyArray {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            mainDict.setValue(String(describing: time), forKey: "frequency")
                            let itemsArray: NSMutableArray = NSMutableArray()
                            for data in arr {
                                let dict: NSDictionary = data as! NSDictionary
                                let obj = CarePlanReadingObj()
                                obj.id = dict.value(forKey: "_id") as! String
                                // Between
                                let goalStr: String = dict.value(forKey: "goal") as! String
                                obj.goal = goalStr.replacingOccurrences(of: "Between ", with: "")
                                //obj.goal = dict.value(forKey: "goal") as! String
                                obj.time = dict.value(forKey: "time") as! String
                                obj.frequency = dict.value(forKey: "frequency") as! String
                                print(String(describing: time))
                                if String(describing: time) == obj.time {
                                    itemsArray.add(obj)
                                }
                            }
                            
                            if itemsArray.count > 0{
                                //                                for i : Int in 0 ..< itemsArray.count {
                                mainDict.setObject(itemsArray, forKey: "data" as NSCopying)
                                self.array.add(mainDict)
                                // }
                            }
                            
                        }
                        
                        print(self.array)
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
        let mainDict: NSMutableDictionary = array[section] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        
        return itemsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let mainDict: NSMutableDictionary = array[indexPath.section] as! NSMutableDictionary
        let itemsArray: NSMutableArray = mainDict.object(forKey: "data") as! NSMutableArray
        let cell : ReportCarePlanReadingViewCell = tableView.dequeueReusableCell(withIdentifier: "readingsCell")! as! ReportCarePlanReadingViewCell
        cell.selectionStyle = .none
        cell.tag = indexPath.row
        if selectedUserType == userType.doctor {
            cell.goalLbl.isUserInteractionEnabled = false
            cell.conditionLbl.isUserInteractionEnabled = false
        }
        else {
            cell.goalLbl.isUserInteractionEnabled = true
            cell.conditionLbl.isUserInteractionEnabled = true
        }
        cell.goalLbl.delegate = self
        if let obj: CarePlanReadingObj = itemsArray[indexPath.row] as? CarePlanReadingObj {
            cell.goalLbl.tag = indexPath.section
            cell.goalLbl.accessibilityLabel = "\(indexPath.row)"
            cell.goalLbl.accessibilityValue = "goal"
            cell.goalLbl.text = obj.goal
            cell.conditionLbl.text = obj.frequency
            cell.conditionLbl.tag = indexPath.section
            cell.conditionLbl.accessibilityLabel = "\(indexPath.row)"
            cell.conditionLbl.accessibilityValue = "Condition"
            cell.numberLbl.text = "\(indexPath.row+1)."
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell : CarePlanReadingHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "headerCell")! as! CarePlanReadingHeaderTableViewCell
        let mainDict: NSMutableDictionary = array[section] as! NSMutableDictionary
        cell.frequencyLbl.text = String(mainDict.value(forKey: "frequency") as! String)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
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
