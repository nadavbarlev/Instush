//
//  CustomNotification.swift
//  Instush
//
//  Created by Nadav Bar Lev on 22/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class CustomNotification<T> {
    
    // MARK: Properties
    let name: String
    var observersCount: Int   = 0
    
    // MARK: Constructor
    init(_ name: String) {
        self.name = name
    }
    
    // MARK: Methods
    func observe(completion:@escaping ((T)->Void)) -> NSObjectProtocol {
        observersCount += 1
        return NotificationCenter.default.addObserver(forName: NSNotification.Name(name), object: nil, queue: nil) { (data: Notification) in
            guard let data = data.userInfo?["data"] as? T else { return }
            completion(data)
        }
    }
    
    func notify(data: T) {
        NotificationCenter.default.post(name: NSNotification.Name(name), object: self, userInfo: ["data":data])
    }
    
    func remove(observer: NSObjectProtocol?) {
        guard let observer = observer else { return }
        observersCount -= 1
        NotificationCenter.default.removeObserver(observer, name: nil, object: nil)
    }
}

