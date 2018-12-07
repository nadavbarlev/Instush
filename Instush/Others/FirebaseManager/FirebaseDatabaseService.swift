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
        dbRef.child(path).observe(.value) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            listener(dicToReturn)
        }
    }
    
    func listenToValue(toPath path: String, orderBy field: String, listener: @escaping (Dictionary<String,Any>?)->Void) {
        dbRef.child(path).queryOrdered(byChild: field).observe(.value) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            listener(dicToReturn)
        }
    }
    
    func listenToKey(toPath path: String, listener: @escaping (String)->Void) {
        dbRef.child(path).observe(.childAdded) { (snapshot: DataSnapshot) in
            listener(snapshot.key)
        }
    }
    
    func listenToKey(toPath path: String, orderBy field: String, startFrom value: Int, limit num: Int, listener: @escaping (String)->Void) {
        dbRef.child(path).queryOrdered(byChild: field).queryLimited(toFirst: UInt(num)).observeSingleEvent(of: .childAdded) { (snapshot: DataSnapshot) in
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
                let keyToAdd = (child as! DataSnapshot).key
                keys.append(keyToAdd)
            }
            completion(keys)
        }
    }
  
    func getKeys(from path: String, orderBy field: String, startFrom value: Int?, limit num: Int, completion: @escaping ([String])->Void) {
        var keys = [String]()
        dbRef.child(path).queryOrdered(byChild: field).queryLimited(toFirst: UInt(num)).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            for child in snapshot.children {
                let keyToAdd = (child as! DataSnapshot).key
                keys.append(keyToAdd)
            }
            completion(keys)
        }
    }
    
    func getKeys(from path: String, orderBy field: String, end value: Int?, limit num: Int, completion: @escaping ([String])->Void) {
        var keys = [String]()
        dbRef.child(path).queryOrdered(byChild: field).queryStarting(atValue: value).queryLimited(toFirst: UInt(num)).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            for child in snapshot.children {
                let keyToAdd = (child as! DataSnapshot).key
                keys.append(keyToAdd)
            }
            completion(keys)
        }
    }
    
    func getKeyAndValue(path: String, completion: @escaping (String, Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let dicKey = snapshot.key
            let dicToReturn = snapshot.value as? [String:Any]
            completion(dicKey, dicToReturn)
        }
    }
    
    func getChildCount(path: String, completion: @escaping (Int)->Void) {
        dbRef.child(path).observe(.value) { (snapshot: DataSnapshot) in
            completion(Int(snapshot.childrenCount))
        }
    }
    
    func setValue(path: String, dataID: String, data: [String:Any], completion: @escaping (Error?)->Void) {
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
    
    func update(path: String, newValues: [String:Any], onSuccess: (()->Void)?, onError: ((Error)->(Void))?) {
        dbRef.child(path).updateChildValues(newValues) { (error: Error?, dbRef: DatabaseReference) in
            if (error != nil) { onError?(error!); return }
            onSuccess?()
        }
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
    
     func contains(text: String, in path: String, orderBy field: String, maxResults: Int,
                 completion: @escaping (String,[String:Any])->Void){
        dbRef.child(path).queryOrdered(byChild: field).queryStarting(atValue: text).queryEnding(atValue: text+"\u{f8ff}")
            .queryLimited(toFirst: UInt(maxResults)).observeSingleEvent(of: .value) { (snapshot) in
                snapshot.children.forEach{ (snapshotChild) in
                    let child = snapshotChild as! DataSnapshot
                    let key  = child.key
                    guard let data = child.value as? [String:Any] else { return }
                    completion(key, data)
                }
        }
    }
    
    func search(for text: String, in path: String, field: String, completion: @escaping (String,[String:Any])->Void){
        dbRef.child(path).queryOrdered(byChild: field).queryEqual(toValue: text).observeSingleEvent(of: .value) { (snapshot) in
                snapshot.children.forEach{ (snapshotChild) in
                    let child = snapshotChild as! DataSnapshot
                    let key  = child.key
                    guard let data = child.value as? [String:Any] else { return }
                    completion(key, data)
                }
        }
    }
}
