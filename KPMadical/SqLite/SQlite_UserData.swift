//
//  SQlite_UserData.swift
//  KPMadical
//
//  Created by Junsung Park on 3/19/24.
//

import Foundation
import SQLite3

class SqliteClass {
    let userDatabaseName = "user.sqlite"
    var db:OpaquePointer?
    
    func createTable(){
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("DSDatabase.sqlite")
            
            if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
                print("table not exsist")
            }
            let CREATE_QUERY_TEXT : String = "CREATE TABLE IF NOT EXISTS user (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, dob TEXT NOT NULL, sex TEXT NOT NULL, Token TEXT NOT NULL)"
            print(CREATE_QUERY_TEXT)
            if sqlite3_exec(db, CREATE_QUERY_TEXT, nil, nil, nil) != SQLITE_OK {
                let errMsg = String(cString:sqlite3_errmsg(db))
                print("db table create error : \(errMsg)")
            }
    }
    func insert(name: String, dob: String, sex: String, token: String){
            var stmt : OpaquePointer?
            
            let INSERT_QUERY_TEXT : String = "INSERT INTO user (id, name, dob, sex, Token) VALUES (?, ?, ?, ?, ?)"

            if sqlite3_prepare(db, INSERT_QUERY_TEXT, -1, &stmt, nil) != SQLITE_OK {
                let errMsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert:v1 \(errMsg)")
                return
            }
            
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            if sqlite3_bind_text(stmt, 1, name, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errMsg = String(cString : sqlite3_errmsg(db)!)
                print("failture binding name: \(errMsg)")
                return
            }

            if sqlite3_bind_text(stmt, 2, dob, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errMsg = String(cString : sqlite3_errmsg(db)!)
                print("failture binding name: \(errMsg)")
                return
            }
            
            if sqlite3_bind_text(stmt, 3, sex, -1, SQLITE_TRANSIENT) != SQLITE_OK{
                let errMsg = String(cString : sqlite3_errmsg(db)!)
                print("failture binding name: \(errMsg)")
                return
            }
            if sqlite3_bind_text(stmt, 4, token, -1, SQLITE_TRANSIENT) != SQLITE_OK{
            let errMsg = String(cString : sqlite3_errmsg(db)!)
            print("failture binding name: \(errMsg)")
            return
            }
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errMsg = String(cString : sqlite3_errmsg(db)!)
                print("insert fail :: \(errMsg)")
                return
            }
        print("Success insert")
        }
}
