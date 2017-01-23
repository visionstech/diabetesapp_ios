//
//  Constants.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


import Foundation

let kChatPresenceTimeInterval:TimeInterval = 45
let kDialogsPageLimit:UInt = 100
let kMessageContainerWidthPadding:CGFloat = 40.0

// Base Url
let baseUrl: String = "http://54.212.229.198:3000/"
// Base Local Server Url
//let baseUrl: String = "http://192.168.25.43:3000/"



let conditionsArray : NSArray = ["All conditions".localized,"Fasting".localized, "Snacks".localized, "Exercise".localized,"Pre Breakfast".localized, "Post Breakfast".localized, "Pre Lunch".localized, "Post Lunch".localized, "Pre Dinner".localized, "Post Dinner".localized, "Bedtime".localized]
let frequnecyArray : NSArray = ["1 time a day".localized, "2 times a day".localized, "3 times a day".localized, "4 times a day".localized, "5 times a day".localized]


/*  ServicesManager
	...
	func downloadLatestUsers(successBlock:(([QBUUser]?) -> Void)?, errorBlock:((NSError) -> Void)?) {
	
	let enviroment = Constants.QB_USERS_ENVIROMENT
	
	self.usersService.searchUsersWithTags([enviroment])
	*/
class Constants {
    
    class var QB_USERS_ENVIROMENT: String {
        
        #if DEBUG
            return "dev"
        #elseif QA
            return "qbqa"
        #else
            assert(false, "Not supported build configuration")
            return ""
        #endif
        
    }
}

// MARK: - UserType
struct userType {
    static let doctor = 1
    static let patient = 2
    static let educator = 3
}

// MARK: - History Days
struct HistoryDays {
    static let days_today = 0
    static let days_7 = 1
    static let days_14 = 2
    static let days_30 = 3
}


// MARK: - View Identifiers
struct ViewIdentifiers{
    
    static let dialogsViewController        = "DialogsViewController"
    static let tabBarViewController         = "TabBarView"
    static let doctorTabBarViewController    = "DoctorTabBarView"
    static let carePlanViewController       = "CarePlanView"
    static let historyViewController        = "HistoryView"
    static let messagesViewController       = "MessagesView"
    static let contactViewController        = "ContactsListView"
    static let chatViewController           = "ChatView"
    static let historyMainViewController    = "HistoryMainView"
    static let ReportViewController         = "ReportView"
    static let editMedicationViewController = "EditMedicationView"
    
}

// MARK: - Cell Identifiers
struct CellIdentifiers{
    
    static let medicationCell = "medicationCell"
    static let readingsCell   = "readingsCell"
    static let historyCell    = "historyCell"
    static let headerView     = "headerView"
    static let messagesViewController = "MessagesView"
}

// MARK: - UserDefaults
struct userDefaults{
    
    static let isLoggedIn           = "isLoggedIn"
    static let loggedInUserID       = "loggedInUserID"
    static let loggedInUserEmail    = "loggedInUserEmail"
    static let loggedInUserPassword = "loggedInUserPassword"
    static let loggedInUsername     = "loggedInUsername"
    static let loggedInUserType     = "loggedInUserType"
    static let selectedPatientID    = "selectedPatientID"
}

// MARK: - Api Methods
struct ApiMethods{
    
    static let login       = "login"
//    static let login       = "getdataios"
    static let getPatients = "getpatients"
    static let updatePatient = "updatepatient"
    static let getPatDoctors  = "getPatDoctors"
    static let getPatEducators = "getPatEducators"
    static let getDocPatients   = "getDocPatients"
    static let getDocEducators = "getDocEducators"
    static let getEduDoctors =    "getEduDoctors"
    static let getEduPatients =  "getEduPatients"
    
    static let getglucose     = "getglucose"
    static let getglucoseDays = "getglucoseDays"
    static let getcareplan     = "getcareplan"
    static let getcareplanReadings = "getcareplanReadings"
    static let addcareplan     = "addcareplan"
    static let updatecareplan = "updatecareplan"
    static let getglucoseDaysCondition = "getglucoseDaysCondition"
    static let getglucoseDaysConditionChart = "getglucoseDaysConditionChart"
    static let editEducatorReport = "savetask"
    static let getTasks = "getTasks"  
}

// MARK: - GeneralLabels
struct GeneralLabels {
    static let cancel    = "Cancel"
}

// MARK: - ChatInfo
struct ChatInfo {
    static let patientInfo    = "PATIENT_INFO".localized
    static let readingHistory = "READING_HISTORY".localized
    static let carePlan       = "CARE_PLAN".localized
}

// MARK: - VideoAudioCall
struct VideoAudioCall {
    static let audioCall = "Audio Call"
    static let videoCall = "Video Call"
}

// MARK: - Notifications
struct Notifications {
    static let chartHistoryView = "ChartViewNotification"
    static let listHistoryView  = "ListViewNotification"
    static let medicationView   = "MedicationViewNotification"
    static let readingView      = "ReadingViewNotification"
    static let newReadingView   = "NewReadingView"
    static let addMedication    = "AddMedicationNotification"
    static let noOfDays         = "NoOfDaysNotification"
    
    static let ReportListHistoryView = "ReportListHistoryView"
    static let ReportChartHistoryView = "ReportChartHistoryView"
    
    static let DoctorReportListHistoryView = "DoctorReportListHistoryView"
    static let DoctorReportChartHistoryView = "DoctorReportChartHistoryView"
    
}

// MARK: - Colors
struct Colors{
    static let userTypeSelectedColor: UIColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
    static let incomingMSgColor: UIColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1)
    static let outgoingMsgColor: UIColor = UIColor(red: 0/255.0, green: 103.0/255.0, blue: 108.0/255.0, alpha: 1)
    static let historyHeaderColor: UIColor = UIColor(red: 62.0/255.0, green: 187.0/255.0, blue: 169.0/255.0, alpha: 1)
    static let chatHeaderColor: UIColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
    
}

// MARK: - Fonts
struct Fonts {
    static let healthCardFont: UIFont = UIFont(name: "SFUIText-Light", size: 12)!
    static let SFTextMediumFont: UIFont = UIFont(name: "SFUIText-Medium", size: 14)!
    static let SFTextRegularFont: UIFont = UIFont(name: "SFUIText-Regular", size: 18)!
    static let GothamBoldFont: UIFont = UIFont(name: "Gotham-Bold", size: 15)!
    static let NavBarBtnFont: UIFont = UIFont(name: "SFUIText-Regular", size: 15)!
    static let HistoryHeaderFont: UIFont = UIFont(name: "SFUIText-Bold", size: 16)!
    static let noOfDaysFont: UIFont = UIFont(name: "SFUIText-Regular", size: 14)!
    static let chartFont: UIFont = UIFont(name: "SFUIText-Regular", size: 8)!
}




