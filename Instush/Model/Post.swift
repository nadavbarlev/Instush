//
//  Post.swift
//  Instush
//
//  Created by Nadav Bar Lev on 12/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class Post {
    
    // MARK: Properties
    var postID  : String
    var userID  : String
    var photoURL: String
    var caption : String
    var timestamp: String
    var likesCount: Int
    var usersLike: Dictionary<String, Bool>
    
    // MARK: Constructor
    private init(postID: String, userID: String, photoURL: String, caption: String, timestamp: String, likesCount: Int, usersLike: [String:Bool]) {
        self.postID = postID
        self.userID = userID
        self.photoURL = photoURL
        self.caption  = caption
        self.timestamp = timestamp
        self.likesCount = likesCount
        self.usersLike = usersLike
    }
    
    // MARK: Methods
    static func transform(from dic: [String: Any], id: String) -> Post? {
        guard let userID = dic["userID"] as? String else { return nil }
        guard let photoURL = dic["photoURL"] as? String else { return nil }
        let timestamp = dic["timestamp"] as? String ?? "0" // TODONADAV
        let caption = dic["caption"] as? String ?? ""
        let likeCount = dic["likesCount"] as? Int ?? 0
        let usersLike = dic["likes"] as? [String:Bool] ?? [:]
        return Post(postID: id, userID: userID, photoURL: photoURL, caption: caption, timestamp: timestamp, likesCount: likeCount, usersLike: usersLike)
    }
}
