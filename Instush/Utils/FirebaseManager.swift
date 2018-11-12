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
    
    func signUp(withEmail email: String,
                          password: String,
                          username: String,
                          imageData: Data,
                          onSuccess:(()->(Void))?,
                          onError:((Error)->(Void))?) {
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if error != nil { onError?(error!); return }
            guard let userID = authResult?.user.uid else { return }
            ServiceManager.storage.save(path: "profile_images", dataID: userID, data: imageData,
            onSuccess: { (url:URL) in
                let dataToSave = ["username": username, "email": email, "profileImagePath": url.absoluteString]
                ServiceManager.database.setValue(path: "users", dataID: userID, data: dataToSave) { (error) in
                    if error != nil { onError?(error!); return }
                     onSuccess?()}
            },
            onError: { (error) in
                onError?(error)
            })
        }
    }
}

class FirebaseDatabaseService: DatabaseService {
    
    // MARK: Properties
    let dbRef = Database.database().reference()
    
    func setValue(path: String, dataID: String, data: [String:String], completion: @escaping (Error?)->Void) {
        let fullPathDatabaseRef = dbRef.child(path).child(dataID)
        fullPathDatabaseRef.setValue(data) { (error, dbRef) in
            completion(error)
        }
    }
    
    func getUniqueId(forPath path: String) -> String? {
        return dbRef.child(path).childByAutoId().key
    }
}

class FirebaseStorageService: StorageService {
    
    // MARK: Properties
    let storageRef = Storage.storage().reference()
   
    // MARK: Methods
    func save(path: String, dataID: String, data: Data, onSuccess: ((URL)->(Void))?, onError: ((Error)->(Void))?) {
        let fullPathStorageRef = storageRef.child(path).child(dataID)
        fullPathStorageRef.putData(data, metadata: nil) { (metadata: StorageMetadata?, error: Error?) in
            if error != nil { onError?(error!); return }
            fullPathStorageRef.downloadURL { (url: URL?, error: Error?) in
                if error != nil { onError?(error!); return }
                onSuccess?(url!)
            }
        }
    }
}
