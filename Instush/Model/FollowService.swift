//
//  FollowService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 21/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class FollowService {
    
    // MARK: Properties
    static var shared = FollowService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: Methods
    func follow(after followedUserID: String, by followingUserID: String, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        let followersPath = String(format: "followers/%@", followedUserID)
        let followingPath = String(format: "following/%@", followingUserID)
        ServiceManager.database.setValue(path: followersPath, dataID: followingUserID, data: "true") { (error: Error?) in
            if error != nil { onError?(error!); return }
            ServiceManager.database.setValue(path: followingPath, dataID: followedUserID, data: "true", completion: { (error: Error?) in
                if error != nil { onError?(error!); return }
                PostService.shared.getPosts(ofUser: followedUserID){ (post: Post) in
                    ServiceManager.database.setValue(path: "feed/" + followingUserID, dataID: post.postID, data: "true", completion: {(error: Error?) in
                        if error != nil { onError?(error!); return }
                        onSuccess?()
                    })
                }
            })
        }
    }
    
    func unfollow(from unfollowedUserID: String, by followingUser: String, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        let followersPath = String(format: "followers/%@", unfollowedUserID)
        let followingPath = String(format: "following/%@", followingUser)
        ServiceManager.database.removeValue(path: followersPath, dataID: followingUser) { (error: Error?) in
            if error != nil { onError?(error!); return }
            ServiceManager.database.removeValue(path: followingPath, dataID: unfollowedUserID, completion: { (error: Error?) in
                if error != nil { onError?(error!); return }
                ServiceManager.database.getKeys(path: "user-posts/" + unfollowedUserID, completion: { (postsID: [String]) in
                    ServiceManager.database.removeAllValues(path: "feed/" + followingUser, dataIDs: postsID, onSuccess: {
                        onSuccess?()
                    }, onError: { (error: Error) in
                        onError?(error)
                    })
                })
            })
        }
    }
    
    func getFollowers(after userID: String, onGetNewFollower: @escaping (User?)->(Void)) {
        let followersPath = String(format: "followers/%@", userID)
        ServiceManager.database.isExist(path: followersPath) { (isPathExist: Bool) in
            if !isPathExist { onGetNewFollower(nil); return }
            ServiceManager.database.listenToKey(toPath: followersPath) { (followerUserID: String) in
                UserService.shared.getUser(by: followerUserID, completion: onGetNewFollower)
            }
        }
    }
    
    func getFollowing(of userID: String, onGetNewFollowing: @escaping (User?)->(Void)){
        let followingPath = String(format: "following/%@", userID)
        ServiceManager.database.isExist(path: followingPath) { (isPathExist: Bool) in
            if !isPathExist { onGetNewFollowing(nil); return }
            ServiceManager.database.listenToKey(toPath: followingPath) { (followedUserID: String) in
                UserService.shared.getUser(by: followedUserID, completion: onGetNewFollowing)
            }
        }
    }
    
    func getFollowersCount(for userID: String, completion: @escaping (Int)->Void) {
        let followersPath = String(format: "followers/%@", userID)
        ServiceManager.database.getChildCount(path: followersPath) { (followersCount: Int) in
            completion(followersCount)
        }
    }
    
    func getFollowingCount(for userID: String, completion: @escaping (Int)->Void) {
        let followingPath = String(format: "following/%@", userID)
        ServiceManager.database.getChildCount(path: followingPath) { (followingCount: Int) in
            completion(followingCount)
        }
    }
    
    func isAppUserFollowing(after userID: String, completion: @escaping (Bool)->(Void)) {
        guard let appUserID = UserService.shared.getCurrentUserID() else { return }
        let followingPath = String(format: "following/%@/%@", appUserID, userID)
        ServiceManager.database.getValue(path: followingPath) { (val: String?) in
            guard let _ = val else { completion(false); return }
            completion(true)
        }
    }
}
