//
//  DataRequest.swift
//  KPMadical
//
//  Created by Junsung Park on 5/3/24.
//

import Foundation


class passwordDataRequest{
    
    func getPasswordOpt(account: String) async -> (Bool,Bool,String){
        let httpStruct = http<Empty?, KPApiStructFrom<getBody>>.init(
            method: "GET",
            urlParse: "v2/users/mobile?account=\(account)&service_id=1",
            token: "" ,
            UUID: getDeviceUUID()
        )
        let result = await HttpRequest(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            if result.data?.status == 200{
                return (true,true,result.data!.data.verify_token)
            }else if result.data?.status == 206{
                return (true,false,"")
            }else{
                return (false,false,"")
            }
        }else{
            print(result.data?.message ?? "Option Null")
            return (false,false,"")
        }
        struct getBody: Codable{
            var verify_token: String
            var error_code: Int
            var error_stack: String
        }
    }
    
    func checkPasswordChange(otp: String, account: String, token: String) async -> (Bool,Bool,String) {
        print("👀 Call checkPasswordChange")
        let httpStruct = http<Empty?, KPApiStructFrom<getBody>>.init(
            method: "GET",
            urlParse: "v2/users/mobile/check?account=\(account)&verify_token=\(token)&code=\(otp)&service_id=1",
            token: token ,
            UUID: getDeviceUUID()
        )
        let result = await HttpRequest(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            if result.data?.status == 200{
                return (true,true,result.data!.data.temp_token)
            }else if result.data?.status == 202{
                print("👀 End checkPasswordChange")
                return (true,false,"")
            }else{
                print("👀 End checkPasswordChange")
                return (true,false,"")
                
            }
        }else{
            print(result.data?.message ?? "Option Null")
            print("👀 End checkPasswordChange")
            return (true,false,"")
        }
        struct getBody: Codable{
            var temp_token: String
            var error_code: Int
            var error_stack: String
        }
    }
    
//    비밀번호 변경 함수
    func patchPassword(type: Int, new_pass: String, pass: String, token: String) async -> Bool{
        let BodyData = patchPass.init(type: type, new_password: new_pass, password: pass, service_id: 1)
        let httpStruct = http<patchPass?, KPApiStructFrom<getBody>>.init(
            method: "PATCH",
            urlParse: "v2/users/password",
            token: token ,
            UUID: getDeviceUUID(),
            requestVal: BodyData
        )
        let result = await HttpRequest(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            if result.data?.status == 201{
                return true
            }else{
                return false
            }
        }else{
            print(result.data?.message ?? "Option Null")
            return false
        }
    }
    struct patchPass:Codable{
        var type: Int
        var new_password:String
        var password: String
        var service_id: Int
    }
    struct getBody: Codable{
        var affectedRows: Int
        var error_code: Int
        var error_stack: String
    }
}
