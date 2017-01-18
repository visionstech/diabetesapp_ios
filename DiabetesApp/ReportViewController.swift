//
//  ReportViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 1/13/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
class ReportViewController: UIViewController , UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var medicationTbl: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var summaryTbl: UITableView!

   
    
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
    @IBOutlet weak var chartBtn: UIButton!
    @IBOutlet weak var listViewContainer: UIView!
    @IBOutlet weak var chartViewContainer: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var topBackView:UIView = UIView()
    var summaryArray = NSArray()
    var summaryTxtArray = NSMutableArray()
    var medicationArray = NSMutableArray()
    var currentMedArray = NSArray()
    
      let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    override func awakeFromNib() {
        super.awakeFromNib()
        setNavBarUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.readingView), object: nil)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        summaryTbl.tableFooterView = UIView()
        summaryArray = ["Educator","Doctor","HC#","Diabetes"];
        
        scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2500)
        // Do any additional setup after loading the view.
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:Colors.outgoingMsgColor], for: .normal)
        segmentControl.setTitleTextAttributes([NSFontAttributeName: Fonts.noOfDaysFont, NSForegroundColorAttributeName:UIColor.white], for: .selected)
        getEducatorReportAPI()
        
    }
    override func viewDidLayoutSubviews() {
        
//        viewDidLayoutSubviews()
       
        scrollView.contentSize = CGSize(width:self.view.frame.size.width, height: 2500)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setNavBarUI()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        topBackView.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == summaryTbl {
             return summaryTxtArray.count
        }
        else {
            return medicationArray.count
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
   
//       let cell: SummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as! SummaryTableViewCell
        if tableView == summaryTbl {
        let cell: SummaryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "Summ", for:indexPath) as! SummaryTableViewCell
     
//        cell.tag = indexPath.row
        cell.nameTxtLbl.text = summaryArray.object(at: indexPath.row) as? String
        cell.ansTxtLbl.text  = summaryTxtArray.object(at: indexPath.row) as? String
        
        return cell
        }
        else {
            
             let cell: ReportMedicationTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MedicationCell", for:indexPath) as! ReportMedicationTableViewCell
            if indexPath.section == 0 {
                if let obj: CarePlanObj = medicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                    let dosageStr : String = obj.dosage as String
                    cell.dosageTxtFld.text = dosageStr
                    
                }
            }
            else {
                if let obj: CarePlanObj = medicationArray[indexPath.row] as? CarePlanObj {
                    cell.medNameLbl.text = obj.name.capitalized
                    let dosageStr : String = obj.dosage as String
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
       
        lbl.text = "New Medication"
        lbl.textColor = UIColor.white
        lbl.font = Fonts.HistoryHeaderFont
       
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
    
    //MARK: - SegmentControl Methods
    @IBAction func SegmentControl_ValueChange(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.noOfDays), object: getSelectedNoOfDays())
    }
    
    // MARK: - IBAction Methods
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
    
    func BackBtn_Click(){
        self.navigationController?.popViewController(animated: true)
    }
    func getEducatorReportAPI()  {
        
        let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
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
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    self.summaryTxtArray.removeAllObjects()
                    print("JSON \(JSON)")
                    self.summaryTxtArray.add(JSON.object(forKey: "educatorName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "dcotorsName") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "HCNumber") as! String)
                    self.summaryTxtArray.add(JSON.object(forKey: "diabetes") as! String)
                    self.summaryTbl.reloadData()
                    
                    let jsonArr : NSMutableArray = NSMutableArray(array:JSON.object(forKey: "medication") as! NSArray)
                    for data in jsonArr {
                        let dict: NSDictionary = data as! NSDictionary
                        let obj = CarePlanObj()
                        obj.id = dict.value(forKey: "_id") as! String
                        obj.name = dict.value(forKey: "name") as! String
                       
                        
                        let timingArray : NSMutableArray = NSMutableArray(array: (data as AnyObject).object(forKey: "timing") as! NSArray)
                       
                            let timedict:NSDictionary = timingArray[0] as! NSDictionary
                            obj.dosage = String(describing: timedict.value(forKey: "dosage"))
                            
//                        obj.frequency = String(describing: dict.value(forKey: "frequency"))
                        self.medicationArray.add(obj)
                    }
                  self.medicationTbl.reloadData()
                    
                    
                }
                
                break
            case .failure:
                print("failure")
                
                break
                
            }
        }

    }
    
    
}
