//
//  FirebaseAuthService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService : AuthService {
    
    // MARK: API Methods
    func getUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func isUserSignedIn() -> Bool {
        if Auth.auth().currentUser != nil { return true }
        return false
    }
    
    func signIn(withEmail email: String,
                password: String,
                onSuccess:(()->(Void))?,
                onError:((Error)->(Void))?) {
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil { onError?(error!); return }
            onSuccess?()
        }
    }
    
    func signOut(onSuccess:(()->(Void))?,
                 onError:((Error)->(Void))?) {
        do { try Auth.auth().signOut(); onSuccess?() }
        catch let error { onError?(error) }
    }
    
    func signUp(withEmail email: String, password: String, username: String, imageData: Data, onSuccess:(()->(Void))?, onError:((Error)->(Void))?) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil { onError?(error!); return }
            guard let userID = authResult?.user.uid else { return }
            ServiceManager.storage.save(path: "profile_images", dataID: userID, data: imageData, onSuccess: { (url:URL) in
                let dataToSave = ["username": username, "username_lowercase": username.lowercased() ,"email": email, "profileImagePath": url.absoluteString]
                ServiceManager.database.setValue(path: "users", dataID: userID, data: dataToSave) { (error) in
                    if error != nil { onError?(error!); return }
                    onSuccess?()
                }
            }, onError: { (error:Error) in
                onError?(error)
            })
        }
    }
}


