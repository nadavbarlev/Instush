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
        ServiceManager.database.listenToValueAndKey(toPath: "posts") { (key: String, data: Dictionary<String, Any>?) in
            guard let dicPost = data else { return }
            guard let newPost = Post.transform(from: dicPost, id: key) else { return }
            onGetNewPost(newPost)
        }
    }
    
    func sharePost(imgPostID: String, imgPostData: Data, userID: String, caption: String, onSuccess:(()->(Void))?, onError:((String)->(Void))?) {
        ServiceManager.storage.save(path: "posts", dataID: imgPostID, data: imgPostData, onSuccess: { (imgUrl:URL) in
            guard let postID = ServiceManager.database.getUniqueId(forPath: "posts") else { return }
            let dicPost = ["photoURL": imgUrl.absoluteString, "caption": caption, "userID": userID]
            ServiceManager.database.setValue(path: "posts", dataID: postID, data: dicPost) { (error: Error?) in
                guard let errorMsg = error?.localizedDescription else {
                    onSuccess?(); return
                }
                onError?(errorMsg)
            }
        }, onError: { (error: Error) in
            onError?(error.localizedDescription)
        })
    }
    
}
