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
class LocalDataBase {
    static let DataBase = LocalDataBase()
    
    var db : OpaquePointer?
    
    let UserdatabaseName = "user.sqlite"
    
    init() {
        self.db = createDB()
    }
    
    deinit{
        sqlite3_close(db)
    }
    //    디비 생성 함수.
//    씨발 ㄴ
    private func createDB() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        do{
            let dbPath: String = try FileManager.default.url(
                for: .documentDirectory,
                in: . userDomainMask,
                appropriateFor: nil,
                create: false).appendingPathComponent(UserdatabaseName).path
            
            if sqlite3_open(dbPath,&db) == SQLITE_OK {
                print("create DB Successfuly. path : \(dbPath)")
                return db
            }
        }
        catch {
            print("Err while Creating Database : \(error.localizedDescription)")
        }
        return nil
    }
//    SQlite 사용 user 정보 담는 DB 생성
    func createTable(){
        let MakeUserDb = """
    CREATE TABLE IF NOT EXISTS user(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    dob TEXT NOT NULL,
    sex TEXT NOT NULL,
    Token TEXT NOT NULL
    );
    """
        var statement: OpaquePointer? = nil
        if sqlite3_prepare(self.db, MakeUserDb, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Creating table has been succesfully done \(String(describing: self.db))")
            }else{
                let errMessage = String(cString: sqlite3_errmsg(db))
                print("creating table false : \(errMessage)")
            }
        }else{
            let errorMessage = String(cString: sqlite3_errmsg(self.db))
            print("\nsqlite3_prepare failure while creating table: \(errorMessage)")
        }
        sqlite3_finalize(statement)
    }
    func insertUserDB(name: String, dob: String, sex: String, Token: String) {
        let insertQuery = "insert into user(id, name, dob, sex, Token) values(?,?,?,?,?);"
        var statement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 2, name, -1, nil)
            sqlite3_bind_text(statement, 3, dob, -1, nil)
            sqlite3_bind_text(statement, 4, sex, -1, nil)
            sqlite3_bind_text(statement, 5, Token, -1, nil)
        }
        else {
            print("sqlite binding failure")
        }
        if sqlite3_step(statement) == SQLITE_DONE {
            print("sqlite insertion success")
        }else{
            print("sqlite step failure")
        }
    }
    func readUserDb(userstate:UserObservaleObject){
        let query: String = "SELECT * FROM user ORDER BY id DESC LIMIT 1;"
        var statement: OpaquePointer? = nil
        
        
        if sqlite3_prepare(self.db, query, -1, &statement, nil) != SQLITE_OK {
            let errMessage = String(cString: sqlite3_errmsg(db)!)
            userstate.isLoggedIn = false
            print("err : \(errMessage)")
        }
        while sqlite3_step(statement) == SQLITE_ROW{
            _ = sqlite3_column_int(statement, 0)
            let name = String(cString: sqlite3_column_text(statement, 1))
            let dob = String(cString: sqlite3_column_text(statement, 2))
            let sex = String(cString: sqlite3_column_text(statement, 3))
            let token = String(cString: sqlite3_column_text(statement, 4))
            userstate.SetData(name: name, dob: dob, sex: sex, token: token, isLoggedIn: true)
        }
        sqlite3_finalize(statement)
    }
//    컬럼 추가
    
//    func addColumnToUserTable() {
//        let alterTableStatementStr = "ALTER TABLE user ADD COLUMN Token TEXT NOT NULL"
//        var alterTableStatement: OpaquePointer? = nil
//        if sqlite3_prepare_v2(self.db, alterTableStatementStr, -1, &alterTableStatement, nil) == SQLITE_OK {
//            if sqlite3_step(alterTableStatement) == SQLITE_DONE {
//                print("Added a column to user table successfully.")
//            } else {
//                print("Could not add a column to user table.")
//            }
//        } else {
//            print("ALTER TABLE statement could not be prepared.")
//        }
//        sqlite3_finalize(alterTableStatement)
//    }
}
