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
let baseUrl: String = "http://192.168.25.43:3000/"


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
    static let equcator = 3
}

// MARK: - View Identifiers
struct ViewIdentifiers{
    
    static let dialogsViewController  = "DialogsViewController"
    static let tabBarViewController   = "TabBarView"
    static let carePlanViewController = "CarePlanView"
    static let historyViewController  = "HistoryView"
    static let messagesViewController = "MessagesView"
    static let contactViewController  = "ContactsListView"
    static let chatViewController     = "ChatView"
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
    static let loggedInUserType        = "loggedInUserType"
}

// MARK: - Api Methods
struct ApiMethods{
    
    static let login       = "getdataios"
    static let getPatients = "getpatients"
    static let updatePatient = "updatepatient"
    static let getPatDoctors  = "getPatDoctors"
    static let getPatEducators = "getPatEducators"
    static let getDocPatients   = "getDocPatients"
    static let getDocEducators = "getDocEducators"
}

// MARK: - GeneralLabels
struct GeneralLabels {
    static let cancel    = "Cancel"
}

// MARK: - ChatInfo
struct ChatInfo {
    static let patientInfo    = "Patient Info"
    static let readingHistory = "Reading History"
    static let carePlan       = "Care Plan"
}

// MARK: - VideoAudioCall
struct VideoAudioCall {
    static let audioCall = "Audio Call"
    static let videoCall = "Video Call"
}


//MARK: - Colors
struct Colors{
    static let userTypeSelectedColor: UIColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
    
}
