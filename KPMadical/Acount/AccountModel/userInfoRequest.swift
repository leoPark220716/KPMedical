//
//  userInfoRequest.swift
//  KPMadical
//
//  Created by Junsung Park on 5/16/24.
//

import Foundation


class UserInfoRequest: ObservableObject {
    @Published var phoneNumber = ""
    @Published var newNumber = ""
    func getMoblie(token: String){
        let parameters = [
            "access_token": token,
            "uid": getDeviceUUID()
        ]
        let httpStruct = http<Empty?, KPApiStructFrom<responseData>>.init(
            method: "GET",
            urlParse: "users/info",
            token: token ,
            UUID: getDeviceUUID()
        )
        Task{
            let result = await StoneKPWalletApi(HttpStructs: httpStruct, param: parameters)
            if result.success{
                print(result.data?.message ?? "Option Null")
                DispatchQueue.main.async{
                    print("👮🏼‍♂️ \(String(describing: result.data?.data.mobile))")
                    self.phoneNumber =  result.data?.data.mobile ?? ""
                    print("👮🏼‍♂️ \(self.phoneNumber)")
                }
                return true
            }else{
                print(result.data?.message ?? "Option Null")
                return false
            }
        }
        struct responseData : Codable{
            var mobile: String
        }
    }
    
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        
        if cleanedPhoneNumber.count == 11 {
            let start = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 3)
            let mid = cleanedPhoneNumber.index(start, offsetBy: 4)
            let end = cleanedPhoneNumber.index(mid, offsetBy: 4)
            return "\(cleanedPhoneNumber[..<start])-\(cleanedPhoneNumber[start..<mid])-\(cleanedPhoneNumber[mid..<end])"
        } else if cleanedPhoneNumber.count == 10 {
            let start = cleanedPhoneNumber.index(cleanedPhoneNumber.startIndex, offsetBy: 3)
            let mid = cleanedPhoneNumber.index(start, offsetBy: 3)
            let end = cleanedPhoneNumber.index(mid, offsetBy: 4)
            return "\(cleanedPhoneNumber[..<start])-\(cleanedPhoneNumber[start..<mid])-\(cleanedPhoneNumber[mid..<end])"
        }
        
        return phoneNumber
    }
    func getOptMoblie(mobile: String) async -> (success : Bool, token: String){
        let parameters = [
            "mobile": mobile
        ]
        let httpStruct = http<Empty?, KPApiStructFrom<responseData>>.init(
            method: "GET",
            urlParse: "mobile",
            token: "" ,
            UUID: getDeviceUUID()
        )
        
        let result = await StoneKPWalletApi(HttpStructs: httpStruct, param: parameters)
        if result.success{
            print(result.data?.message ?? "Option Null")
            print(result.data!.data.verify_token)
            
            return (true,result.data!.data.verify_token)
        }else{
            print(result.data?.message ?? "Option Null")
            return (false,"")
        }
        struct responseData : Codable{
            var verify_token: String
        }
    }
    func CheckOptMoblie(mobile: String,code: String, token: String) async -> (Bool){
        print("👀 Call CheckOptMoblie")
        let parameters = [
            "mobile": mobile,
            "mobile_code": code,
            "verify_token":token
        ]
        let httpStruct = http<Empty?, KPApiStructFrom<responseData>>.init(
            method: "GET",
            urlParse: "mobile/check",
            token: "" ,
            UUID: getDeviceUUID()
        )
        
        let result = await StoneKPWalletApi(HttpStructs: httpStruct, param: parameters)
        if result.success{
            print(result.data?.message ?? "Option Null")
            print("👀 End CheckOptMoblie")
            return (true)
        }else{
            print(result.data?.message ?? "Option Null")
            print("👀 End CheckOptMoblie")
            return (false)
        }
        struct responseData : Codable{
            var mobile: String
            var service_id: Int
            var iat: Int
            var exp: Int
        }
    }
    func patchMoblie(mobile : String,code: String,verifiy_token: String,token: String) async -> Bool{
        print("👀 Call patchMoblie")
        let BodyData = bodyData.init(mobile: mobile, code: code, verify_token: verifiy_token)
        let httpStruct = http<bodyData?, KPApiStructFrom<responseData>>.init(
            method: "PATCH",
            urlParse: "v2/users/mobile",
            token: token ,
            UUID: getDeviceUUID(),
            requestVal: BodyData
        )
            let result = await KPWalletApi(HttpStructs: httpStruct)
            if result.success{
                print(result.data?.message ?? "Option Null")
                print("👮🏼‍♂️ \(String(describing: result.data?.data.mobile))")
                print("👀 End patchMoblie")
                return true
            }else{
                print(result.data?.message ?? "Option Null")
                print("👀 End patchMoblie")
                return false
            }
        
        struct responseData : Codable{
            var mobile: String
            var error_code: Int
            var error_stack: String
        }
        struct bodyData: Codable{
            var mobile: String
            var code: String
            var verify_token: String
        }
    }
}

