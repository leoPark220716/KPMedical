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
//    복구 요청
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
//    스마트 컨트랙트 주소 저장
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
    func CheckAndGetContractAddress(token: String, uid: String, address: String) async -> (success: Bool, addres: String,contract: String){
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/users/cryptos?access_token=\(token)&uid=\(uid)"){
            do{
                var request = URLRequest.init(url: url)
                request.httpMethod = "GET"
                let (data,response) = try await URLSession.shared.data(for: request)
                guard let HttpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= HttpResponse.statusCode else{
                    print("CheckAndGetContractAddress HTTP request \(String(describing: response))")
                    return (false,"","")
                }
                guard let jsonData = try? JSONDecoder().decode(KPApiStructFrom<WalletSaveResponseData>.self, from: data) else{
                    return (false,"","")
                }
                guard let serverAddress = jsonData.data.address else{
                    print("주소 없음")
                    return (false,"","")
                }
                guard let contractAddr = jsonData.data.contract else{
                    print("컨트랙트 주소 없음")
                    return (false,"","")
                }
                return (serverAddress == address, serverAddress, contractAddr)
                
            }catch{
                print("CheckAndGetContractAddress Err \(error)")
                return (false,"","")
            }
        }else{
            return (false,"","")
        }
    }
    func getTransactionList(Limit: String, token: String,account: String) async -> (success: Bool, array: [WalletDataStruct.AccessItem]){
        let httpStruct = http<Empty?,KPApiStructFrom<getListData>>.init(
            method: "GET",
            urlParse: "v2/chat/transactions?limit=\(Limit)",
            token: token,
            UUID: getDeviceUUID())
        struct getListData: Codable{
            var transactions: [TransactionItems]
        }
        let result = await KPWalletApi(HttpStructs: httpStruct)
        if result.success{
            var tempItems: [WalletDataStruct.AccessItem] = []
            for item in result.data!.data.transactions{
                tempItems.append(WalletDataStruct.AccessItem(HospitalName: item.hospital_name, Purpose: item.message, State: item.from == account, Date: datePase(dateString: item.timestamp),blockHash: item.hash,unixTime: item.unixtime))
            }
            return (true,tempItems)
        }else{
            return (false,[])
        }
        struct TransactionItems: Codable{
            let room_key: String
            let timestamp_uuid: String
            let msg_type: Int
            let from: String
            let to: String
            let message: String
            let hospital_id: Int
            let unixtime: Int
            let hash: String
            let timestamp: String
            let hospital_name: String
        }
    }
    private func datePase(dateString: String) -> String{

        // DateFormatter 인스턴스 생성 및 설정
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M.dd"

        // 문자열을 Date 객체로 변환
        if let date = inputFormatter.date(from: dateString) {
            // Date 객체를 원하는 형식의 문자열로 변환
            let formattedDateString = outputFormatter.string(from: date)
            print(formattedDateString) // "5.25"
            return formattedDateString
        } else {
            return "1"
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
        var address: String?
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
