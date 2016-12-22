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
}

// MARK: - View Identifiers
struct ViewIdentifiers{
    
    static let dialogsViewController  = "DialogsViewController"
    static let tabBarViewController   = "TabBarView"
    
    
}

// MARK: - UserDefaults
struct userDefaults{
    
    static let isLoggedIn           = "isLoggedIn"
    static let loggedInUserID       = "loggedInUserID"
    static let loggedInUserEmail    = "loggedInUserEmail"
    static let loggedInUserPassword = "loggedInUserPassword"
    static let loggedInUsername     = "loggedInUsername"
    
}

// MARK: - Api Methods
struct ApiMethods{
    
    static let login       = "getdataios"
    static let getPatients = "getpatients"
    
    
}

//MARK: - Colors
struct Colors{
    static let userTypeSelectedColor: UIColor = UIColor(red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1)
    
}
