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
    
    // MARK: Constructors
    init(username: String, profileImgURL: String, postImgURL: String, caption: String) {
        self.username = username
        self.profileImgURL = profileImgURL
        self.postImgURL = postImgURL
        self.caption = caption
    }
    
    init(post: Post, user: User) {
        self.username = user.username
        self.profileImgURL = user.profileImgURL
        self.postImgURL = post.photoURL
        self.caption = post.caption
    }
}
