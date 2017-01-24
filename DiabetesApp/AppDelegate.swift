//
//  AppDelegate.swift
//  DiabetesApp
//
//  Created by IOS2 on 12/21/16.
//  Copyright © 2016 Visions. All rights reserved.
//

import UIKit
import CoreData
import Quickblox

let kQBApplicationID:UInt = 47247
let kQBAuthKey = "wbtMCF5p5c3yC-S"
let kQBAuthSecret = "kSJ29gCrnWTjZFW"
let kQBAccountKey = "QwJxtpozqbEi58QT1Qm9"
// Video Calling Values

let kQBRingThickness : CGFloat = 1.0
let kQBAnswerTimeInterval :TimeInterval = 60.0
let kQBRTCDisconnectTimeInterval :TimeInterval = 30.0
let kQBDialingTimeInterval :TimeInterval = 5.0



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,NotificationServiceDelegate {

    var window: UIWindow?

    var currentUser: QBUUser? = nil
    var session : QBRTCSession? = nil

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
      
        // set Navigation bar Fonts
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: Fonts.GothamBoldFont, NSForegroundColorAttributeName:UIColor.white]
       // UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: Fonts.NavBarBtnFont, NSForegroundColorAttributeName:UIColor.white], for: UIControlState.normal)
        
        
        QBSettings.setApplicationID(kQBApplicationID)
        QBSettings.setAuthKey(kQBAuthKey)
        QBSettings.setAuthSecret(kQBAuthSecret)
        QBSettings.setAccountKey(kQBAccountKey)
        
        // enabling carbons for chat
        QBSettings.setCarbonsEnabled(true)
        
        // Enables Quickblox REST API calls debug console output.
        QBSettings.setLogLevel(QBLogLevel.nothing)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
        // app was launched from push notification, handling it
//        let remoteNotification: NSDictionary! = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
//        if (remoteNotification != nil) {
//            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
//        }
        
        // Initialize QuickbloxWebRTC and configure signaling
        // You should call this method before any interact with QuickbloxWebRTC
        
    
        //QuickbloxWebRTC preferences
        QBRTCConfig .setAnswerTimeInterval(kQBAnswerTimeInterval)
        QBRTCConfig .setDisconnectTimeInterval(kQBRTCDisconnectTimeInterval)
        QBRTCConfig .setDialingTimeInterval(kQBDialingTimeInterval)
        QBRTCConfig .setStatsReportTimeInterval(1.0)
        QBRTCClient.initializeRTC()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription: QBMSubscription! = QBMSubscription()
        
        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        UserDefaults.standard .set(deviceToken, forKey: "DeviceToken")
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
        }) { (response: QBResponse!) -> Void in
            //
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        print("my push is: %@", userInfo)
        guard application.applicationState == UIApplicationState.inactive else {
            return
        }
        if let messageFrom : String = userInfo["type"] as? String {
            if messageFrom == "Report" {
                
                let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController
                let viewController: ReportViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: ViewIdentifiers.ReportViewController) as! ReportViewController
                    viewController.taskID = (userInfo["taskid"] as! String)
                    application.applicationIconBadgeNumber = Int(userInfo["badgeCounter"] as! String)!
                    navigatonController.pushViewController(viewController, animated: true)
            }
        }
        
        guard let dialogID = userInfo["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String else {
            return
        }
        
        guard !dialogID.isEmpty else {
            return
        }
        
        
        let dialogWithIDWasEntered: String? = ServicesManager.instance().currentDialogID
        if dialogWithIDWasEntered == dialogID {
            return
        }
        
        ServicesManager.instance().notificationService.pushDialogID = dialogID
        
        // calling dispatch async for push notification handling to have priority in main queue
        DispatchQueue.main.async {
            
            ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: self)
        }
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        application.applicationIconBadgeNumber = 0
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        ServicesManager.instance().chatService.connect(completionBlock: nil)
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

   

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Core Data stack

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "DiabetesApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController
        
        let chatController: ChatViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog
        
        let dialogWithIDWasEntered = ServicesManager.instance().currentDialogID
        if !dialogWithIDWasEntered.isEmpty {
            // some chat already opened, return to dialogs view controller first
            navigatonController.popViewController(animated: false);
        }
        
        navigatonController.pushViewController(chatController, animated: true)
    }
    
    func notificationServiceDidFailFetchingDialog() {
    }


}

