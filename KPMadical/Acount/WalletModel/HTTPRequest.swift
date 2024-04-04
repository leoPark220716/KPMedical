//
//  HTTPRequest.swift
//  KPMadical
//
//  Created by Junsung Park on 4/4/24.
//

import Foundation

class WalletAPIRequest{
//    지갑 생성 및 복구 데이터 저장
    func SaveWalletWithRSA(token: String, uid: String, address:String, rsa: String, type: Int) async -> Bool {
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/users/wallet") {
            do {
                let postData: SaveWalletData = .init(access_token: token, uid: uid, address: address, encrypt_rsa: rsa, type: type)
                var request = URLRequest.init(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let requestData = try JSONEncoder().encode(postData)
                request.httpBody = requestData
                
                // 요청값 출력
                if let jsonString = String(data: requestData, encoding: .utf8) {
                    print(jsonString)
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpResponse.statusCode else {
                    print("SaveWalletWithRSA HTTP request \(String(describing: response))")
                    return false
                }
                
                guard let jsonData = try? JSONDecoder().decode(KPApiStructFrom<WalletSaveResponseData>.self, from: data) else {
                    return false
                }
                if let contract = jsonData.data.contract{
                    print("지갑 복구 contract 주소 : \(contract) ")
                }
                return jsonData.status == 201
            } catch {
                print("SaveWalletWithRSA Err : \(error)")
                return false
            }
        } else {
            return false
        }
    }
    func RecoverWalletWithRSA(token: String, uid: String, address:String, rsa: String, type: Int) async -> (success:Bool, rsaEncrypt: String) {
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/users/wallet") {
            do {
                let postData: SaveWalletData = .init(access_token: token, uid: uid, address: address, encrypt_rsa: rsa, type: type)
                var request = URLRequest.init(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let requestData = try JSONEncoder().encode(postData)
                request.httpBody = requestData
                
                // 요청값 출력
                if let jsonString = String(data: requestData, encoding: .utf8) {
                    print(jsonString)
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpResponse.statusCode else {
                    print("SaveWalletWithRSA HTTP request \(String(describing: response))")
                    return (false,"")
                }
                
                guard let jsonData = try? JSONDecoder().decode(KPApiStructFrom<WalletSaveResponseData>.self, from: data) else {
                    return (false,"")
                }
                let contract = jsonData.data.encrypt_rsa
                print(contract)
                return (jsonData.status == 201, jsonData.data.encrypt_rsa)
            } catch {
                print("SaveWalletWithRSA Err : \(error)")
                return (false,"")
            }
        } else {
            return (false,"")
        }
    }
    func SaveContractAddress(token: String, uid: String, contract: String) async -> Bool{
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/users/contract"){
            do{
                let postData: SaveContract = .init(access_token: token, uid: uid, contract: contract)
                var request = URLRequest.init(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                let requestData = try JSONEncoder().encode(postData)
                request.httpBody = requestData
                
                if let jsonString = String(data: requestData, encoding: .utf8){
                    print(jsonString)
                }
                let (data,response) = try await URLSession.shared.data(for: request)
                guard let HttpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= HttpResponse.statusCode else{
                    print("SaveContractAddress HTTP request \(String(describing: response))")
                    return false
                }
                guard let jsonData = try? JSONDecoder().decode(KPApiStructFrom<SaveContractResponseData>.self, from: data) else{
                    return false
                }
                return jsonData.status == 201
            }
            catch{
                print("SaveContractAddress Err : \(error)")
                return false
            }
        }else{
            return false
        }
    }

    struct SaveWalletData: Codable{
        var access_token: String
        var uid: String
        var address: String
        var encrypt_rsa: String
        var type: Int
    }
    struct WalletSaveResponseData: Codable{
        var access_token: String
        var encrypt_rsa: String
        var contract: String?
        var error_code: Int
        var error_stack: String
    }
    struct SaveContract: Codable{
        var access_token: String
        var uid: String
        var contract: String
    }
    struct SaveContractResponseData: Codable{
        var access_token: String
        var affected_rows: Int
        var error_code: Int
        var error_stack: String
    }
}
