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
            timeText = "NOW"
        }
        if differenceTime.second! > 0 && differenceTime.minute! == 0 {
            timeText = differenceTime.second == 1 ? "1 SECOND AGO" : "\(differenceTime.second!) SECONDS AGO"
        }
        if differenceTime.minute! > 0 && differenceTime.hour == 0 {
            timeText = differenceTime.minute == 1 ? "1 MINUTE AGO" : "\(differenceTime.minute!) MINUTES AGO"
        }
        if differenceTime.hour! > 0 && differenceTime.day == 0 {
            timeText = differenceTime.hour == 1 ? "1 HOUR AGO" : "\(differenceTime.hour!) HOURS AGO"
        }
        if differenceTime.day! > 0 && differenceTime.weekOfMonth == 0 {
            timeText = differenceTime.day == 1 ? "1 DAY AGO" : "\(differenceTime.day!) DAYS AGO"
        }
        if differenceTime.weekOfMonth! > 0 {
            timeText = differenceTime.weekOfMonth == 1 ? "1 WEEK AGO" : "\(differenceTime.weekOfMonth!) WEEKS AGO"
        }
        return (timeText)
    }
}
