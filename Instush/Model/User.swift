//
//  User.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class User {
    
    // MARK: Properties
    var userID: String
    var username: String
    var email: String
    var profileImgURL: String
    var isAppUserFollowAfterMe: Bool
    
    // MARK: Constructor
    private init(userID: String, username: String, email: String, profileImgURL: String, isAppUserFollowAfterMe: Bool) {
        self.userID = userID
        self.username = username
        self.email  = email
        self.profileImgURL = profileImgURL
        self.isAppUserFollowAfterMe = isAppUserFollowAfterMe
    }
    
    // MARK: Methods
    static func transform(from dic: [String: Any], key: String, isFollowing: Bool) -> User? {
        guard let username = dic["username"] as? String else { return nil }
        guard let email = dic["email"] as? String else { return nil }
        guard let profileImgURL = dic["profileImagePath"] as? String else { return nil }
        return User(userID: key, username: username, email: email, profileImgURL: profileImgURL, isAppUserFollowAfterMe: isFollowing)
    }
}
