//
//  Comment.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class Comment {
    
    // MARK: Properties
    var userID: String
    var txtCommemt: String
    
    // MARK: Constructor
    init(userID: String, txtComment: String) {
        self.userID = userID
        self.txtCommemt = txtComment
    }
    
    // MARK: Methods
    static func transform(from dic: [String: Any]) -> Comment? {
        guard let userID = dic["userID"] as? String else { return nil }
        guard let txtComment = dic["comment"] as? String else { return nil }
        return Comment(userID: userID, txtComment: txtComment)
    }
}
