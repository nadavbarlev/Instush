//
//  FactoryManager.swift
//  Instush
//
//  Created by Nadav Bar Lev on 21/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

// MARK: Factory Design Pattern
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
        case sqlite
    }
    
    static func create(_ type: databaseType) -> DatabaseService {
        switch type {
        case .firebase: return FirebaseDatabaseService()
        case .sqlite:   return SqliteDatabaseService()
        }
    }
}

class StorageFactory {
    enum storageType {
        case firebase
        case sqlite
    }
    
    static func create(_ type: storageType) -> StorageService {
        switch type {
        case .firebase: return FirebaseStorageService()
        case .sqlite:   return SqliteStorageService()
        }
    }
}
