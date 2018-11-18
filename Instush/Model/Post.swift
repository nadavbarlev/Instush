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
    
    // MARK: Constructor
    private init(postID: String, userID: String, photoURL: String, caption: String) {
        self.postID = postID
        self.userID = userID
        self.photoURL = photoURL
        self.caption  = caption
    }
    
    // MARK: Methods
    static func transform(from dic: [String: Any], id: String) -> Post? {
        guard let userID = dic["userID"] as? String else { return nil }
        guard let caption = dic["caption"] as? String else { return nil }
        guard let photoURL = dic["photoURL"] as? String else { return nil }
        return Post(postID: id, userID: userID, photoURL: photoURL, caption: caption)
    }
}
