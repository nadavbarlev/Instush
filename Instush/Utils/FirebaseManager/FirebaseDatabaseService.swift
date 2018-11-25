//
//  FirebaseDatabaseService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import FirebaseDatabase

class FirebaseDatabaseService: DatabaseService {
    
    // MARK: Computed Properties
    let dbRef = Database.database().reference()
    
    // MARK: API Methods
    func getUniqueId(forPath path: String) -> String? {
        return dbRef.child(path).childByAutoId().key
    }
    
    func isExist(path: String, completion: @escaping (Bool)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() { completion(true); return }
            completion(false)
        }
    }
    
    func listenToValue(toPath path: String, listener: @escaping (Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observe(.childAdded) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            listener(dicToReturn)
        }
    }
    
    func listenToKey(toPath path: String, listener: @escaping (String)->Void) {
        dbRef.child(path).observe(.childAdded) { (snapshot: DataSnapshot) in
            listener(snapshot.key)
        }
    }
    
    func listenToValueAndKey(toPath path: String, listener: @escaping (String, Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observe(.childAdded) { (snapshot: DataSnapshot) in
            let dicKey = snapshot.key
            let dicValue = snapshot.value as? [String:Any]
            listener(dicKey, dicValue)
        }
    }
    
    func listenForRemoveKey(toPath path: String, listener: @escaping (String)->Void) {
        dbRef.child(path).observe(.childRemoved) { (snapshot: DataSnapshot) in
            listener(snapshot.key)
        }
    }
    
    func getValue(path: String, completion: @escaping (Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            completion(dicToReturn)
        }
    }
    
    func getValue(path: String, completion: @escaping (String?)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let valToReturn = snapshot.value as? String
            completion(valToReturn)
        }
    }
    
    func getKeys(path: String, completion: @escaping ([String])->Void) {
        var keys = [String]()
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            for child in snapshot.children {
                let ketToAdd = (child as! DataSnapshot).key
                keys.append(ketToAdd)
            }
            completion(keys)
        }
    }
    
    func getKeyandValue(path: String, completion: @escaping (String, Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let dicKey = snapshot.key
            let dicToReturn = snapshot.value as? [String:Any]
            completion(dicKey, dicToReturn)
        }
    }
    
    func setValue(path: String, dataID: String, data: [String:String], completion: @escaping (Error?)->Void) {
        let fullPathDatabaseRef = dbRef.child(path).child(dataID)
        fullPathDatabaseRef.setValue(data) { (error, dbRef) in
            completion(error)
        }
    }
    
    func setValue(path: String, dataID: String, data: String, completion: @escaping (Error?)->Void) {
        let fullPathDatabaseRef = dbRef.child(path).child(dataID)
        fullPathDatabaseRef.setValue(data) { (error, dbRef) in
            completion(error)
        }
    }
    
    func removeValue(path: String, dataID: String, completion: @escaping (Error?)->Void) {
        let fullPathDatabaseRef = dbRef.child(path).child(dataID)
        fullPathDatabaseRef.removeValue { (error, dbRef) in
            completion(error)
        }
    }
    
    func removeAllValues(path: String, dataIDs: [String], onSuccess: ()->(Void), onError: @escaping (Error)->Void) {
        var isErrorOccured = false
        for dataID in dataIDs {
            var fullPathDatabaseRef = dbRef.child(path).child(dataID)
            fullPathDatabaseRef.removeValue { (error, dbRef) in
                if (error != nil) {
                    onError(error!);
                    isErrorOccured = true
                    return
                }
            }
        }
        
        defer { if (!isErrorOccured) { onSuccess() } }
    }
    
    func update(path: String, updateDataBlock: @escaping ([String:Any])->([String:Any]),
                              onSuccess: @escaping ([String:Any])->Void,
                              onError: ((Error)->(Void))?) {
        var changedData = [String:Any]()
        dbRef.child(path).runTransactionBlock({ (currentData: MutableData) in
            guard let data = currentData.value as? [String:Any] else {
                return TransactionResult.success(withValue: currentData)
            }
            changedData = updateDataBlock(data)
            currentData.value = changedData
            return TransactionResult.success(withValue: currentData)
        }, andCompletionBlock: { (error: Error?, commited: Bool, snapshot: DataSnapshot?) in
            guard let error = error else { onSuccess(changedData); return }
            onError?(error)
        })
    }
}
