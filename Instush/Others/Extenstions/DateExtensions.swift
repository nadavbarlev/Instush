//
//  DateExtensions.swift
//  Instush
//
//  Created by Nadav Bar Lev on 02/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

extension Date {
    
    static func differenceInStringFormat(from fromDate: Date, to toDate: Date) -> String {
        let timeComponents = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
        let differenceTime = Calendar.current.dateComponents(timeComponents, from: fromDate, to: toDate)
        var timeText: String = ""
        if differenceTime.second! == 0 {
            timeText = "Now"
        }
        if differenceTime.second! > 0 && differenceTime.minute! == 0 {
            timeText = differenceTime.second == 1 ? "1 second ago" : "\(differenceTime.second!) seconds ago"
        }
        if differenceTime.minute! > 0 && differenceTime.hour == 0 {
            timeText = differenceTime.minute == 1 ? "1 minute ago" : "\(differenceTime.minute!) minutes ago"
        }
        if differenceTime.hour! > 0 && differenceTime.day == 0 {
            timeText = differenceTime.hour == 1 ? "1 hour ago" : "\(differenceTime.hour!) hours ago"
        }
        if differenceTime.day! > 0 && differenceTime.weekOfMonth == 0 {
            timeText = differenceTime.day == 1 ? "1 day ago" : "\(differenceTime.day!) days ago"
        }
        if differenceTime.weekOfMonth! > 0 {
            timeText = differenceTime.weekOfMonth == 1 ? "1 week ago" : "\(differenceTime.weekOfMonth!) weeks ago"
        }
        return (timeText)
    }
}
