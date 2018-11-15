//
//  FirebaseManager.swift
//  Instush
//
//  Created by Nadav Bar Lev on 07/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class ServiceManager {
    static let auth    : AuthService     = FirebaseAuthService()
    static let database: DatabaseService = FirebaseDatabaseService()
    static let storage : StorageService  = FirebaseStorageService()
}

// MARK: Protocols
protocol AuthService {
    func getUserID() -> String?
    func isUserSignedIn() -> Bool
    func signIn(withEmail email: String, password: String, onSuccess:(()->(Void))?, onError:((Error)->(Void))?)
    func signUp(withEmail email: String, password: String, username: String, imageData: Data, onSuccess:(()->(Void))?, onError:((Error)->(Void))?)
    func signOut(onSuccess:(()->(Void))?, onError:((Error)->(Void))?)
}

protocol DatabaseService {
    func getUniqueId(forPath path: String) -> String?
    func setValue(path: String, dataID: String, data: [String:String], completion: @escaping (Error?)->Void)
    func getValue(path: String, completion: @escaping (Dictionary<String,Any>?)->Void)
    func listen(toPath path: String, listener: @escaping (Dictionary<String,Any>?)->Void)
}

protocol StorageService {
    func save(path: String, dataID: String, data: Data, onSuccess: ((URL)->(Void))?, onError: ((Error)->(Void))?)
}

