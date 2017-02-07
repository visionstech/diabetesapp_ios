//
//  RequestViewController.swift
//  DiabetesApp
//
//  Created by User on 1/20/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SDWebImage

class RequestViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    var userTypeString = String()
    var requestListArray = NSMutableArray()
    
    var selectedPatientID: String = ""
    
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
        
        let obj = requestListArray[indexPath.row] as! RequestObject
        
        
        if selectedUserType == userType.doctor {
            cell.lblDoctorEductor.text = "Educator:"
            cell.lblEducator.text = obj.educatorName
        }
        if selectedUserType == userType.educator {
            cell.lblDoctorEductor.text = "Doctor:"
            cell.lblEducator.text = obj.doctorName
        }
        
        let imagePath = "http://54.212.229.198:3000/upload/" + selectedPatientID + "image.jpg"
        let manager:SDWebImageManager = SDWebImageManager.shared()
        
        manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                              options: SDWebImageOptions.highPriority,
                              progress: nil,
                              completed: {[weak self] (image, error, cached, finished, url) in
                                if (error == nil && (image != nil) && finished) {
                                    
                                    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width/2
                                    cell.userImageView.clipsToBounds = true
                                    cell.userImageView.image = image
                                }
        })
        
        cell.lbPatientName.text = obj.patientName
        
        cell.lblTime.text = obj.time
        cell.lblRequestStatus.text = obj.status
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        
        return cell;
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let reqObj =  requestListArray.object(at: indexPath.row) as! RequestObject
        
        let viewController: ReportViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.ReportViewController) as! ReportViewController
       // viewController.taskID = reqObj.taskid
        
        UserDefaults.standard.set(false, forKey:userDefaults.groupChat)
        UserDefaults.standard.set(reqObj.taskid, forKey:userDefaults.taskID)
        UserDefaults.standard.set(reqObj.patientid, forKey: userDefaults.selectedPatientID)
        UserDefaults.standard.synchronize()
        
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    func getRequestTask() {
        //         SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: 
        
            let userID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
            let parameters: Parameters = [
                "usertype": userTypeString,
                "userid": userID
            ]
            
            print(parameters)
            
            
            SVProgressHUD.show(withStatus: "Loading requests".localized)
           // Alamofire.request("\(baseUrl)\(ApiMethods.getTasks)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
         Alamofire.request("\(baseUrl)\(ApiMethods.getTasks)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in

                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    //                    SVProgressHUD.dismiss()
                    
                   // if let JSON: NSArray = response.result.value! as? NSArray {
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary{
                        self.requestListArray .removeAllObjects()
                            print("JSON \(JSON)")
                            //for data in JSON {
                        if  let jsonArray :  NSArray = JSON.value(forKey: "taskList") as? NSArray{
                            for data in jsonArray {
                                let dict: NSDictionary = data as! NSDictionary
                                let requestObj = RequestObject()
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
                                requestObj.patientid = (dict.value(forKey: "patientid") as? String)!
                                self.selectedPatientID = dict.value(forKey: "patientid") as! String
                                self.requestListArray.add(requestObj)
                            }
                        }
                            self.tableView.reloadData()
                        
                        }
                        SVProgressHUD.dismiss()
                    break
                case .failure:
                    //                    SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                    print("failure")
                    
                    break
                    
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
