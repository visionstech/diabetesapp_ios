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
    
    var totalBadgeCounter =  Int()

    
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
        //self.parent?.navigationItem.leftBarButtonItem = nil
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
            cell.lblDoctorEductor.text = "Educator:".localized
            cell.lblEducator.text = obj.educatorName
        }
        if selectedUserType == userType.educator {
            cell.lblDoctorEductor.text = "Doctor:".localized
            cell.lblEducator.text = obj.doctorName
        }
        // TODO generalize this URL to the new public ip
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
        
        if obj.status == "Accepted".localized{
            cell.lblRequestStatus.text = obj.status
            cell.lblRequestStatus.textColor = Colors.approveButtonGreen
            
        }
        else if obj.status == "Declined".localized{
            cell.lblRequestStatus.text = obj.status
            cell.lblRequestStatus.textColor = UIColor.red
            
        }
        else if obj.status == "Single Report".localized{
            cell.lblRequestStatus.text = obj.status
            cell.lblRequestStatus.textColor = Colors.PrimaryColor
        }
        else {
            cell.lblRequestStatus.text = obj.status
            cell.lblRequestStatus.textColor = Colors.PrimaryColor
        }

        
        if selectedUserType == userType.doctor
        {
            if obj.status == "Accepted".localized{
                cell.backgroundColor = nil
            }
            else if obj.status == "Declined".localized{
                cell.backgroundColor = nil
            }
            else if obj.status == "Single Report".localized{
                cell.backgroundColor = nil
            }
            else {
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 248.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
        }
        else if selectedUserType == userType.educator{
           /* if obj.iseducatorin == false{
                cell.backgroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
            }
            else{
                cell.backgroundColor = nil
            }*/
           
            if obj.didDoctorComment == true && obj.iseducatorin{
                cell.backgroundColor = UIColor(red: 240.0/255.0, green: 248.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            else{
                cell.backgroundColor = nil
            }
            
            
        }
        
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
        
            let userID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
            var account = Account(name: userID)
            var tDate = ""
            var tokenVal = ""
            do {
            
                try account.fetchFromKeychain()
            
                if let token = account.accessToken {
                    tokenVal = token
                }
            
                if let taskDate = account.tDate {
                    tDate = taskDate
                }
            
            } catch {
                tDate = ""
                print(error)
            }

        
        
            let parameters: Parameters = [
                "usertype": userTypeString,
                "userid": userID,
                "lastUpdateDate":tDate
            ]
        
        
        
            var unreadCounter = 0
            var reloadTable : Bool = true
            print(parameters)
        
            print("Total Badge Counter")
            print(totalBadgeCounter)
           // if let badgeCounter = UserDefaults.standard.value(forKey: userDefaults.totalBadgeCounter) as! Int?{
             //   totalBadgeCounter = badgeCounter
           // }
           // else{
            //    totalBadgeCounter = 0
           // }
        
        
            SVProgressHUD.show(withStatus: "Loading requests".localized)
           // Alamofire.request("\(baseUrl)\(ApiMethods.getTasks)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
        //"\(baseUrl)\(ApiMethods.getTasks)
         Alamofire.request("\(baseUrl)\(ApiMethods.getTasks)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in

                print("Validation Successful ")
                
                switch response.result {
                    
                case .success:
                    if let JSON: NSDictionary = response.result.value! as? NSDictionary{
                        self.requestListArray .removeAllObjects()
                            print("JSON \(JSON)")
                            //for data in JSON {
                        
                        // Still pending : Store NSDate in keychain to check lastUpdateForRequests. Do not pull all requests everytime
                        if let maxDate: String = JSON.value(forKey:"maxDate") as! String{
                            let newAccount = Account(name: userID, accessToken: tokenVal, tDate : maxDate)
                        
                            // save / update
                            do {
                                try newAccount.saveInKeychain()
                                print("> saved the account in the Keychain")
                            
                            } catch {
                            
                                print(error)
                            }
                        }
                        
                        
                        if  let jsonArray :  NSArray = JSON.value(forKey: "taskList") as? NSArray{
                            if jsonArray.count <= 0
                            {
                                reloadTable = false
                            }
                            
                            for data in jsonArray {
                                let dict: NSDictionary = data as! NSDictionary
                                let requestObj = RequestObject()
                                requestObj.date = dict.value(forKey: "date") as! String
                                if self.selectedUserType == userType.doctor {
                                    if let tempName = dict.value(forKey: "educatorName"){
                                         requestObj.educatorName = dict.value(forKey: "educatorName") as! String
                                    }
                                   
                                }
                                else if self.selectedUserType == userType.educator {
                                    if let tempDrName = dict.value(forKey: "doctorName"){
                                        requestObj.doctorName = dict.value(forKey: "doctorName") as! String
                                    }
                                }
                                
                                if let tempPatName = dict.value(forKey: "patientName"){
                                    requestObj.patientName =  tempPatName as! String

                                }
                                else{
                                    requestObj.patientName = ""
                                }
                                
                                requestObj.taskid = dict.value(forKey: "taskid") as! String
                                requestObj.time =   dict.value(forKey: "time") as! String
                                requestObj.status =   dict.value(forKey: "status") as! String
                                requestObj.patientid = (dict.value(forKey: "patientid") as? String)!
                                
                                if self.selectedUserType == userType.educator{
                                    requestObj.didDoctorComment = dict.value(forKey: "commentAddedByDoctor") as! Bool
                                }
                                /*if let doctorCommented = {
                                    
                                }*/

                                
                                var readByArray : [String] = []
                                if let readByArrayCheck = dict.value(forKey: "readByArray"){
                                    
                                   // if readByArray.contains(null)
                                    //if readByArrayCheck
                                    readByArray = readByArrayCheck as! [String]
                                }
                                print("Read By Array")
                                print(readByArray)
                                
                                if self.selectedUserType == userType.doctor{
                                    requestObj.iseducatorin = true
                                    var status = dict.value(forKey: "status") as! String

                                    if status == "Pending"{
                                        status = "Pending".localized
                                        unreadCounter = unreadCounter + 1
                                        self.requestListArray.add(requestObj)
                                    }
                                    else if status == "Accepted"{
                                        status = "Accepted".localized
                                    }
                                    else if status == "Declined"{
                                        status = "Declined".localized
                                    }
                                    else
                                    {
                                        status = "Single Report".localized
                                        //unreadCounter = unreadCounter + 1
                                        self.requestListArray.add(requestObj)
                                    }
                                   
                                }
                                    
                                else if self.selectedUserType == userType.educator{
                                    let currentUserID : String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
                                    
                                    if readByArray.count >= 0
                                    {
                                        if !readByArray.contains(currentUserID){
                                            unreadCounter = unreadCounter + 1
                                            requestObj.iseducatorin = false
                                        }
                                        else{
                                            requestObj.iseducatorin = true
                                        }
                                        self.requestListArray.add(requestObj)
                                    }
                                   
                                    
                                    
                                }
                                
                                self.selectedPatientID = dict.value(forKey: "patientid") as! String
                                //self.requestListArray.add(requestObj)
                            }
                            
                        
//                            self.requestListArray.sort({$0.status.compare($1.status) == .orderedAscending})

//                             let requestListArraySorted = self.requestListArray.sorted(by: {($0 as AnyObject).status.compare(($1 as AnyObject).status) == .orderedAscending})
//                            print (requestListArraySorted)
                            
                        }
                                        
                                        
                        //if reloadTable{   // reload only if something new
                                        
                                        let requestListArraySorted : NSArray = self.requestListArray.sorted(by: {($0 as! RequestObject).status.compare(($1 as! RequestObject).status) == .orderedAscending}) as NSArray
                                        self.requestListArray.removeAllObjects()
                                        self.requestListArray = NSMutableArray(array:requestListArraySorted)
                           // let sortedMovies = requestListArray.sort { $0.status < $1.status }
                            self.tableView.reloadData()
                        //}
                        
                        }
                
                        if unreadCounter == 0 {
                            requestTabBarItem.badgeValue = nil
                        }
                        else{
                            requestTabBarItem.badgeValue = String(unreadCounter)
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
