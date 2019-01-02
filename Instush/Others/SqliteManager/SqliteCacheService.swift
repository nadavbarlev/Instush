//
//  SqliteCacheService.swift
//  Instush
//
//  Created by Nadav Bar Lev on 01/01/2019.
//  Copyright © 2019 Nadav Bar Lev. All rights reserved.
//

import Foundation

class SqliteCacheService : CacheService {
    
    // MARK: Properties
    var database: OpaquePointer?
    
    // MARK: Constructor
    init() {
        let dbFileName = "database-instush.db"
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let path = dir.appendingPathComponent(dbFileName)
        if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
            print("Failed to open db")
            return
        }
    }
    
    // MARK: Methods
    func create(name: String, data: String?, onSuccess: ()->Void, onError: ()->Void) {
        guard let columns = data else { return }
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let statment = String(format: "CREATE TABLE IF NOT EXISTS %@%@", name, columns)
        let response = sqlite3_exec(database, statment, nil, nil, &errormsg);
        if (response != 0) {
            onError(); return
        }
        onSuccess()
    }
    
    func delete(name: String, onSuccess: ()->Void, onError: ()->Void) {
        let statment = String(format: "DROP TABLE %@;", name)
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let response = sqlite3_exec(database, statment, nil, nil, &errormsg);
        if (response != 0) {
            onError(); return
        }
        onSuccess()
    }
    
    func get(name: String, onSuccess: (Array<[String]>)->Void, onError: ()->Void) {
        var dataToRetrieve = Array<[String]>()
        var sqlite3_stmt: OpaquePointer? = nil
        let statment = String(format: "SELECT * from %@;", name)
        if (sqlite3_prepare_v2(database, statment, -1, &sqlite3_stmt, nil) == SQLITE_OK) {
            let numOfColumn = sqlite3_column_count(sqlite3_stmt)
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW) {
                var data = [String]()
                for index in 0..<numOfColumn {
                     data.append(String(cString:sqlite3_column_text(sqlite3_stmt,index)!))
                }
                dataToRetrieve.append(data)
            }
            onSuccess(dataToRetrieve)
        }
        else { onError() }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    func save(name: String, dataToSave: [String], onSuccess: ()->Void, onError: ()->Void) {
        var sqlite3_stmt: OpaquePointer? = nil
        let questionMarks = createQuestionmMarks(count: dataToSave.count)
        var data = dataToSave.map { $0.cString(using: .utf8) }
        let statment = String(format: "INSERT OR REPLACE INTO %@ VALUES (%@);", name, questionMarks)
        if (sqlite3_prepare_v2(database, statment,-1, &sqlite3_stmt,nil) == SQLITE_OK){
            for index in 0..<dataToSave.count {
                 sqlite3_bind_text(sqlite3_stmt, Int32(index.advanced(by: 1)), data[index],-1,nil)
            }
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                onSuccess()
            } else {
                onError()
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    // MARK: Private Methods
    func createQuestionmMarks(count: Int) -> String {
        var questionMarks = ""
        for _ in 1...count {
            questionMarks += "?,"
        }
        return String(questionMarks.dropLast())
    }
    
}
