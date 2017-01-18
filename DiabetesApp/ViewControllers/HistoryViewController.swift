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
    @IBOutlet weak var noHistoryAvailableLbl: UILabel!
    
    @IBOutlet var pickerViewContainer: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK:- Var
    var sectionsArray = NSMutableArray()
    var boolArray = NSMutableArray()
    var noOfDays = "1"
    
    var obj = NSDictionary()
    var cellArray = NSArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "READING_HISTORY".localized
        self.setUI()
        //self.addNotifications()
        //getHistory()
        conditionTxtFld.text = conditionsArray[0] as! String
        getReadingHistory(condition: conditionsArray[0] as! String)
    }
    override func viewDidAppear(_ animated: Bool) {
           self.addNotifications()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
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
        
       
    }
    
    func resetUI() {
        if self.sectionsArray.count > 0 {
            tblView.isHidden = false
            noHistoryAvailableLbl.isHidden = true
        }
        else {
            
            tblView.isHidden = true
            noHistoryAvailableLbl.isHidden = false
        }
    }
    
    func addNotifications() {
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.listViewNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.listHistoryView), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.noOfDaysNotification(notification:)), name: NSNotification.Name(rawValue: Notifications.noOfDays), object: nil)
    }
    
    func refreshSelectedSections(section: Int) {
        
        var value: Bool =  self.boolArray [section] as! Bool
        if value == true {
            value = false
        }
        else {
            value = true
        }
        boolArray.replaceObject(at: section, with: value)
//        print("section \(section)")
//        var count = 0
//        for bool in boolArray {
//            let value: Bool
//            if count == section {
//                value = true
//            }
//            else {
//                value = false
//            }
//            boolArray.replaceObject(at: count, with: value)
//            count += 1
//        }
        
        //self.tblView.reloadSections(IndexSet(integer: section ), with: .automatic)
         self.tblView.reloadData()
    }
    
    
    //MARK: - Notifications Methods
    func listViewNotification(notification: NSNotification) {
        
    }
    
    func noOfDaysNotification(notification: NSNotification) {
       
        noOfDays = String(describing: notification.value(forKey: "object")!)
         print("noOfDays \(noOfDays)")
        //getHistory()
        getReadingHistory(condition: conditionTxtFld.text!)
        
    }
    
    //MARK: - ToolBarButtons Methods
    @IBAction func ToolBarButtons_Click(_ sender: Any) {
        self.view.endEditing(true)
        if (sender as AnyObject).tag == 0 {
            
            conditionTxtFld.text = conditionsArray[pickerView.selectedRow(inComponent: 0)] as? String
            // Api Method
            getReadingHistory(condition: conditionTxtFld.text!)
            //getHistory()
        }
    }
    
    func getHistory(){
        
        sectionsArray.removeAllObjects()
        let historyData: NSDictionary = NSDictionary(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "history", ofType: "plist")!) as URL)!
        
         print(historyData)
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
        
       // print("count \(sectionsArray.count)")
        
        for _ in sectionsArray {
            boolArray.add(false)
        }
        
        tblView.reloadData()
    }
    
    
    //MARK: - Api Methods
    func getReadingHistory(condition: String) {
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
        sectionsArray.removeAllObjects()
        boolArray.removeAllObjects()
        
       let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
        let parameters: Parameters = [
            "userid": patientsID,
             "numDaysBack": noOfDays,
             "condition": condition
        ]
        
        print(parameters)
        
        Alamofire.request("http://54.212.229.198:3000/\(ApiMethods.getglucoseDaysCondition)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    print("JSON \(JSON)")
                    
                    if self.conditionTxtFld.text == String(conditionsArray[0] as! String) {
                        let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                        if mainArray.count != 0 {
                        self.sectionsArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                        }
                    }
                    else {
                        
                        let mainArray: NSArray = NSMutableArray(array: JSON.object(forKey: "objectArray") as! NSArray)
                        if mainArray.count != 0 {
                            let mainDict: NSMutableDictionary = NSMutableDictionary()
                            var count = 0
                            let itemsArray = NSMutableArray()
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
                                
                                count += 1
                            }
                            mainDict.setObject(itemsArray.copy(), forKey: "items" as NSCopying)
                            self.sectionsArray.add(mainDict)
                        }
                    }
                    
                    for _ in self.sectionsArray {
                        self.boolArray.add(false)
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
             let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
             let array: NSArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
             return array.count
            
        }
        
       // return (bool == true ? 4 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict: NSDictionary = sectionsArray[indexPath.section] as! NSDictionary
       
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let dateStr: String = String(describing: dict.allKeys.first!)
            cellArray = NSArray(array: dict.object(forKey: dateStr) as! NSArray)
            obj = cellArray[indexPath.row] as! NSDictionary
        }
        else {
            cellArray = NSArray(array: dict.object(forKey: "items" as NSCopying)! as! NSArray).copy() as! NSArray
            obj = cellArray[indexPath.row] as! NSDictionary
        }
        
        let cell: HistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "historyCell")! as! HistoryTableViewCell
        cell.readingLbl.text = "\(obj.value(forKey: "reading")!) mg/dl"
        cell.dateLbl.text = String(describing: obj.value(forKey: "created")!)
        cell.conditionLbl.text = String(describing: obj.value(forKey: "condition")!)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let arr =  cellArray .object(at: indexPath.row)
        
        let dict =   arr as! NSDictionary
        
        //print("\(dict.value(forKey: "reading")!) mg/dl")
        self.present(UtilityClass.displayAlertMessage(message: "\(dict.value(forKey: "reading")!) mg/dl".localized, title: ""), animated: true, completion: nil)
        
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
        let lbl: UILabel = UILabel(frame: CGRect(x: 40, y: 5, width: tableView.frame.size.width-80, height: 35))
        let dict: NSDictionary = NSDictionary(dictionary: sectionsArray[section] as! NSDictionary)
        
        lbl.textColor = UIColor.white
        lbl.font = Fonts.HistoryHeaderFont
        headerView.addSubview(topView)
        headerView.addSubview(lbl)
        headerView.tag = section
        
        
        if conditionTxtFld.text == String(conditionsArray[0] as! String) {
            let dateStr: String = String(describing: dict.allKeys.first!)
            lbl.text = dateStr
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapHeader(gestureReconizer:)))
            headerView.addGestureRecognizer(tapGesture)
             var arrowImgView =  UIImageView()
            if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
                
                 arrowImgView = UIImageView(frame: CGRect(x:17 , y: 14, width: 17, height: 17))
                headerView.addSubview(arrowImgView)
            }
            else {
                
                 arrowImgView = UIImageView(frame: CGRect(x:headerView.frame.size.width-27 , y: 14, width: 17, height: 17))
                headerView.addSubview(arrowImgView)
            }
            
            
            
            let bool : Bool = boolArray[section] as! Bool
            if bool == true {
                
               
                let bottomView: UIView = UIView(frame: CGRect(x: 0, y: 35, width: tableView.frame.size.width, height: 10))
                bottomView.backgroundColor = Colors.historyHeaderColor
                headerView.addSubview(bottomView)
                
                arrowImgView.image = UIImage(named: "collapseArrow")
                
            }
            else {
                arrowImgView.image = UIImage(named: "expandArrow")
            }
        }
        else {
            if  dict["end_date"] != nil {
            
            lbl.text = "\(String(describing: dict.value(forKey: "start_date")!)) - \(String(describing: dict.value(forKey: "end_date")!))"
            }
            else {
                 lbl.text = "\(String(describing: dict.value(forKey: "start_date")!))"
            }
            
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
