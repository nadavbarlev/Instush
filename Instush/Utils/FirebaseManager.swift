//
//  FirebaseManager.swift
//  Instush
//
//  Created by Nadav Bar Lev on 07/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class FirebaseAuthService : AuthService {
    
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
    
    func signUp(withEmail email: String,
                          password: String,
                          username: String,
                          imageData: Data,
                          onSuccess:(()->(Void))?,
                          onError:((Error)->(Void))?) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil { onError?(error!); return }
            guard let userID = authResult?.user.uid else { return }
            ServiceManager.storage.save(for: userID, path: "profile_images", data: imageData, onSuccess: { (url:URL) in
                let dataToSave = ["username": username, "email": email, "profileImagePath": url.absoluteString]
                ServiceManager.database.setValue(for: userID, path: "users", data: dataToSave)
                onSuccess?()
            }, onError: { (error) in
                print(error)
            })
        }
    }
}

class FirebaseDatabaseService: DatabaseService {
    
    // MARK: Properties
    let dbRef = Database.database().reference()
    
    func setValue(for userID: String, path: String, data: [String:String]) {
        let fullPathDatabaseRef = dbRef.child(path).child(userID)
        fullPathDatabaseRef.setValue(data)
    }
}

class FirebaseStorageService: StorageService {
    
    // MARK: Properties
    let storageRef = Storage.storage().reference()
   
    // MARK: Methods
    func save(for userID: String, path: String, data: Data, onSuccess: ((URL)->(Void))?, onError: ((Error)->(Void))?) {
        let fullPathStorageRef = storageRef.child(path).child(userID)
        fullPathStorageRef.putData(data, metadata: nil) { (metadata: StorageMetadata?, error: Error?) in
            if error != nil { onError?(error!); return }
            fullPathStorageRef.downloadURL { (url: URL?, error: Error?) in
                if error != nil { onError?(error!); return }
                onSuccess?(url!)
            }
        }
    }
}
