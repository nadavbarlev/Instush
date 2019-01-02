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
    
    // MARK: API Methods - Sever
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
    
    func share(imgPostID: String, imgPostData: Data, userID: String, caption: String, onSuccess:((String)->(Void))?, onError:((String)->(Void))?) {
        ServiceManager.storage.save(path: "posts", dataID: imgPostID, data: imgPostData, onSuccess: { (imgUrl:URL) in
            guard let postID = ServiceManager.database.getUniqueId(forPath: "posts") else { return }
            let postTimestamp = Int(NSDate().timeIntervalSince1970)
            let dicPost: [String : Any] = ["photoURL": imgUrl.absoluteString, "caption": caption, "userID": userID, "timestamp": postTimestamp]
            ServiceManager.database.setValue(path: "posts", dataID: postID, data: dicPost) { (error: Error?) in
                if error != nil { onError?(error!.localizedDescription); return  }
                HashTagService.shared.extract(from: caption, postID: postID)
                ServiceManager.database.setValue(path: "user-posts/" + userID, dataID: postID, data: "true", completion: { (error: Error?) in
                    if error != nil { onError?(error!.localizedDescription); return }
                    ServiceManager.database.setValue(path: "feed/" + userID, dataID: postID, data: ["timestamp": -postTimestamp], completion: { (error: Error?) in
                        if error != nil { onError?(error!.localizedDescription); return }
                        onSuccess?(postID)
                        return
                    })
                })
            }
        }, onError: { (error: Error) in
            onError?(error.localizedDescription)
        })
    }
    
    func delete(post: Post, onSuccess:(()->(Void))?, onError:((String)->(Void))?) {
        ServiceManager.storage.delete(url: post.photoURL, onSuccess: {
            ServiceManager.database.removeValue(path: "posts", dataID: post.postID) { (error: Error?) in
                if (error != nil) { onError?(error!.localizedDescription); return }
                ServiceManager.database.removeValue(path: "user-posts/" + post.userID, dataID: post.postID) { (error: Error?) in
                    if (error != nil) { onError?(error!.localizedDescription); return }
                    ServiceManager.database.removeValue(path: "feed/" + post.userID, dataID: post.postID) { (error: Error?) in
                        if (error != nil) { onError?(error!.localizedDescription); return }
                        onSuccess?()
                    }
                }
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
    
    func onPostFeedRemove(from userID: String, completion: @escaping (String)->Void) {
        let userFeedPostsPath = String(format: "feed/%@", userID)
        ServiceManager.database.listenForRemoveKey(toPath: userFeedPostsPath) { (postID: String) in
            completion(postID)
        }
    }
    
    func getFeedPosts(of userID: String, recent count: Int, end timestamp: Int?, completion: @escaping ([(Post, User)]?)->Void) {
        let userFeedPostsPath = String(format: "feed/%@", userID)
        ServiceManager.database.isExist(path: userFeedPostsPath) { (isPathExist: Bool) in
            if (!isPathExist) { completion(nil); return }
            let dispatchGroup = DispatchGroup()
            var feedData = [(Post, User)]()
            ServiceManager.database.getKeys(from: userFeedPostsPath, orderBy: "timestamp", end: timestamp, limit: count) { (postsID: [String]) in
                for postID in postsID {
                    dispatchGroup.enter()
                    let postPath = String(format: "posts/%@", postID)
                    ServiceManager.database.getValue(path: postPath, completion: { (data: Dictionary<String, Any>?) in
                        guard let dicPost = data else { return }
                        guard let post = Post.transform(from: dicPost, id: postID) else { return }
                        UserService.shared.getUser(by: post.userID) { (user: User) in
                            feedData.append((post, user))
                            dispatchGroup.leave()
                        }
                    })
                }
                
                dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                    feedData.sort(by: { $0.0.timestamp > $1.0.timestamp })
                    completion(feedData)
                })
            }
        }
    }
    
    func getMostPopularPosts(count: Int, completion: @escaping ([Post])->Void) {
        let dispatchGroup = DispatchGroup()
        var popularPosts = [Post]()
        ServiceManager.database.getKeys(from: "posts", orderBy: "likesCount", end: nil, limit: count) { (postsID: [String]) in
            for postID in postsID {
                dispatchGroup.enter()
                let postPath = String(format: "posts/%@", postID)
                ServiceManager.database.getValue(path: postPath, completion: { (data: Dictionary<String, Any>?) in
                    guard let dicPost = data else { return }
                    guard let post = Post.transform(from: dicPost, id: postID) else { return }
                    popularPosts.append(post)
                    dispatchGroup.leave()
                })
            }
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                completion(popularPosts)
            })
        }
    }
    
    // MARK: API Methods - Cache
    func createTable(completion: ((Bool)->Void)? = nil)   {
        let tableName   = "POSTS"
        let tableColumn = "(POST_ID TEXT PRIMARY KEY, USER_ID TEXT, PHOTO_URL TEXT, CAPTION TEXT, TIMESTAMP INTEGER, LIKE_COUNT INTEGER)"
        ServiceManager.cache.create(name: tableName, data: tableColumn, onSuccess: {
            completion?(true)
        }, onError: {
            completion?(false)
        })
    }
    
    func dropTable(completion: ((Bool)->Void)? = nil)  {
        let tableName = "POSTS"
        ServiceManager.cache.delete(name: tableName, onSuccess: {
            completion?(true)
        }, onError: {
            completion?(false)
        })
    }
    
    func saveCache(posts: [Post], completion: ((Bool)->Void)? = nil) {
        for post in posts {
            var postAsString = [String]()
            postAsString.append(post.postID)
            postAsString.append(post.userID)
            postAsString.append(post.photoURL)
            postAsString.append(post.caption)
            postAsString.append(String(post.timestamp))
            postAsString.append(String(post.likesCount))
            ServiceManager.cache.save(name: "POSTS", dataToSave: postAsString, onSuccess: {
                 completion?(true)
            }, onError: {
                completion?(false)
            })
        }
    }
    
    func getCache(completion: @escaping ([(Post, User)]?)->Void) {
        
        /* Gets Posts and users local data */
        var feedData = [(Post, User)]()
        ServiceManager.cache.get(name: "POSTS", onSuccess: { (postsAsString : Array<[String]>) in
            let posts = postsAsString.map { Post.transform(from: $0) }
            ServiceManager.cache.get(name: "USERS", onSuccess: { (usersAsString: Array<[String]>) in
                let users = usersAsString.map { User.transform(from: $0) }.filter { $0 != nil }
    
                /* Insert post and corresponding user into FeedData */
                for post in posts {
                    let user = users.first { $0?.userID == post?.userID }
                    guard let post = post else { return }
                    guard let correspondUser = user else { return }
                    feedData.append((post, correspondUser!))
                }
                completion(feedData)
            },onError: { completion(nil) })
        },onError: { completion(nil) })
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
