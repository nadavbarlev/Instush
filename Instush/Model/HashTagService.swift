//
//  HashTagService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 02/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class HashTagService {
    
    // MARK: Properties
    static var shared = HashTagService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: API Methods
    func extract(from caption: String, postID: String) {
        let words = caption.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                let path = String(format: "hashtag/%@", word.lowercased())
                ServiceManager.database.setValue (path: path, dataID: postID , data: "true") { _ in }
            }
        }
    }
    
    func search(for hashtag: String, completion: @escaping (Post)->(Void)) {
        let path = String(format: "hashtag/%@", hashtag)
        ServiceManager.database.getKeys(path: path) { (postIDs : [String]) in
            for postID in postIDs {
                PostService.shared.getPost(by: postID, completion: { (post: Post) in
                    completion(post)
                })
            }
        }
    }
    
}
