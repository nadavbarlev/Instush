//
//  UserService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 13/11/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class UserService {
    
    // MARK: Properties
    static var shared = UserService()
    
    // MARK: Constructor
    private init() {}
    
    // MARK: Methods
    func getCurrentUserID() -> String? {
        return ServiceManager.auth.getUserID()
    }
    
    func getUser(by id: String, completion: @escaping (User)->Void) {
        ServiceManager.database.getValue(path: "users/" + id) { (data: Dictionary<String, Any>?) in
            guard let dicUser = data else { return }
            guard let userToReturn = User.transform(from: dicUser) else { return }
            completion(userToReturn)
        }
    }
    
}
