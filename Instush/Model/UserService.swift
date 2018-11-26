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
    
    func searchUsers(withText text: String, completion: @escaping (User)->Void) {
        ServiceManager.database.search(for: text, in: "users", orderBy: "username_lowercase", maxResults: 3) { (UserID:String, dicUser:[String : Any]) in
            FollowService.shared.isAppUserFollowing(after: UserID) { (isFollowing: Bool) in
                guard let userToReturn = User.transform(from: dicUser, key: UserID, isFollowing: isFollowing) else { return }
                completion(userToReturn)
            }
        }
    }
    
}
