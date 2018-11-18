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
    var username: String
    var email: String
    var profileImgURL: String
    
    // MARK: Constructor
    private init(username: String, email: String, profileImgURL: String) {
        self.username = username
        self.email  = email
        self.profileImgURL = profileImgURL
    }
    
    // MARK: Methods
    static func transform(from dic: [String: Any]) -> User? {
        guard let username = dic["username"] as? String else { return nil }
        guard let email = dic["email"] as? String else { return nil }
        guard let profileImgURL = dic["profileImagePath"] as? String else { return nil }
        return User(username: username, email: email, profileImgURL: profileImgURL)
    }
}
