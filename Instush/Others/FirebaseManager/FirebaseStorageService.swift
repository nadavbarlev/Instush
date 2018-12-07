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
    let storage = Storage.storage()
    
    // MARK: API Methods
    func save(path: String, dataID: String, data: Data, onSuccess: ((URL)->(Void))?, onError: ((Error)->(Void))?) {
        let fullPathStorageRef = storage.reference().child(path).child(dataID)
        fullPathStorageRef.putData(data, metadata: nil) { (metadata: StorageMetadata?, error: Error?) in
            if error != nil { onError?(error!); return }
            fullPathStorageRef.downloadURL { (url: URL?, error: Error?) in
                if error != nil { onError?(error!); return }
                onSuccess?(url!)
            }
        }
    }
    
    func delete(path: String, dataID: String, onSuccess: (()->(Void))?, onError: ((Error)->(Void))?) {
        let fullPathStorageRef = storage.reference().child(path).child(dataID)
        fullPathStorageRef.delete { (error: Error?) in
            if (error != nil) { onError?(error!); return }
            onSuccess?()
        }
    }
    
    func delete(url: String, onSuccess: (()->(Void))?, onError: ((Error)->(Void))?) {
        let fullPathStorageRef = storage.reference(forURL: url)
        fullPathStorageRef.delete { (error: Error?) in
            if (error != nil) { onError?(error!); return }
            onSuccess?()
        }
    }
}
