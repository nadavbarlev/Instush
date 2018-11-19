//
//  PostService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Firebase

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
    
    func share(imgPostID: String, imgPostData: Data, userID: String, caption: String, onSuccess:(()->(Void))?, onError:((String)->(Void))?) {
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
    
    func Like(postID: String, completion: @escaping (Post)->Void) {
        ServiceManager.database.update(path: "posts/" + postID, updateDataBlock: { (post: [String:Any]) in
            guard let userID = ServiceManager.auth.getUserID() else { return post }
            return self.updatePostLike(userID: userID, postData: post)
        }, onSuccess: { (dataPost: [String:Any]) in
            guard let post = Post.transform(from: dataPost, id: postID) else { return }
            completion(post)
        },
        onError: {(error: Error) in
            print(error.localizedDescription)
        })
    }
    
    func updatePostLike(userID: String, postData: [String:Any]) -> [String:Any] {
        var changedPostData = postData
        var likes = postData["likes"] as? [String : Bool] ?? [:]
        var likesCount = postData["likesCount"] as? Int ?? 0
        
        if let _ = likes[userID] {
            likesCount -= 1
            likes.removeValue(forKey: userID)
        } else {
            likesCount += 1
            likes[userID] = true
        }
        
        changedPostData["likesCount"] = likesCount as Any?
        changedPostData["likes"] = likes as Any?
        return changedPostData
    }
}
