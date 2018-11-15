//
//  FirebaseStorageService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 15/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation
import FirebaseStorage

class FirebaseStorageService: StorageService {
    
    // MARK: Properties
    let storageRef = Storage.storage().reference()
    
    // MARK: API Methods
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
