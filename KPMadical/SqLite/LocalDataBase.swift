//
//  File.swift
//  KPMadical
//
//  Created by Junsung Park on 3/18/24.
//

import Foundation
import SQLite3

struct UserDb_Sqlite{
    var id: Int
    var name: String
    var dob: String
    var sex: String
    var token: String
}

class LocalDataBase: ObservableObject {
    
    static let shared = LocalDataBase()
    
    var db: OpaquePointer?
    
    let userDatabaseName = "User_info.sqlite"
    
    func createTable(){
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("User_info.sqlite")
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
            
            let INSERT_QUERY_TEXT : String = "INSERT INTO user (name, dob, sex, Token) VALUES (?, ?, ?, ?)"

        if sqlite3_prepare_v2(self.db, INSERT_QUERY_TEXT, -1, &stmt, nil) != SQLITE_OK {
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
    
    func readUserDb(userState: UserObservaleObject) {
        print("Call readUserDb")
        let query = "SELECT * FROM user ORDER BY id DESC LIMIT 1;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let name = String(cString: sqlite3_column_text(statement, 1))
                let dob = String(cString: sqlite3_column_text(statement, 2))
                let sex = String(cString: sqlite3_column_text(statement, 3))
                let token = String(cString: sqlite3_column_text(statement, 4))
                userState.SetData(name: name, dob: dob, sex: sex, token: token)
                print("name : \(name)")
                print("name : \(dob)")
                print("name : \(sex)")
                print("name : \(token)")
            }
        } else {
            let errMessage = String(cString: sqlite3_errmsg(db))
            print("Error reading user DB: \(errMessage)")
            userState.isLoggedIn = false
        }
        sqlite3_finalize(statement)
    }
    
    func removeAllUserDB() {
        print("Call removeAllUserDB")
        let query = "DELETE FROM user;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully deleted all users")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error deleting users: \(errorMessage)")
            }
        } else {
            let errMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing delete: \(errMessage)")
        }
        sqlite3_finalize(statement)
    }
    
    func updateToken(token: String) {
        print("Call updateToken")
        let query = "UPDATE user SET Token = ? ORDER BY id DESC LIMIT 1;"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (token as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Successfully updated token")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error updating token: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing update: \(errorMessage)")
        }
        sqlite3_finalize(statement)
        sqlite3_close(self.db)
    }
}
