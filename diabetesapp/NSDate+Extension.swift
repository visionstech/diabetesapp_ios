//
//  NSDate+Extension.swift
//  DiabetesApp
//
//  Created by User on 1/7/17.
//  Copyright © 2017 Visions. All rights reserved.
//

import Foundation

extension NSDate {
    static func <(lhs: NSDate, rhs: NSDate) -> Bool {
        return lhs.timeIntervalSinceReferenceDate < rhs.timeIntervalSinceReferenceDate
    }
    
    static func >(lhs: NSDate, rhs: NSDate) -> Bool {
        return lhs.timeIntervalSinceReferenceDate > rhs.timeIntervalSinceReferenceDate
    }
    
    class func daySuffix(from date: NSDate) -> String {
        let calendar = Calendar.current
        let dayOfMonth = calendar.component(.day, from: date as Date)
        switch dayOfMonth {
        case 1, 21, 31: return "st".localized
        case 2, 22: return "nd".localized
        case 3, 23: return "rd".localized
        default: return "th".localized
        }
    }
}
