//
//  UserDataHandle.swift
//  KPMadical
//
//  Created by Junsung Park on 3/18/24.
//

import Foundation
import UIKit
class UserObservaleObject: ObservableObject {
    @Published var name: String = ""
    @Published var dob: String = ""
    @Published var sex: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn = false
    @Published var recommendHospitalUrl1 = ""
    @Published var recommendHospitalUrl2 = ""
    @Published var recommendHospitalUrl3 = ""
    func SetData(name: String, dob: String, sex: String, token: String) {
        self.name = name
        self.dob = dob
        self.sex = sex
        self.token = token
    }
    func SetRecommendHospitalUrl(url1: String, url2: String, url3: String){
        DispatchQueue.main.async{
            self.recommendHospitalUrl1 = url1
            self.recommendHospitalUrl2 = url2
            self.recommendHospitalUrl3 = url3
        }
    }
    func SetLoggedIn(logged: Bool) {
        DispatchQueue.main.async {
            self.isLoggedIn = logged
        }
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
// 디바이스 고유 넘버
func getDeviceUUID() -> String {
    return UIDevice.current.identifierForVendor!.uuidString
}
