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

var requestTabBarItem = UITabBarItem()
var careplanTabBarItem = UITabBarItem()


// Base Url

//let baseUrl: String = "http://54.244.176.114:3000/"
//let baseUrl: String = "http://localhost:3000/"
let baseUrl: String = "http://54.212.229.198:3000/"


let conditionsArray : NSArray = ["All conditions".localized,"Fasting".localized, "After Breakfast".localized, "Before Lunch".localized, "After Lunch".localized, "Before Dinner".localized, "After Dinner".localized, "Bedtime".localized]

let conditionsArrayEng : NSArray = ["All conditions","Fasting", "After Breakfast", "Before Lunch", "After Lunch", "Before Dinner", "After Dinner", "Bedtime"]
let frequnecyArray : NSArray = ["Once a week".localized, "Twice a week".localized, "Thrice a week".localized, "Once daily".localized, "Twice daily".localized]
let frequencyArrayEng : NSArray = ["Once a week", "Twice a week", "Thrice a week", "Once daily", "Twice daily"]


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
    static let doctorTabBarViewController   = "DoctorTabBarView"
    static let carePlanViewController       = "CarePlanView"
    static let historyViewController        = "HistoryView"
    static let messagesViewController       = "MessagesView"
    static let contactViewController        = "ContactsListView"
    static let chatViewController           = "ChatView"
    static let historyMainViewController    = "HistoryMainView"
    static let ReportViewController         = "ReportView"
    static let editMedicationViewController = "EditMedicationView"
    static let patientInfoViewController    = "PatientInfoView"
    static let requestViewController        = "RequestListView"
    
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
    
    static let isLoggedIn               = "isLoggedIn"
    static let loggedInUserID           = "loggedInUserID"
    static let loggedInUserEmail        = "loggedInUserEmail"
    static let loggedInUserPassword     = "loggedInUserPassword"
    static let loggedInUsername         = "loggedInUsername"
    static let loggedInUserFullname     = "loggedInUserFullname"
    static let loggedInUserType         = "loggedInUserType"
    static let selectedPatientID        = "selectedPatientID"
    static let selectedPatientHCNumber  = "selectedPatientHCNumber"
    static let recipientTypesArray      = "recipientTypesArray"
    static let recipientIDArray         = "recipientIDArray"
    static let deviceToken              = "deviceToken"
    static let groupChat                = "groupChat"
    static let taskID                   = "taskID"
    static let selectedNoOfDays         = "selectedNoOfDays"
    static let totalBadgeCounter        = "totalBadgeCounter"
}

// MARK: - Api Methods
struct ApiMethods{
    

    static let login       = "login"
    static let getPatients = "getpatients"
    static let updatePatient = "updateuser"
    static let getPatDoctors  = "getPatDoctors"
    static let getPatEducators = "getPatEducators"
    static let getEduDoctors  = "getEduDoctors"
    static let getEduPatients = "getEduPatients"
    static let getDocPatients   = "getDocPatients"
    static let getDocEducators = "getDocEducators"
    static let getglucose     = "getglucose"
    static let getglucoseDays = "getglucoseDays"
    static let getcareplan     = "getcareplanUpdated"
    static let getcareplanReadings = "getcareplanReadings"
    static let getcareplanConstantReadings = "getcareplanConstantReadings"
    static let addcareplan     = "addcareplan"
    static let updatecareplan = "updatecareplan"
    static let updatecareplanReadings = "updatecareplanReadings"
    static let deletecareplan = "deletecareplan"
    static let getglucoseDaysCondition = "getglucoseDaysCondition"
    static let getglucoseDaysConditionChart = "getglucoseDaysConditionChart"
    static let saveGlucose = "saveglucose"
    static let getUserProfile = "getUserProfile"
    static let getdocName = "getDocName"
    static let getTasks = "getTasks"
    static let getMedicationArray = "medicationArray"
    static let doctorApprove = "doctorApprove"
    static let doctorDecline = "doctorDecline"
    static let getDoctorRequestReport = "getdoctorreport"
    static let getDoctorGroupReport = "getdoctorsingle"
    static let saveEducatorReport = "savetask"
    static let getEducatorGroupReport = "geteducatorreport"
    static let getChartConditionData = "getChartConditionData"
    static let canceleMeds = "cancelDeleteMeds"
    static let getRequestCount = "getRequestCount"
    static let updateReadBy = "requestUpdateEducator"
    static let saveDoctorChanges = "saveDoctorChanges"
    static let addcareplanReadings = "addcareplanReadings"
     static let deletecareplanReadings = "deletecareplanReadings"
    
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
    static let addMedication    = "AddMedicationNotification"
    static let noOfDays         = "NoOfDaysNotification"
    static let addNewMedication    = "AddNewMedicationNotification"
    static let addNewReading    = "AddNewReadingNotification"
    
    static let ReportListHistoryView = "ReportListHistoryView"
    static let ReportChartHistoryView = "ReportChartHistoryView"
    
    static let DoctorReportListHistoryView = "DoctorReportListHistoryView"
    static let DoctorReportChartHistoryView = "DoctorReportChartHistoryView"
    
    static let closeAddNewMedication    = "CloseAddNewMedicationNotification"
    static let selectMedicationNotification    = "SelectMedicationNotification"
    static let editMedicationNotification    = "EditMedicationNotification"
    
    static let newReadingView   = "NewReadingView"
}

// MARK: - Colors
struct Colors{
    static let userTypeSelectedColor: UIColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
    static let incomingMSgColor: UIColor = UIColor(red: 230.0/255.0, green: 243.0/255.0, blue: 247.0/255.0, alpha: 1)
    static let outgoingMsgColor: UIColor = UIColor(red: 214.0/255.0, green: 225.0/255.0, blue: 244.0/255.0, alpha: 1)
    // static let outgoingMsgColor: UIColor = UIColor(red: 126.0/255.0, green: 213.0/255.0, blue: 217.0/255.0, alpha: 1)
    static let historyHeaderColor: UIColor = UIColor(red: 0.0/255.0, green: 156.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    static let oldMedicationTableBGColor: UIColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
      static let medicationConditionGrayColor: UIColor = UIColor(red: 125.0/255.0, green: 125.0/255.0, blue: 125.0/255.0, alpha: 1.0)
    
    static let chatHeaderColor: UIColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
    
    static let glucoseReadingColor: UIColor = UIColor(red: 0.0/255.0, green: 103.0/255.0, blue: 108.0/255.0, alpha: 1)
    
    static let DHBackgroundBlue     = UIColor(red: 0.0/255.0, green: 90.0/255.0, blue: 143.0/255.0, alpha: 1.0)
    static let DHBackgroundGreen    = UIColor(red: 0.0/255.0, green: 159.0/255.0, blue: 139.0/255.0, alpha: 1.0)
    static let DHLoginButtonGreen   = UIColor(red: 63.0/255.0, green: 230.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    static let DHTabBarGreen        = UIColor(red: 0.0/255.0, green: 156.0/255.0, blue: 190.0/255.0, alpha: 1.0)
    static let DHIntakeGreen        = UIColor(red: 62.0/255.0, green: 187.0/255.0, blue: 169.0/255.0, alpha: 1.0)
    static let DHConditionBg       = UIColor(red: 0.0/255.0, green: 174.0/255.0, blue: 205.0/255.0, alpha: 1.0)
    static let DHAddConditionBg       = UIColor(red: 68.0/255.0, green: 106.0/255.0, blue: 125.0/255.0, alpha: 1.0)
    
    static let DHLightGray = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    static let DHDarkGray = UIColor(red: 127.0/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
    static let DHPinkRed = UIColor(red: 236.0/255.0, green: 96.0/255.0, blue: 119.0/255.0, alpha: 1.0)
    
    static let DHTabBarItemUnselected = UIColor(red: 0.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    static let DHTabBarWhiteTint = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.7)
    static let ChatTextColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 59.0/255.0, alpha: 1.0)
    
    static let approveButtonGreen = UIColor(red:75.0/255.0, green: 156.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    
    static let PrimaryColor = UIColor(red: 0.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 1.0)
    static let PrimaryColorAlpha = UIColor(red: 0.0/255.0, green: 60.0/255.0, blue: 79.0/255.0, alpha: 0.6)
    
    static let chartHyperHypoColor = UIColor(red: 227.0/255.0, green: 5.0/255.0, blue: 28.0/255.0, alpha: 1.0)
    static let chartNormalColor = UIColor(red: 162.0/255.0, green: 197.0/255.0, blue: 22.0/255.0, alpha: 1.0)
    static let placeHolderColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6)
    static let DefaultplaceHolderColor = UIColor(red: 191.0/255.0, green: 191.0/255.0, blue: 191.0/255.0, alpha: 1.0)
    
    static let chatBackGroundColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 0.6)
}


// MARK: - Fonts
struct Fonts {
    static let healthCardFont: UIFont = UIFont(name: "SFUIText-Light", size: 12)!
    static let SFTextMediumFont: UIFont = UIFont(name: "SFUIText-Medium", size: 14)!
    static let SFTextRegularFont: UIFont = UIFont(name: "SFUIText-Regular", size: 18)!
    static let GothamBoldFont: UIFont = UIFont(name: "Gotham-Bold", size: 15)!
    static let NavBarBtnFont: UIFont = UIFont(name: "SFUIText-Regular", size: 15)!
    static let HistoryHeaderFont: UIFont = UIFont(name: "SFUIText-Bold", size: 14)!
    static let noOfDaysFont: UIFont = UIFont(name: "SFUIText-Regular", size: 14)!
    static let chartFont: UIFont = UIFont(name: "SFUIText-Regular", size: 8)!
    
}

let kButtonRadius : CGFloat = 10.2047
let kLoginScreenName: String = "Login Screen"
let kGIntakeScreenName: String = "G Intake"
let kContactListScreenName: String = "Contact List"
let kPatientInfoScreenName: String = "Patient Info"
let kDialogsScreenName: String = "Dialogs"
let kChatScreenName: String = "Chat"
let kAddMedicationScreenName: String = "Add Medication"
let kMedicationScreenName: String = "Medication"
let kCarePlanReadingScreenName: String = "Care Plan Reading"
let kChartViewScreenName: String = "Chart View"
let kHistoryViewScreenName: String = "History View"
let kReportNewCarePlanScreenName: String = "Report New Care Plan"
let kReportCarePlanScreenName: String = "Report Care Plan"
let kReportChartViewScreenName: String = "Report Chart View"
let kReportHistoryViewScreenName: String = "Report History View"

