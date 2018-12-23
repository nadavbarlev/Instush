//
//  NotificationManager.swift
//  Instush
//
//  Created by Nadav Bar Lev on 23/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class NotificationManager {
    
    static let followNotification = CustomNotification<String>("com.nadavbarlev.follow")
    static let unfollowNotification = CustomNotification<String>("com.nadavbarlev.unfollow")
    
}
