//
//  UserService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseDatabase

class UserService {
    
    // MARK: Properties
    static var shared = UserService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: Methods Auth
    func getCurrentUserID() -> String? {
        return ServiceManager.auth.getUserID()
    }
    
    func isUserSignedIn() -> Bool {
        return ServiceManager.auth.isUserSignedIn()
    }
    
    func signIn(withEmail email: String, password: String, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        ServiceManager.auth.signIn(withEmail: email, password: password, onSuccess: onSuccess, onError: onError)
    }
   
    func signUp(withEmail email: String, password: String, username: String, imageData: Data, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        ServiceManager.auth.signUp(withEmail: email, password: password, username: username, imageData: imageData, onSuccess: onSuccess, onError: onError)
    }
    
    func signOut(onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        ServiceManager.auth.signOut(onSuccess: onSuccess, onError: onError)
    }
    
    func updateInfo(of userID: String, username: String, email: String, imageData: Data, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        ServiceManager.auth.updateCurrentUser(email: email, onSuccess: {
            ServiceManager.storage.save(path: "profile_images", dataID: userID, data: imageData, onSuccess: { (url:URL) in
                let pathToUpdate = String(format: "users/%@", userID)
                let dataToUpdate = ["username": username, "username_lowercase": username.lowercased() ,"email": email, "profileImagePath": url.absoluteString]
                ServiceManager.database.update(path: pathToUpdate, newValues: dataToUpdate, onSuccess: {
                    onSuccess?()
                }, onError: { (error:Error) in
                    onError?(error)
                })
            }, onError: { (error:Error) in
                onError?(error)
            })
        }, onError: { (error:Error) in
            onError?(error)
        })
    }
    
    // MARK: Methods Database
    func getUser(by id: String, completion: @escaping (User)->Void) {
        ServiceManager.database.getValue(path: "users/" + id) { (data: Dictionary<String, Any>?) in
            guard let dicUser = data else { return }
            FollowService.shared.isAppUserFollowing(after: id) { (isFollowing: Bool) in
                guard let userToReturn = User.transform(from: dicUser, key: id, isFollowing: isFollowing) else { return }
                completion(userToReturn)
            }
        }
    }
    
    func getUser(byUsername username: String, completion: @escaping (User)->Void) {
        ServiceManager.database.search(for: username, in: "users", field: "username_lowercase") { (UserID:String, dicUser:[String : Any]) in
            FollowService.shared.isAppUserFollowing(after: UserID) { (isFollowing: Bool) in
                guard let userToReturn = User.transform(from: dicUser, key: UserID, isFollowing: isFollowing) else { return }
                completion(userToReturn)
            }
        }
    }
    
    func searchUsers(withText text: String, completion: @escaping (User)->Void) {
        ServiceManager.database.contains(text: text, in: "users", orderBy: "username_lowercase", maxResults: 4) { (UserID:String, dicUser:[String : Any]) in
            FollowService.shared.isAppUserFollowing(after: UserID) { (isFollowing: Bool) in
                guard let userToReturn = User.transform(from: dicUser, key: UserID, isFollowing: isFollowing) else { return }
                completion(userToReturn)
            }
        }
    }
    
    // MARK: Methods Cache
    func dropTable() {
        ServiceManager.cache.delete(name: "USERS", onSuccess: {
            print("Success - dropTable")
        }, onError: {
            print("Error - dropTable")
        })
    }
    
    func createTable()  {
        ServiceManager.cache.create(name: "USERS", data: "(USER_ID TEXT PRIMARY KEY, USER_NAME TEXT, EMAIL TEXT, PROFILE_IMG_URL TEXT, IS_APP_USER_FOLLOW TEXT)",
        onSuccess: {
            print("Success - createTable")
        }, onError: {
            print("Error - createTable")
        })
    }
    
    func saveCache(users: [User]) {
        for user in users {
            var userAsString = [String]()
            userAsString.append(user.userID)
            userAsString.append(user.username)
            userAsString.append(user.email)
            userAsString.append(user.profileImgURL)
            userAsString.append(user.isAppUserFollowAfterMe ? "TRUE" : "FALSE")
            ServiceManager.cache.save(name: "USERS", dataToSave: userAsString, onSuccess: {
                print("User saved locally")
            }, onError: {
                print("Faild to save post locally")
            })
        }
    }
}
