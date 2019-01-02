//
//  FactoryManager.swift
//  Instush
//
//  Created by Nadav Bar Lev on 21/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class AuthFactory {
    enum authType {
        case firebase
    }
    
    static func create(_ type: authType) -> AuthService {
        switch type {
        case .firebase: return FirebaseAuthService()
        }
    }
}

class DatabaseFactory {
    enum databaseType {
        case firebase
    }
    
    static func create(_ type: databaseType) -> DatabaseService {
        switch type {
        case .firebase: return FirebaseDatabaseService()
        }
    }
}

class StorageFactory {
    enum storageType {
        case firebase
    }
    
    static func create(_ type: storageType) -> StorageService {
        switch type {
        case .firebase: return FirebaseStorageService()
        }
    }
}


class CacheFactory {
    enum cacheType {
        case sqlite
    }
    
    static func create(_ type: cacheType) -> CacheService {
        switch type {
        case .sqlite: return SqliteCacheService()
        }
    }
}
