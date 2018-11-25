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
    func isExist(path: String, completion: @escaping (Bool)->Void)
    func setValue(path: String, dataID: String, data: [String:String], completion: @escaping (Error?)->Void)
    func setValue(path: String, dataID: String, data: String, completion: @escaping (Error?)->Void)
    func getValue(path: String, completion: @escaping (Dictionary<String,Any>?)->Void)
    func getValue(path: String, completion: @escaping (String?)->Void)
    func getKeys(path: String, completion: @escaping ([String])->Void)
    func getKeyandValue(path: String, completion: @escaping (String, Dictionary<String,Any>?)->Void) 
    func removeValue(path: String, dataID: String, completion: @escaping (Error?)->Void)
    func removeAllValues(path: String, dataIDs: [String], onSuccess: ()->(Void), onError: @escaping (Error)->Void)
    func listenToValue(toPath path: String, listener: @escaping (Dictionary<String,Any>?)->Void)
    func listenToKey(toPath path: String, listener: @escaping (String)->Void)
    func listenForRemoveKey(toPath path: String, listener: @escaping (String)->Void)
    func listenToValueAndKey(toPath path: String, listener: @escaping (String, Dictionary<String,Any>?)->Void)
    func update(path: String, updateDataBlock: @escaping ([String:Any])->([String:Any]), onSuccess: @escaping ([String:Any])->Void, onError: ((Error)->(Void))?)
}

protocol StorageService {
    func save(path: String, dataID: String, data: Data, onSuccess: ((URL)->(Void))?, onError: ((Error)->(Void))?)
}

