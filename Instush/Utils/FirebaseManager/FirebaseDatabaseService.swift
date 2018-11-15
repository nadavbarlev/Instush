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
    
    // MARK: Properties
    let dbRef = Database.database().reference()
    
    // MARK: API Methods
    func setValue(path: String, dataID: String, data: [String:String], completion: @escaping (Error?)->Void) {
        let fullPathDatabaseRef = dbRef.child(path).child(dataID)
        fullPathDatabaseRef.setValue(data) { (error, dbRef) in
            completion(error)
        }
    }
    
    func getUniqueId(forPath path: String) -> String? {
        return dbRef.child(path).childByAutoId().key
    }
    
    func listen(toPath path: String, listener: @escaping (Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observe(.childAdded) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            listener(dicToReturn)
        }
    }
    
    func getValue(path: String, completion: @escaping (Dictionary<String,Any>?)->Void) {
        dbRef.child(path).observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let dicToReturn = snapshot.value as? [String:Any]
            completion(dicToReturn)
        }
    }
}
