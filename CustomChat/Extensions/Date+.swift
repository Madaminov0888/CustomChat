//
//  Date+.swift
//  CustomChat
//
//  Created by Muhammadjon Madaminov on 16/03/24.
//

import Foundation
import SwiftUI


extension Date {
    static func formatDateString(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Not this year"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            return dateFormatter.string(from: date)
        }
    }
    
    static func formatDateStringHeader(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Not this year"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        let dayMonthFormatter = DateFormatter()
        dayMonthFormatter.dateFormat = "d MMMM"
        
        let dayMonthYearFormatter = DateFormatter()
        dayMonthYearFormatter.dateFormat = "d MMMM yyyy"
        
        let isSameYear = calendar.isDate(date, equalTo: now, toGranularity: .year)
        
        if isSameYear {
            return dayMonthFormatter.string(from: date)
        } else {
            return dayMonthYearFormatter.string(from: date)
        }
    }

    
    static func formatDateStringTimeOnly(_ dateString: String) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Not this year"
        }
        
        let calendar = Calendar.current
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        return timeFormatter.string(from: date)
        
    }
}
