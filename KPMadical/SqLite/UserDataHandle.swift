//
//  UserDataHandle.swift
//  KPMadical
//
//  Created by Junsung Park on 3/18/24.
//

import Foundation

class UserObservaleObject: ObservableObject {
    @Published var name: String = ""
    @Published var dob: String = ""
    @Published var sex: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn = false
    func SetData(name: String, dob:String, sex:String, token:String, isLoggedIn: Bool){
        self.name = name
        self.dob = dob
        self.sex = sex
        self.token = token
        self.isLoggedIn = isLoggedIn
    }
}

class singupOb: ObservableObject {
    @Published var birthday = ""
    @Published var sex = ""
    @Published var message = ""
    @Published var phoneNumber = ""
    @Published var name = ""
    @Published var id = ""
    @Published var password = ""
    @Published var smsCheck = false
    @Published var Checkpassword = ""
}
