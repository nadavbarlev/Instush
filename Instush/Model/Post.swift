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
    var timestamp: Int
    var likesCount: Int
    var usersLike: Dictionary<String, Bool>
    
    // MARK: Constructor
    init(postID: String, userID: String, photoURL: String, caption: String, timestamp: Int, likesCount: Int, usersLike: [String:Bool]) {
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
        let timestamp = dic["timestamp"] as? Int ?? 0
        let caption = dic["caption"] as? String ?? ""
        let likeCount = dic["likesCount"] as? Int ?? 0
        let usersLike = dic["likes"] as? [String:Bool] ?? [:]
        return Post(postID: id, userID: userID, photoURL: photoURL, caption: caption, timestamp: timestamp, likesCount: likeCount, usersLike: usersLike)
    }
    
    static func transform(from array: [String]) -> Post? {
        guard let timestamp =  Int(array[4]) else { return nil }
        guard let likesCount = Int(array[5]) else { return nil }
        return Post(postID: array[0], userID: array[1], photoURL: array[2], caption: array[3], timestamp: timestamp, likesCount: likesCount, usersLike: [:])
    }
}
