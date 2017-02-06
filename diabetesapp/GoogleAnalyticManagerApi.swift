//
//  GoogleAnalyticManagerApi.swift
//  DiabetesApp
//
//  Created by Carisa Antariksa on 1/24/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import Foundation

class GoogleAnalyticManagerApi: NSObject {
    
    static let sharedInstance = GoogleAnalyticManagerApi()
    var googleBoolean = false
    var automaticSessionManagementEnabled = false
    var loggingEnabled = false
    var isSessionActive = false
    var kAnalyticsStartSessionKey = "start"
    var kAnalyticsEndSessionKey = "end"
    weak var tracker: GAITracker?
    
    func configureGoogleServices() {
        if googleBoolean {
            let gai = GAI.sharedInstance()
            gai?.trackUncaughtExceptions = true
            gai?.logger.logLevel = GAILogLevel(rawValue: 4)!
        }
    }
    
    func setuserId(userId: String) {
        do {
            if googleBoolean {
                GAI.sharedInstance().defaultTracker.set(kGAIUserId, value: userId)
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    func setclientId(clientId: String) {
        do {
            if googleBoolean {
                GAI.sharedInstance().defaultTracker.set(kGAIClientId, value: clientId)
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    
    func startScreenSessionWithName(screenName: String) {
        do {
            if googleBoolean {
                GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: screenName)
                guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                GAI.sharedInstance().defaultTracker.send(builder.build() as [NSObject : AnyObject])
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    
    func sendEventWithCategory(methodName: String, lableName labelName: String) {
        do {
            if googleBoolean {
                self.tracker = GAI.sharedInstance().defaultTracker
                guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
                self.tracker?.send(builder.build() as [NSObject : AnyObject])
                
                self.tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: "ui_action", action: methodName, label: labelName, value: nil).build() as [NSObject : AnyObject])
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    
    func sendException(isFatal: Bool, withDescription: String) {
        do {
            if googleBoolean {
                let tracker = GAI.sharedInstance().defaultTracker
                
                tracker?.send(GAIDictionaryBuilder.createException(withDescription: withDescription, withFatal: NSNumber(value: isFatal)).build() as [NSObject : AnyObject])
                // isFatal (required). NO indicates non-fatal exception.
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    func setCreateEventWithCategory(createEventWithCategory: String, action: String, label: String) {
        do {
            if googleBoolean {
                let tracker = GAI.sharedInstance().defaultTracker
                tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: createEventWithCategory, action: action, label: label, value: nil).build() as [NSObject : AnyObject])
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    func setCreateEventWithCategory(createEventWithCategory: String, action: String, label: String, value: NSNumber) {
        do {
            if googleBoolean {
                let tracker = GAI.sharedInstance().defaultTracker
                let timeused = NSNumber(value:(Int(CDouble(value) * 1000)))
                tracker?.send(GAIDictionaryBuilder.createEvent(withCategory: createEventWithCategory, action: action, label: label, value: timeused).build() as [NSObject : AnyObject])
            }
        }     catch let exception {
            print("exception=\(exception)")
        }
    }
    
    // pragma mark - Initialization
    
    override init() {
        super.init()
        self.automaticSessionManagementEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppInactive), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleAppInactive), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    
    func handleAppActive() {
        // If the app has become active and automatic session management is enabled,
        // let's start the session.
        //
        if self.automaticSessionManagementEnabled {
            self.startAnalyticsSession()
        }
    }
    
    func handleAppInactive() {
        // If the app has become inactive and automatic session management is enabled,
        // let's end the session.
        //
        if self.automaticSessionManagementEnabled {
            self.endAnalyticsSession()
        }
    }
    
    
    func startAnalyticsSession() {
        if self.loggingEnabled {
            print("[GTrack] Starting analytics session.")
        }
        let tracker = GAI.sharedInstance().defaultTracker
        
        tracker!.set(kGAISessionControl, value: kAnalyticsStartSessionKey)
        self.isSessionActive = true
    }
    
    func endAnalyticsSession() {
        if self.loggingEnabled {
            print("[GTrack] Ending analytics session.")
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker!.set(kGAISessionControl, value: kAnalyticsEndSessionKey)
        self.isSessionActive = false
    }
    
    
    func sendScreenEventWithTitle(title: String) {
        if self.loggingEnabled {
            print("[GTrack] Dispatched screen event: \(title)")
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker!.set(kGAIScreenName, value: title)
        tracker!.send(GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject])
    }
    
    
    func sendAnalyticsEventWithCategory(category: String) {
        self.sendAnalyticsEventWithCategory(category: category, action: "", label: "", value: 0)
    }
    
    func sendAnalyticsEventWithCategory(category: String, action: String) {
        self.sendAnalyticsEventWithCategory(category: category, action: action, label: "", value: 0)
    }
    
    func sendAnalyticsEventWithCategory(category: String, action: String, label: String) {
        self.sendAnalyticsEventWithCategory(category: category, action: action, label: label, value: 0)
    }
    
    func sendAnalyticsEventWithCategory(category: String, action: String, label: String, value: NSNumber) {
        if self.loggingEnabled {
            print("[GTrack] Dispatched event with category: \(category), action: \(action), label: \(label), value: \(value)")
        }
        let tracker = GAI.sharedInstance().defaultTracker
        tracker!.set(kGAIScreenName, value: nil)
        let timeUsed = Int(Int(CDouble(value) * 1000))
        tracker!.send(GAIDictionaryBuilder.createTiming(withCategory: category, interval: timeUsed as NSNumber!, name: action, label: label).build() as [NSObject : AnyObject])
        //   [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:value] build]];
    }
}

class GTInterval: NSObject {
    let kAnalyticsSecondsPerMinute = 60.0
    let kAnalyticsSecondsPerHour = 3600.0
    let kAnalyticsDefaultTimeInterval : TimeInterval = -1.0
    var endDate: NSDate!
    var startDate: NSDate!
    var timeInterval : TimeInterval!
    
    class func intervalWithNowAsStartDate() -> GTInterval {
        let interval = GTInterval()
        interval.startDate = NSDate()
        interval.timeInterval = -1
        return interval
    }
    
    func end() {
        self.endDate = NSDate()
        setEndDate(endDate: self.endDate)
    }
    
    func setEndDate(endDate: NSDate) {
        self.endDate = endDate
        self.timeInterval = self.endDate.timeIntervalSince(self.startDate as Date)
    }
    
    func intervalAsSeconds() -> NSNumber {
        let seconds = String(format: "%.1f", self.timeInterval)
        let myInteger : Int = NSString(string: seconds).integerValue
        let myNumber = NSNumber(value:myInteger)
        return myNumber
    }
    
    func intervalAsMinutes() -> Int {
        let minutes = self.timeInterval / kAnalyticsSecondsPerMinute
        let minutesString = String(format: "%.1f", minutes)
        return Int(minutesString)!
    }
    
    func intervalAsHours() -> Int {
        let hours = self.timeInterval / kAnalyticsSecondsPerHour
        let hoursString = String(format: "%.1f", hours)
        return Int(hoursString)!
    }
    
    
}
