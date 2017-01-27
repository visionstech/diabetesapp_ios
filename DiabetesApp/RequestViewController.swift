//
//  RequestViewController.swift
//  DiabetesApp
//
//  Created by IOS2 on 1/13/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class RequestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
 let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var userTypeString = String()
    var requestListArray = NSMutableArray()
    
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
     
       
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNavBarUI()
        
        if selectedUserType == userType.doctor {
            userTypeString = "Doctor"
        }
        if selectedUserType == userType.educator {
            userTypeString = "Educator"
        }
         getRequestTask()
    }
    
    // MARK: - Custom Methods
    func setNavBarUI(){
        
        self.title = "\("Requests".localized)"
        self.tabBarController?.title = "\("Requests".localized)"
        self.tabBarController?.navigationItem.title = "\("Requests".localized)"
        self.parent?.navigationItem.leftBarButtonItem = nil
        self.parent?.navigationItem.rightBarButtonItems = nil
        self.parent?.navigationItem.hidesBackButton = true
        
        
        //createCustomTopView()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     return requestListArray.count
    }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell: RequestTableViewCell = tableView.dequeueReusableCell(withIdentifier: "requestCell")! as! RequestTableViewCell
    
       let obj = requestListArray[indexPath.row] as! ReqestObject
    
    if selectedUserType == userType.doctor {
        cell.lblDoctorEductor.text = "Educator"
         cell.lblEducator.text = obj.educatorName
    }
    if selectedUserType == userType.educator {
        cell.lblDoctorEductor.text = "Doctor"
         cell.lblEducator.text = obj.doctorName
    }
    
      cell.lbPatientName.text = obj.patientName
    
      cell.lblTime.text = obj.time
      cell.lblRequestStatus.text = obj.status
    
      cell.accessoryType = .disclosureIndicator
      cell.selectionStyle = .none
    
    
    return cell;
    
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let reqObj =  requestListArray.object(at: indexPath.row) as! ReqestObject
        
        let viewController: ReportViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.ReportViewController) as! ReportViewController
        viewController.taskID = reqObj.taskid
        UserDefaults.standard.set(false, forKey:"groupChat")
        UserDefaults.standard.set(reqObj.taskid, forKey: "taskID")
        UserDefaults.standard.synchronize()

        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    func getRequestTask() {
//         SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        if  UserDefaults.standard.string(forKey: userDefaults.selectedPatientID) != nil {
           
            
            let userID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
            let parameters: Parameters = [
                "usertype": userTypeString,
                "userid": userID,
               
            ]
            
            print(parameters)
            
            
            
            Alamofire.request("\(baseUrl)\(ApiMethods.getTasks)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
                
                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
//                    SVProgressHUD.dismiss()
                    print(response.result.value!)
                    
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                       self.requestListArray .removeAllObjects()
                        print("JSON \(JSON)")
                        if  let jsonArray :  NSArray = JSON.value(forKey: "taskList") as? NSArray{
                        for data in jsonArray {
                            let dict: NSDictionary = data as! NSDictionary
                            let requestObj = ReqestObject()
                            requestObj.date = dict.value(forKey: "date") as! String
                            if self.selectedUserType == userType.doctor {
                                requestObj.educatorName = dict.value(forKey: "educatorName") as! String
                            }
                            else if self.selectedUserType == userType.educator {
                                requestObj.doctorName = dict.value(forKey: "doctorName") as! String
                            }
                            requestObj.patientName = dict.value(forKey: "patientName") as! String
                            requestObj.taskid = dict.value(forKey: "taskid") as! String
                            requestObj.time =   dict.value(forKey: "time") as! String
                            requestObj.status =   dict.value(forKey: "status") as! String
                            self.requestListArray.add(requestObj)
                         }
                        }
                        self.tableView.reloadData()
                        
                    }
                    
                    break
                case .failure:
//                    SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                    print("failure")
                    
                    break
                    
                }
            }
        }
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
