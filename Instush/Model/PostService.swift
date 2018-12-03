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
    
    // MARK: API Methods
    func listener(onGetNewPost: @escaping (Post)->Void) {
        ServiceManager.database.listenToValueAndKey(toPath: "posts") { (key: String, data: Dictionary<String, Any>?) in
            guard let dicPost = data else { return }
            guard let newPost = Post.transform(from: dicPost, id: key) else { return }
            onGetNewPost(newPost)
        }
    }
    
    func listener(to postID: String, onPostChanged: @escaping (Post)->Void) {
        let pathPostID = String(format: "posts/%@", postID)
        ServiceManager.database.listenToValue(toPath: pathPostID) { (data: Dictionary<String, Any>?) in
            guard let dicPost = data else { return }
            guard let postChanged = Post.transform(from: dicPost, id: postID) else { return }
            onPostChanged(postChanged)
        }
    }
    
    func getPosts(ofUser userID: String, onGetNewPost: @escaping (Post)->Void) {
        let userPostsPath = String(format: "user-posts/%@", userID)
        ServiceManager.database.listenToKey(toPath: userPostsPath) { (postID: String) in
            let postPath = String(format: "posts/%@", postID)
            ServiceManager.database.getValue(path: postPath, completion: { (data: Dictionary<String, Any>?) in
                guard let dicPost = data else { return }
                guard let newPost = Post.transform(from: dicPost, id: postID) else { return }
                onGetNewPost(newPost)
            })
        }
    }
    
    func share(imgPostID: String, imgPostData: Data, userID: String, caption: String, onSuccess:(()->(Void))?, onError:((String)->(Void))?) {
        ServiceManager.storage.save(path: "posts", dataID: imgPostID, data: imgPostData, onSuccess: { (imgUrl:URL) in
            guard let postID = ServiceManager.database.getUniqueId(forPath: "posts") else { return }
            let postTimestamp = Int(NSDate().timeIntervalSince1970)
            let dicPost = ["photoURL": imgUrl.absoluteString, "caption": caption, "userID": userID, "timestamp": String(postTimestamp)]
            ServiceManager.database.setValue(path: "posts", dataID: postID, data: dicPost) { (error: Error?) in
                if error != nil { onError?(error!.localizedDescription); return  }
                HashTagService.shared.extract(from: caption, postID: postID)
                ServiceManager.database.setValue(path: "user-posts/" + userID, dataID: postID, data: "true", completion: { (error: Error?) in
                    if error != nil { onError?(error!.localizedDescription); return }
                    ServiceManager.database.setValue(path: "feed/" + userID, dataID: postID, data: "true", completion: { (error: Error?) in
                        if error != nil { onError?(error!.localizedDescription); return }
                        onSuccess?()
                        return
                    })
                })
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
    
    func getPostCount(for userID: String, completion: @escaping (Int)->Void) {
        let userPostPath = String(format: "user-posts/%@", userID)
        ServiceManager.database.getChildCount(path: userPostPath) { (postCount: Int) in
            completion(postCount)
        }
    }
    
    func getPost(by postID: String, completion: @escaping (Post)->Void) {
        let pathPostID = String(format: "posts/%@", postID)
        ServiceManager.database.getValue(path: pathPostID) { (data: Dictionary<String, Any>?) in
            guard let dicPost = data else { return }
            guard let post = Post.transform(from: dicPost, id: postID) else { return }
            completion(post)
        }
    }
    
    func getFeedPosts(ofUser userID: String, onAddPost: @escaping (Post?)->Void, onRemovePost: @escaping (String)->Void) {
        let userFeedPostsPath = String(format: "feed/%@", userID)
        ServiceManager.database.isExist(path: userFeedPostsPath) { (isPathExist: Bool) in
            if (!isPathExist) { onAddPost(nil) }
            ServiceManager.database.listenToKey(toPath: userFeedPostsPath) { (postID: String) in
                let postPath = String(format: "posts/%@", postID)
                ServiceManager.database.getValue(path: postPath, completion: { (data: Dictionary<String, Any>?) in
                    guard let dicPost = data else { return }
                    guard let newPost = Post.transform(from: dicPost, id: postID) else { return }
                    onAddPost(newPost)
                })
            }
            ServiceManager.database.listenForRemoveKey(toPath: userFeedPostsPath) { (postID: String) in
                onRemovePost(postID)
            }
        }
    }
   
    // MARK: Private Methods
    private func updatePostLike(userID: String, postData: [String:Any]) -> [String:Any] {
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
