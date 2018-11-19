//
//  PostViewModel.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class PostViewModel {
    
    // MARK: Properties
    var username: String
    var profileImgURL: String
    var postImgURL: String
    var caption : String
    var likeCount: String
    var isUserLiked: Bool
    
    // MARK: Constructor
    init(post: Post, user: User, userID: String) {
        self.username = user.username
        self.profileImgURL = user.profileImgURL
        self.postImgURL = post.photoURL
        self.caption = post.caption
        self.likeCount = String(post.likesCount)
        self.isUserLiked = post.usersLike[userID] != nil
    }
}
