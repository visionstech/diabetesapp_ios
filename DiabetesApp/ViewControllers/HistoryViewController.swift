//
//  HistoryViewController.swift
//  DiabetesApp
//
//  Created by IOS4 on 26/12/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import Alamofire

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK:- Outlets
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var conditionView: UIView!
    @IBOutlet weak var conditionTxtFld: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK:- Var
    var sectionsArray = NSMutableArray()
    var boolArray = NSMutableArray()
    var conditionsArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Reading History"
        conditionsArray = ["All Conditions","Fasting","Post lunch","Bedtime"]
        self.setUI()
        getHistory()
        //getReadingHistory()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Custom Methods
    func setUI() {
        conditionView.layer.cornerRadius = 5
        conditionView.layer.borderColor = UIColor.lightGray.cgColor
        conditionView.layer.borderWidth = 1
        
        conditionTxtFld.inputView = pickerViewContainer
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.listViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: nil)
    }
    
    func refreshSelectedSections(section: Int) {
        print("section \(section)")
        var count = 0
        for bool in boolArray {
            let value: Bool
            if count == section {
                value = true
            }
            else {
                value = false
            }
            boolArray.replaceObject(at: count, with: value)
            count += 1
        }
        
        //self.tblView.reloadSections(IndexSet(integer: section ), with: .automatic)
         self.tblView.reloadData()
    }
    
    func getSelectedNoOfDays() -> NSString {
        
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
            return ""
        }

    }
    
    //MARK: - Notifications Methods
    func listViewNotification(notification: NSNotification) {
        
    }

    
    //MARK: - SegmentControl Methods
    @IBAction func SegmentControl_ValueChanged(_ sender: Any) {
        getReadingHistory(noOfDays: getSelectedNoOfDays() as String, condition: conditionTxtFld.text!)
    }
    
    //MARK: - ToolBarButtons Methods
    @IBAction func ToolBarButtons_Click(_ sender: Any) {
        self.view.endEditing(true)
        if (sender as AnyObject).tag == 0 {
            
            conditionTxtFld.text = conditionsArray[pickerView.selectedRow(inComponent: 0)] as! String
            // Api Method
            //getReadingHistory(noOfDays: getSelectedNoOfDays() as String, condition: conditionTxtFld.text!)
            getHistory()
        }
    }
    
    func getHistory(){
        
        sectionsArray.removeAllObjects()
        let historyData: NSDictionary = NSDictionary(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "history", ofType: "plist")!) as URL)!
        
         print(sectionsArray)
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            sectionsArray = NSMutableArray(array: historyData.object(forKey: "objectArray") as! NSArray)
        }
        else {
            
            let mainArray: NSArray = NSMutableArray(array: historyData.object(forKey: "objectArray") as! NSArray)
            let mainDict: NSMutableDictionary = NSMutableDictionary()
            var count = 0
            var itemsArray = NSMutableArray()
            for dict in mainArray {
                let obj: NSDictionary = dict as! NSDictionary
                let dateStr: String = String(describing: obj.allKeys.first!)
                if count == 0 {
                    mainDict.setValue(dateStr, forKey: "start_date")
                }
                else if count == mainArray.count-1 {
                    mainDict.setValue(dateStr, forKey: "end_date")
                }
                let array: NSArray = NSArray(array: (dict as AnyObject).object(forKey: dateStr) as! NSArray)
                itemsArray.addObjects(from: array as! [Any])
//                for dataObj in array {
//                    let dataDict: NSDictionary = dataObj as! NSDictionary
//                    
//
//                }
                count += 1
            }
            mainDict.setObject(itemsArray.copy(), forKey: "items" as NSCopying)
            sectionsArray.add(mainDict)
        }
        
        print("count \(sectionsArray.count)")
        
        for _ in sectionsArray {
            boolArray.add(false)
        }
        
        tblView.reloadData()
    }
    
    
    //MARK: - Api Methods
    func getReadingHistory(noOfDays: String , condition: String) {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid": patientsID,
             "numDaysBack": noOfDays
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getglucoseDays)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful \(response)")
            switch response.result {
                
            case .success:
                
//                if let JSON: NSArray = response.result.value as? NSArray {
//                    for data in JSON {
//                        let dict: NSDictionary = data as! NSDictionary
//                        let obj = CarePlanObj()
//                        obj.id = dict.value(forKey: "_id") as! String
//                        obj.name = dict.value(forKey: "name") as! String
//                        obj.dosage = String(describing: dict.value(forKey: "dosage")!)
//                        obj.frequency = String(describing: dict.value(forKey: "frequency")!)
//                        self.array.add(obj)
//                    }
//                    
//                    print(self.array)
//                    self.tblView.reloadData()
//                }
                
                break
            case .failure:
                print("failure")
                
                break
                
            }
        }
        
    }

    
   //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let bool : Bool = boolArray[section] as! Bool
            if bool == true {
                
                let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
                let dateStr: String = String(describing: dict.allKeys.first!)
                let array: NSArray = NSArray(array: dict.object(forKey: dateStr) as! NSArray)
                
                return array.count
            }
            else {
                return 0
            }
        }
        
        else {
             let dict: NSMutableDictionary = NSMutableDictionary(dictionary: sectionsArray[section] as! NSMutableDictionary)
             let array: NSArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
             return array.count
            
        }
        
       // return (bool == true ? 4 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict: NSMutableDictionary = NSMutableDictionary(dictionary: sectionsArray[indexPath.section] as! NSMutableDictionary)
        let obj: NSDictionary
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let dateStr: String = String(describing: dict.allKeys.first!)
            let array: NSArray = NSArray(array: dict.object(forKey: dateStr) as! NSArray)
            obj = array[indexPath.row] as! NSDictionary
        }
        else {
            let array: NSArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
            obj = array[indexPath.row] as! NSDictionary
        }
        
        let cell: HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell")! as! HistoryTableViewCell
        cell.readingLbl.text = "\(obj.value(forKey: "reading") as! String) mg/dl"
        cell.dateLbl.text = String(describing: obj.value(forKey: "created")!)
        cell.conditionLbl.text = String(describing: obj.value(forKey: "condition")!)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        headerView.backgroundColor = UIColor.clear
        let topView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 45))
        topView.backgroundColor = Colors.historyHeaderColor
//        topView.layer.shadowColor = UIColor.black.cgColor
//        topView.layer.shadowOpacity = 1
//        topView.layer.shadowOffset = CGSize.zero
//        topView.layer.shadowRadius = 10
//        topView.layer.masksToBounds = true
        topView.layer.cornerRadius = 10
        let lbl: UILabel = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width-20, height: 35))
        let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
        
        lbl.textColor = UIColor.white
        headerView.addSubview(topView)
        headerView.addSubview(lbl)
        headerView.tag = section
        
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let dateStr: String = String(describing: dict.allKeys.first!)
            lbl.text = dateStr
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureReconizer:)))
            headerView.addGestureRecognizer(tapGesture)
            
            let bool : Bool = boolArray[section] as! Bool
            if bool == true {
                let bottomView: UIView = UIView(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 10))
                bottomView.backgroundColor = Colors.historyHeaderColor
                headerView.addSubview(bottomView)
            }
        }
        else {
            lbl.text = "\(String(describing: dict.value(forKey: "start_date")!)) - \(String(describing: dict.value(forKey: "end_date")!))"
            
            let bottomView: UIView = UIView(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 10))
            bottomView.backgroundColor = Colors.historyHeaderColor
            headerView.addSubview(bottomView)
        }
        
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    //MARK: - Header Tap Gesture
    func tapHeader(gestureReconizer: UITapGestureRecognizer){
        
        if gestureReconizer.view != nil {
         
            self.refreshSelectedSections(section: (gestureReconizer.view?.tag)!)
            
        }
    }
    
   //MARK:- PickerView Delegate Methods
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return conditionsArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return conditionsArray[row] as? String
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
