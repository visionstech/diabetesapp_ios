//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit
import QMServices
import SVProgressHUD
import Quickblox
import Alamofire
import SDWebImage



var recentMessageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }
    
    return Static.instance
}
class DialogTableViewCellModel: NSObject {
    
    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?
   
    
    
    init(dialog: QBChatDialog) {
        super.init()
		switch (dialog.type){
		case .publicGroup:
			self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
		case .group:
			self.detailTextLabelText = "SA_STR_GROUP".localized
		case .private:
			self.detailTextLabelText = "SA_STR_PRIVATE".localized
			
			if dialog.recipientID == -1 {
				return
			}
			
			// Getting recipient from users service.
			if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
				self.textLabelText = recipient.login ?? recipient.email!
               
			}
            
		}
        
        if self.textLabelText.isEmpty {
            // group chat
            
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }
        
        // Unread messages counter label
        
        if (dialog.unreadMessagesCount > 0) {
            
            var trimmedUnreadMessageCount : String
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            
            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false
            
        }
        else {
            
            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }
        
        // Dialog icon
        
//        let customParams: NSMutableDictionary = NSMutableDictionary()
//        customParams["chat_id"] = dialog.id
//        
//        QBRequest.objects(withClassName: "Patient", extendedRequest: customParams, successBlock: { (responce: QBResponse?,record, page) in
//            
//                let data = record! as Array<QBCOCustomObject>
//            
        
//                let recipientTypes = data[0].fields?.value(forKey: "recipientTypes") as! [String]
//                let recipientIDs = data[0].fields?.value(forKey: "recipientIDs") as! [String]
//                var selectedPatientID : String = ""
//            
//                let typeUser : Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
//            
//            
//                var databaseToCheck = ""
//            
//                if(typeUser == userType.doctor){
//                    databaseToCheck = "Patient"
//                }
//                else if(typeUser == userType.patient && recipientTypes.contains("doctor"))
//                {
//                    databaseToCheck = "Doctor"
//                    selectedPatientID = recipientIDs[recipientTypes.index(of: "doctor")!]
//                }
//                else if(typeUser == userType.patient && recipientTypes.contains("educator"))
//                {
//                    databaseToCheck = "Educator"
//                    selectedPatientID = recipientIDs[recipientTypes.index(of: "educator")!]
//                }
//                else if(typeUser == userType.patient && recipientTypes.contains("patient"))
//                {
//                    databaseToCheck = "Patient"
//                }
//                else if(typeUser == userType.patient && recipientTypes.contains("doctor"))
//                {
//                    databaseToCheck = "Doctor"
//                   selectedPatientID = recipientIDs[recipientTypes.index(of: "doctor")!]
//                }
//            
//                getImage(userid: selectedPatientID, type: databaseToCheck) { (result) -> Void in
//                    if(result){
//                    
//                    }
//                    else
//                    {
//                            //Add Alert code here
//                        _ = AlertView(title: "Error", message: "No display image found", cancelButtonTitle: "OK", otherButtonTitle: ["Cancel"], didClick: { (buttonIndex) in
//                        })
//                    }
//                
//                }
//            
//                
//        });
//        if dialog.type == .private {
//            self.dialogIcon = UIImage(named: "user")
//        }
//        else {
//            self.dialogIcon = UIImage(named: "group")
//        }
    }
}

class DialogsViewController: UITableViewController, QMChatServiceDelegate, QBCoreDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate, QBRTCClientDelegate, IncomingCallViewControllerDelegate  {

    @IBOutlet weak var lblDate: UILabel!
    
    private var didEnterBackgroundDate: NSDate?
    private var observer: NSObjectProtocol?
    var counterCall = 0
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
    //var session : QBRTCSession? = nil
     var requestTimer  =  Timer()
     var myTimer  =  Timer()
    
    
    
    // MARK: - ViewController overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
       // self.navigationItem.title = ServicesManager.instance().currentUser()?.login!
       
        setNavBarUI()
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().authService.add(self)
        
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            
            if !QBChat.instance().isConnected {
               
                QBChat.instance().forceReconnect()
                
               // SVProgressHUD.show(withStatus: "SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.clear)
                self.myTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
            }
            else{
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(DialogsViewController.didEnterBackgroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if (QBChat.instance().isConnected && ServicesManager.instance().isAuthorized()) {
            self.getDialogs()
        }
        
        QBRTCClient.instance().add(self)
        
        tableView.tableFooterView = UIView()
        if self.requestTimer != nil {
            self.requestTimer .invalidate()
            self.requestTimer == nil
        }
        
    self .getRequestBadgeCounter()
        
       self.requestTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.getRequestBadgeCounter), userInfo: nil, repeats: true)
    }
    
    func runTimedCode()  {
        if UIApplication.shared.isNetworkActivityIndicatorVisible {
        }
        else {
            SVProgressHUD.dismiss()
            myTimer.invalidate()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //--------Google Analytics Start-----
        GoogleAnalyticManagerApi.sharedInstance.startScreenSessionWithName(screenName: kDialogsScreenName)
        //--------Google Analytics Finish-----
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // let appleArray = UserDefaults.standard.value(forKey: "AppleLanguages") as! NSArray
        setNavBarUI()
        self.tableView.reloadData()
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if appDelegate.session != nil {
            appDelegate.session = nil
        }
        
    }
    
    
    func getRequestBadgeCounter()  {
        
        let loggedInUserID: String = UserDefaults.standard.string(forKey: userDefaults.loggedInUserID)!
        let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        
       
        let parameters: Parameters = [
            "userid": loggedInUserID,
            "usertype": selectedUserType
            
        ]
        
        Alamofire.request("\(baseUrl)\(ApiMethods.getRequestCount)", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            
            print("Validation Successful ")
            
            switch response.result {
                
            case .success:
                
                if let JSON: NSDictionary = response.result.value! as? NSDictionary {
                    
                    let badgeCounter =  String(JSON.value(forKey: "requestCount") as! Int)
                    print("Badge counter")
                    print(badgeCounter)
                    if badgeCounter == "0" {
                        requestTabBarItem.badgeValue = nil
                    }
                    else{
                        requestTabBarItem.badgeValue = String(badgeCounter)
                    }
                    
                    
                    
                    
                }
                
                break
            case .failure:
                print("failure")
                // SVProgressHUD.showError(withStatus:response.result.error?.localizedDescription )
                break
                
            }
        }
        
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            self.navigationItem.leftBarButtonItem = nil
            self.navigationItem.rightBarButtonItems = nil
            self.tabBarController?.navigationItem.leftBarButtonItem = nil
            self.tabBarController?.navigationItem.rightBarButtonItems = nil
            
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialog = sender as? QBChatDialog
                 chatVC.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    
    func setNavBarUI(){
        

        if selectedUserType != userType.patient {
            
            let chatButton = UIBarButtonItem(image: UIImage(named:"NewMessage" ), style: .plain, target: self, action: #selector(DialogsViewController.GroupAction(_:)))
            chatButton.tag = 1
//            let groupChatButton = UIBarButtonItem(image: UIImage(named:"groupIcon" ), style: .plain, target: self, action: #selector(DialogsViewController.GroupAction(_:)))

             let groupChatButton = UIBarButtonItem(image: UIImage(named:"NewMessage" ), style: .plain, target: self, action: #selector(DialogsViewController.GroupAction(_:)))
            groupChatButton.tag = 0
            
            if selectedUserType == userType.doctor {
                  self.tabBarController?.navigationItem.rightBarButtonItems = [chatButton]
            }
            else {
                  self.tabBarController?.navigationItem.rightBarButtonItems = [groupChatButton]
//                 self.navigationItem.rightBarButtonItems = [groupChatButton,chatButton]
            }
        }
        
        //self.tabBarController?.title = "Bo"
        //self.tabBarController?.navigationItem.title = "Too"
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(DialogsViewController.logoutAction))
        if self.tabBarController != nil {
          //  self.tabBarController?.navigationItem.title = "Hey"
           // self.tabBarController?.title = "Ho"
            //self.tabBarController?.navigationItem.title = "Inbox".localized

            
            self.title = "\("Inbox".localized)"
            self.tabBarController?.title = "\("Inbox".localized)"
            self.tabBarController?.navigationItem.title = "\("Inbox".localized)"
            
            self.tabBarController?.navigationItem.leftBarButtonItem = logoutButton
            
        }
        
        
    }
    
    //MARK: - QBRTCClientDelegate Delegate
    func didReceiveNewSession(_ session: QBRTCSession!, userInfo: [AnyHashable : Any]! = [:]) {
        
        if (appDelegate.session != nil) {
            session.rejectCall(["reject":"busy"])
            GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Incoming Call", action:"Reject - busy" , label:"Incoming Call \(session.initiatorID)")
            return
        }
        
        appDelegate.session = session
        QBRTCSoundRouter.instance().initialize()
        
        
        QBRequest.user(withID:session.initiatorID as UInt , successBlock: { (response, user) in
            
            let incomingViewController: IncomingCallViewController = self.storyboard?.instantiateViewController(withIdentifier: "IncomingCallViewController") as! IncomingCallViewController
            incomingViewController.delegate = self
            incomingViewController.session = self.appDelegate.session
            incomingViewController.currentUser = self.appDelegate.currentUser
            incomingViewController.qbUsersArray = NSMutableArray(object: user! as QBUUser)
            //self.present(incomingViewController, animated: true, completion: nil)
            self.navigationController?.pushViewController(incomingViewController, animated: true)
            
        }) { (eroor) in
            
        }
        
    }
    
    func sessionDidClose(_ session: QBRTCSession!) {
        
        //if session == appDelegate.session {
            self.navigationController?.popViewController(animated: true)
            //self.navigationController?.popToViewController(self as UIViewController, animated: true)
            //self.dismiss(animated: true, completion: nil)
            appDelegate.session = nil
            
        //}
    }
    
    //MARK: - IncomingCall Delegate
    func incomingCallViewControllerReject(_ vc: IncomingCallViewController!, didReject session: QBRTCSession!) {
        self.appDelegate.session = session
        session.rejectCall(nil)
         GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Incoming Call", action:"Reject" , label:"Incoming Call \(session.initiatorID)")
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func incomingCallViewControllerAccept(_ vc: IncomingCallViewController!, didAccept session: QBRTCSession!) {
        
        self.appDelegate.session = session
        
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Incoming Call", action:"Accept" , label:"Incoming Call \(session.initiatorID)")
        
        QBRequest.user(withID:session.initiatorID as UInt , successBlock: { (response, user) in
            
            let callViewController: CallViewController = self.storyboard?.instantiateViewController(withIdentifier: "CallViewController") as! CallViewController
            callViewController.currentUser = self.appDelegate.currentUser
            callViewController.session = self.appDelegate.session
            callViewController.qbUsersArray = NSMutableArray(object: user)
            // self.present(callViewController, animated: true, completion: nil)
            self.navigationController?.pushViewController(callViewController, animated: true)
            
        }) { (eroor) in
            
        }
    }
    
    // MARK: - Notification handling
    
    func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    
    // MARK: - Actions
    func createLogoutButton() -> UIBarButtonItem {
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(DialogsViewController.logoutAction))
        return logoutButton
    }
    
    @IBAction func GroupAction(_ sender: UIBarButtonItem) {
        
        let viewController: ContactListViewController = self.storyboard?.instantiateViewController(withIdentifier: ViewIdentifiers.contactViewController) as! ContactListViewController
        viewController.isGroupMode = (sender.tag == 0 ? true : false)
        self.tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func logoutAction() {
        
        if !QBChat.instance().isConnected {

            SVProgressHUD.showError(withStatus: "Error")
            return
        }
        
       // SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.clear)
        
        ServicesManager.instance().lastActivityDate = nil
        
        ServicesManager.instance().logoutUserWithCompletion { [weak self] (boolValue) -> () in
            
            guard let strongSelf = self else { return }
            if boolValue {
                NotificationCenter.default.removeObserver(strongSelf)
                
                if strongSelf.observer != nil {
                    NotificationCenter.default.removeObserver(strongSelf.observer!)
                    strongSelf.observer = nil
                }
                
                ServicesManager.instance().chatService.removeDelegate(strongSelf)
                ServicesManager.instance().authService.remove(strongSelf)
                UserDefaults.standard.set(false, forKey: userDefaults.isLoggedIn)
                ServicesManager.instance().lastActivityDate = nil;
                
                // Update UserDefaults
                UserDefaults.standard.set(false, forKey: userDefaults.isLoggedIn)
                
                UserDefaults.standard.setValue("" , forKey: userDefaults.loggedInUserID)
                UserDefaults.standard.setValue("", forKey: userDefaults.loggedInUsername)
                UserDefaults.standard.setValue("", forKey: userDefaults.loggedInUserEmail)
                UserDefaults.standard.setValue("", forKey: userDefaults.loggedInUserPassword)
                UserDefaults.standard.setValue("", forKey: userDefaults.selectedPatientID)
                UserDefaults.standard.setValue("", forKey: userDefaults.selectedPatientHCNumber)
                UserDefaults.standard.set("", forKey: userDefaults.recipientTypesArray)
                UserDefaults.standard.set("", forKey: userDefaults.recipientIDArray)
                UserDefaults.standard.setValue("", forKey: userDefaults.loggedInUserFullname)
                UserDefaults.standard.setValue("", forKey: userDefaults.loggedInUserType)
               
                UserDefaults.standard.synchronize()
                 GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Logout", action:"Logout Button Clicked" , label:"Successfull logout")
                
                SVProgressHUD.dismiss()
                if self?.tabBarController != nil {
                    self?.tabBarController?.navigationController?.popToRootViewController(animated: true)
                }
                else{
                     let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
                
                //SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
            }
        }
    }
	
    // MARK: - DataSource Action
	
    func getDialogs() {
		//self.getReadCount()
        if let lastActivityDate = ServicesManager.instance().lastActivityDate {
			
			ServicesManager.instance().chatService.fetchDialogsUpdated(from: lastActivityDate as Date, andPageLimit: kDialogsPageLimit, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
                
            }, completionBlock: { (response) -> Void in
					
                    if (response.isSuccess) {
                         self.updateCounter()
                        ServicesManager.instance().lastActivityDate = NSDate()
                    }
			})
        }
        else {
            
           // SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOGS".localized, maskType: SVProgressHUDMaskType.clear)
			
			ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            }, completion: { (response: QBResponse?) -> Void in
					
					guard response != nil && response!.isSuccess else {
                        
                        
						SVProgressHUD.showError(withStatus: "SA_STR_FAILED_LOAD_DIALOGS".localized)
						return
					}
					 self.updateCounter()
					//SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
					ServicesManager.instance().lastActivityDate = NSDate()
			})
        }
    }

    // MARK: - DataSource
    
	func dialogs() -> [QBChatDialog]? {
       
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let dialogs = self.dialogs() {
			return dialogs.count
		}
       // else{
         //   self.present(UtilityClass.displayAlertMessage(message: "Dialog count is 0. Error loading recent chats", title: "Error"), animated: true, completion: nil)
           // return 0
        //}
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        print("Done second")
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogcell", for: indexPath) as! DialogTableViewCell
        
        if ((self.dialogs()?.count)! < indexPath.row) {
            return cell
        }
        
        guard let chatDialog = self.dialogs()?[indexPath.row] else {
            return cell
        }
        
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        cell.backgroundColor = UIColor.white
        cell.accessoryType = .disclosureIndicator
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.id!
        
        
        
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
    
        
        let customParams: NSMutableDictionary = NSMutableDictionary()
        customParams["chat_id"] = chatDialog.id
        
        //SVProgressHUD.show(withStatus: "Loading chat".localized, maskType: SVProgressHUDMaskType.clear)
        
        let typeUser : Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        
        QBRequest.objects(withClassName: "Patient", extendedRequest: customParams, successBlock: { (responce: QBResponse?,record, page) in
            
            let data = record! as Array<QBCOCustomObject>
            
            if(data.count > 0)
            {
                if data[0].fields?.value(forKey: "recipientTypes") != nil && data[0].fields?.value      (forKey: "recipientIDs") != nil
                {
                
                    let recipientTypes = data[0].fields?.value(forKey: "recipientTypes") as! [String]
                    let recipientIDs = data[0].fields?.value(forKey: "recipientIDs") as! [String]
            
                    //var databaseToCheck = ""
                    var selectedPatientID : String = ""
            
                    if(typeUser == userType.doctor){
                       // databaseToCheck = "Patient"
                        selectedPatientID = (recipientIDs[(recipientTypes.index(of: "patient"))!])
                    }
                    else if(typeUser == userType.patient && (recipientTypes.contains("doctor")))
                    {
                        //databaseToCheck = "Doctor"
                        selectedPatientID = (recipientIDs[(recipientTypes.index(of: "doctor"))!])
                    }
                    else if(typeUser == userType.patient && (recipientTypes.contains("educator")))
                    {
                        //databaseToCheck = "Educator"
                        selectedPatientID = (recipientIDs[(recipientTypes.index(of: "educator"))!])
                    }
                    else if(typeUser == userType.educator && (recipientTypes.contains("patient")))
                    {
                        //databaseToCheck = "Patient"
                        selectedPatientID = (recipientIDs[(recipientTypes.index(of: "patient"))!])
                    }
                    else if(typeUser == userType.educator && (recipientTypes.contains("doctor")))
                    {
                       // databaseToCheck = "Doctor"
                        selectedPatientID = (recipientIDs[(recipientTypes.index(of: "doctor"))!])
                    }
                    // TODO generalize this URL to the new public ip
                    let imagePath = "http://54.212.229.198:3000/upload/" + selectedPatientID + "image.jpg"
                    let manager:SDWebImageManager = SDWebImageManager.shared()
            
                    //cell.dialogTypeImage.image =   UIImage(named:"user.png")!
                    manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                  options: SDWebImageOptions.highPriority,
                                  progress: nil,
                                  completed: {[weak self] (image, error, cached, finished, url) in
                                    if (error == nil && (image != nil) && finished) {
                                        
                                        //cell.
                                        
                                        cell.dialogTypeImage.layer.cornerRadius =
                                            cell.dialogTypeImage.frame.size.width/2
                                        
                                        cell.dialogTypeImage.clipsToBounds = true
                                        
                                        cell.dialogTypeImage.image = image
                                        
                                    }
                            })
                }

            
                var recipientNames : [String] = []
            
                if data[0].fields?.value(forKey: "recipientNames") != nil{
                    recipientNames = data[0].fields?.value(forKey: "recipientNames") as! [String]
                
                    if(typeUser == userType.patient)
                    {
                        if(recipientNames.count >= 2)
                        {
                            cell.dialogName?.text = recipientNames[1]
                            SVProgressHUD.dismiss()
                        }
                        else{
                            cell.dialogName?.text = cellModel.textLabelText
                            SVProgressHUD.dismiss()
                        }
                    }
                    else{
                        cell.dialogName?.text = cellModel.textLabelText
                        SVProgressHUD.dismiss()
                    }
                
                }
            }
        });
        
        
        if UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.rightToLeft {
            
           // self.navigationItem.leftBarButtonItems = [optionsBtnBar,ReportBarButton]
            cell.dialogLastMessage?.textAlignment = .right
            cell.dialogName?.textAlignment = .right
        }
        else {
            
           // self.navigationItem.rightBarButtonItems = [optionsBtnBar,ReportBarButton]
             cell.dialogLastMessage?.textAlignment = .left
             cell.dialogName?.textAlignment = .left
            
        }

        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden
        
    if  chatDialog.lastMessageDate != nil {
        let date =  chatDialog.lastMessageDate! as Date
        let calendar = Calendar.current
        
        
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hh = calendar.component(.hour, from: date)
        let min = calendar.component(.minute, from: date)
        let sec = calendar.component(.second, from: date)
        let cal =  Calendar.current
        
        
        let date1 = cal.date(from: DateComponents(year: year, month:  month, day: day, hour: hh, minute: min, second : sec))!
        
        let timeOffset1 = date1.relativeTime
       
 
        cell.lblDate.text = timeOffset1
        }
        
        return cell
    }
    
    func getImage(userid: String, type: String, cellModel: DialogTableViewCell, withCompletionHandler:@escaping (_ result:Bool) -> Void)  {
       
        Alamofire.request("http://54.212.229.198:3000/showImage?id="+userid+"&type="+type, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                print("Validation Successful")
                print(response.result.value)
                if let JSON: NSDictionary = response.result.value as! NSDictionary?
                {
                    if JSON["profileimage"] != nil {
                        // now val is not nil and the Optional has been unwrapped, so use it
                        
                        let imageName: String = JSON.value(forKey:"profileimage") as! String
                        
                        let imagePath = "http://54.212.229.198:3000/upload/" + imageName
                        let manager:SDWebImageManager = SDWebImageManager.shared()
                        
                        
                        
                        manager.downloadImage(with: NSURL(string: imagePath) as URL!,
                                              options: SDWebImageOptions.highPriority,
                                              progress: nil,
                                              completed: {[weak self] (image, error, cached, finished, url) in
                                                if (error == nil && (image != nil) && finished) {
                                                  
                                                   
                                                    cellModel.dialogTypeImage.layer.cornerRadius = cellModel.dialogTypeImage.frame.size.width/2
                                                    
                                                    cellModel.dialogTypeImage.clipsToBounds = true
                                                    
                                                    cellModel.dialogTypeImage.image = image
                                                    
                                                    
//                                                    guard let chatDialog = self.dialogs()?[indexPath.row] else {
//                                                        return cell
//                                                    }
                                                    
                                                }
                        })
                        print(imagePath)
                        withCompletionHandler(true)
                    }
                }
                
                break
            case .failure:
                withCompletionHandler(false)
                break
                
            }
            
        }
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         tableView.isUserInteractionEnabled = false
       
        tableView.deselectRow(at: indexPath, animated: true)
        
               if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        if dialog.photo != nil
        {
            
            UserDefaults.standard.setValue(String(describing: dialog.photo!), forKey: userDefaults.selectedPatientID)
        }
        
        let customParams: NSMutableDictionary = NSMutableDictionary()
        customParams["chat_id"] = dialog.id
        
        
        QBRequest.objects(withClassName: "Patient", extendedRequest: customParams, successBlock: { (responce: QBResponse?,record, page) in
            
            let data = record! as Array<QBCOCustomObject>
            
           
            if(data.count > 0)
            {
                UserDefaults.standard.set(data[0].fields?.value(forKey: "recipientTypes"), forKey: userDefaults.recipientTypesArray)
                UserDefaults.standard.set(data[0].fields?.value(forKey: "recipientIDs"), forKey: userDefaults.recipientIDArray)
            
                UserDefaults.standard.setValue(data[0].fields?.value(forKey: "patient_id"), forKey: userDefaults.selectedPatientID)
            
                UserDefaults.standard.setValue(data[0].fields?.value(forKey: "HCNumber"), forKey: userDefaults.selectedPatientHCNumber)
            
                let patientsID: String = UserDefaults.standard.string(forKey: userDefaults.selectedPatientID)!
//            print(patientsID)
            
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QMChat", action:"Select Dialog For chat" , label:"Successfully redirect with chat")
                tableView.isUserInteractionEnabled = true
                self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
            }
            else{
                self.present(UtilityClass.displayAlertMessage(message: "Something is wrong with this chat", title: "SA_STR_ERROR".localized), animated: true, completion: nil)
                //Google Analytic
                GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QMChat", action:"Select Dialog For chat" , label:"Something is wrong with this chat")
                 tableView.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
            }
        }) { (responce: QBResponse?) in
            print(responce as Any)

        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == UITableViewCellEditingStyle.delete else {
            return
        }
        
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        _ = AlertView(title:"SA_STR_WARNING".localized , message:"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick:{ (buttonIndex) -> Void in
            
            guard buttonIndex == 1 else {
                return
            }
            
            SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.clear)
            
            let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
                
                // Deletes dialog from server and cache.
                ServicesManager.instance().chatService.deleteDialog(withID: dialog.id!, completion: { (response) -> Void in
                    
                    guard response.isSuccess else {
                        
                        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Delete Chat", action:"Fail - Delete Chat" , label:response.error?.error as! String)
                        
                        SVProgressHUD.showError(withStatus: "SA_STR_ERROR_DELETING".localized)
                        print(response.error?.error)
                        return
                    }
                    GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "Delete Chat", action:"Success - Delete Chat" , label:"Successful Delete Chat")
                    SVProgressHUD.showSuccess(withStatus: "SA_STR_DELETED".localized)
                })
            }
            
            if dialog.type == QBChatDialogType.private {
                
                deleteDialogBlock(dialog)
                
            }
            else {
                // group
                let occupantIDs = dialog.occupantIDs!.filter({ (number) -> Bool in
                    
                    return number.uintValue != ServicesManager.instance().currentUser()?.id
                })
                
                dialog.occupantIDs = occupantIDs
                let userLogin = ServicesManager.instance().currentUser()?.login ?? ""
                let notificationMessage = "User \(userLogin) " + "SA_STR_USER_HAS_LEFT".localized
                // Notifies occupants that user left the dialog.
                ServicesManager.instance().chatService.sendNotificationMessageAboutLeaving(dialog, withNotificationText: notificationMessage, completion: { (error) -> Void in
                    deleteDialogBlock(dialog)
                })
            }
        })
    }
	
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "SA_STR_DELETE".localized
    }
    
     // MARK: - Update badgue Counter
    func updateCounter()
    {
        var totalCount = 0
        if let dialogs = self.dialogs() {
            for dialog in dialogs {
                let cellModel = DialogTableViewCellModel(dialog: dialog)
                
                if(cellModel.unreadMessagesCounterLabelText != nil)
                {
                    totalCount = totalCount + Int(cellModel.unreadMessagesCounterLabelText!)!
                }
            }
        }
        
        tabCounter = String(totalCount)
        //Set Unread Count Based on User type
        //        let selectedUserType: Int = Int(UserDefaults.standard.integer(forKey: userDefaults.loggedInUserType))
        if(self.tabBarController?.tabBar.items?.count == 2)
        {
            
            self.tabBarController?.tabBar.items?.first?.badgeValue = tabCounter
            if(Int(tabCounter)==0)
            {
                self.tabBarController?.tabBar.items?.first?.badgeValue = nil
            }
        }
        else
        {
            self.tabBarController?.tabBar.items?.last?.badgeValue = tabCounter
            if(Int(tabCounter)==0)
            {
                self.tabBarController?.tabBar.items?.last?.badgeValue = nil
            }
        }
    }
    // MARK: - QMChatServiceDelegate

    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        self.updateCounter()
        self.reloadTableViewIfNeeded()
    }
	
    func chatService(_ chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){
        self.reloadTableViewIfNeeded()
    }
	
    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){
        
        self.reloadTableViewIfNeeded()
    }

    
    // MARK: QMChatConnectionDelegate
    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
        //Google Analytic
        var strError = ""
        if(error.localizedDescription.length>0)
        {
            strError = error.localizedDescription
        }
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QMChat", action:"Chat Fail" , label:strError )
        
    }
    
    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        SVProgressHUD.showError(withStatus: "SA_STR_DISCONNECTED".localized)
        //Google Analytic
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QMChat", action:"Accidentally Disconnect" , label:  "SA_STR_DISCONNECTED".localized)
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
       // SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType:.clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    func chatService(_ chatService: QMChatService,chatDidNotConnectWithError error: Error){
        SVProgressHUD.showError(withStatus: error.localizedDescription)
        //Google Analytic
        var strError = ""
        if(error.localizedDescription.length>0)
        {
            strError = error.localizedDescription
        }
        GoogleAnalyticManagerApi.sharedInstance.sendAnalyticsEventWithCategory(category: "QMChat", action:"Not Connect With Error" , label:strError)
    }
	
	
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        //SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType: .clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    // MARK: - Helpers
    func reloadTableViewIfNeeded() {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.tableView.reloadData()
        }
    }
    func getReadCount() {
        let selectedUser = QBUUser()
        selectedUser.email = UserDefaults.standard.value(forKey: userDefaults.loggedInUserEmail) as! String!
        selectedUser.password = UserDefaults.standard.value(forKey: userDefaults.loggedInUserPassword) as! String!
        
        Alamofire.request("http://54.244.176.114:3000/api/messages/unread?email="+selectedUser.email!+"&password="+selectedUser.password!, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
            case .success:
                if let JSON: NSDictionary = response.result.value as! NSDictionary? {
                    print (JSON)
                    if let result_number = JSON["total"] as? NSNumber
                    {
                        let result_string = "\(result_number)"
                        tabCounter = result_string
                        if(self.tabBarController?.tabBar.items?.count == 2)
                        {
                            
                            self.tabBarController?.tabBar.items?.first?.badgeValue = tabCounter
                            if(Int(tabCounter)==0)
                            {
                                self.tabBarController?.tabBar.items?.first?.badgeValue = nil
                            }
                        }
                        else
                        {
                            self.tabBarController?.tabBar.items?.last?.badgeValue = tabCounter
                            if(Int(tabCounter)==0)
                            {
                                self.tabBarController?.tabBar.items?.last?.badgeValue = nil
                            }
                        }
                    }
                }
                break
            case .failure:
                print("failure")
                SVProgressHUD.dismiss()
                break
            }
        }
    }
    
     //MARK:- Selected users
    

//    func usersToCall() -> Bool {
//        let isOK : Bool =
//        
//    }
     //MARK:- getReadCount
}

extension Date {
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    var relativeTime: String {
        let now = Date()
        if now.years(from: self)   > 0 {
            return now.years(from: self).description  + " year"  + { return now.years(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.months(from: self)  > 0 {
            return now.months(from: self).description + " month" + { return now.months(from: self)  > 1 ? "s" : "" }() + " ago"
        }
        if now.weeks(from:self)   > 0 {
            return now.weeks(from: self).description  + " week"  + { return now.weeks(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.days(from: self)    > 0 {
            if now.days(from:self) == 1 { return "Yesterday" }
            return now.days(from: self).description + " days ago"
        }
        if now.hours(from: self)   > 0 {
            return "\(now.hours(from: self)) hour"     + { return now.hours(from: self)   > 1 ? "s" : "" }() + " ago"
        }
        if now.minutes(from: self) > 0 {
            return "\(now.minutes(from: self)) minute" + { return now.minutes(from: self) > 1 ? "s" : "" }() + " ago"
        }
        if now.seconds(from: self) > 0 {
            if now.seconds(from: self) < 15 { return "Just now"  }
            return "\(now.seconds(from: self)) second" + { return now.seconds(from: self) > 1 ? "s" : "" }() + " ago"
        }
        return ""
    }
}

