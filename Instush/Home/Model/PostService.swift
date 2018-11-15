//
//  PostService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class PostService {
    
    // MARK: Properties
    static var shared = PostService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: Methods
    func listener(onGetNewPost: @escaping (Post)->Void) {
        ServiceManager.database.listen(toPath: "posts", listener: { (data: Dictionary<String,Any>?) in
            guard let dicPost = data else { return }
            guard let newPost = Post.transform(from: dicPost) else { return }
            onGetNewPost(newPost)
        })
    }
    
}
