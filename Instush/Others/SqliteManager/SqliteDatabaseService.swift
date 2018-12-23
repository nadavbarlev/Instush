//
//  FirebaseDatabaseService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 23/12/2018.
//  Copyright © 2018 Nadav Bar Lev. All rights reserved.
//

import Foundation

class SqliteDatabaseService: DatabaseService {
    
    // MARK: API Methods
    func getUniqueId(forPath path: String) -> String? {
        return nil
    }
    
    func isExist(path: String, completion: @escaping (Bool)->Void) {
    }
    
    func listenToValue(toPath path: String, listener: @escaping (Dictionary<String,Any>?)->Void) {
    }
    
    func listenToValue(toPath path: String, orderBy field: String, listener: @escaping (Dictionary<String,Any>?)->Void) {
    }
    
    func listenToKey(toPath path: String, listener: @escaping (String)->Void) {
    }
    
    func listenToKey(toPath path: String, orderBy field: String, startFrom value: Int, limit num: Int, listener: @escaping (String)->Void) {
    }
    
    func listenToValueAndKey(toPath path: String, listener: @escaping (String, Dictionary<String,Any>?)->Void) {
    }
    
    func listenForRemoveKey(toPath path: String, listener: @escaping (String)->Void) {
    }
    
    func getValue(path: String, completion: @escaping (Dictionary<String,Any>?)->Void) {
    }
    
    func getValue(path: String, completion: @escaping (String?)->Void) {
    }
    
    func getKeys(path: String, completion: @escaping ([String])->Void) {
    }
    
    func getKeys(from path: String, orderBy field: String, startFrom value: Int?, limit num: Int, completion: @escaping ([String])->Void) {
    }
    
    func getKeys(from path: String, orderBy field: String, end value: Int?, limit num: Int, completion: @escaping ([String])->Void) {
    }
    
    func getKeyAndValue(path: String, completion: @escaping (String, Dictionary<String,Any>?)->Void) {
    }
    
    func getChildCount(path: String, completion: @escaping (Int)->Void) {
    }
    
    func setValue(path: String, dataID: String, data: [String:Any], completion: @escaping (Error?)->Void) {
    }
    
    func setValue(path: String, dataID: String, data: String, completion: @escaping (Error?)->Void) {
    }
    
    func removeValue(path: String, dataID: String, completion: @escaping (Error?)->Void) {
    }
    
    func removeAllValues(path: String, dataIDs: [String], onSuccess: ()->(Void), onError: @escaping (Error)->Void) {
    }
    
    func update(path: String, newValues: [String:Any], onSuccess: (()->Void)?, onError: ((Error)->(Void))?) {
    }
    
    func update(path: String, updateDataBlock: @escaping ([String:Any])->([String:Any]),
                onSuccess: @escaping ([String:Any])->Void,
                onError: ((Error)->(Void))?) {
    }
    
    func contains(text: String, in path: String, orderBy field: String, maxResults: Int,
                  completion: @escaping (String,[String:Any])->Void){
    }
    
    func search(for text: String, in path: String, field: String, completion: @escaping (String,[String:Any])->Void) {
    }
}