//
//  CommentViewModel.swift
//  Instush
//
//  Created by Nadav Bar Lev on 16/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class CommentViewModel {
    
    // MARK: Properties
    var comment: String
    var username: String
    var profileImgPath: String
    
    // MARK: Constructor
    init(comment: String, username: String, profileImgPath: String) {
        self.comment = comment
        self.username = username
        self.profileImgPath = profileImgPath
    }
    
    init(comment: Comment, user: User) {
        self.comment = comment.txtCommemt
        self.username = user.username
        self.profileImgPath = user.profileImgURL
    }
}
