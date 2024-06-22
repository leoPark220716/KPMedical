//
//  TransactionManager.swift
//  KPMadical
//
//  Created by Junsung Park on 5/28/24.
//

import Foundation
import BigInt

class TransactionManager: KNPWallet,ObservableObject{
    var UnixTime: Int
    var HospitalId: Int?
    var socket: ChatSocketModel?
    var hospitalName: String?
    var ContractCase: ChatMessegeItem.MessageTypes
    var pubkey: String?
    var departCode: Int?
    var hash: String?
    var index: Int?
    @Published var TransactionState = false
    init(UnixTime: Int,type: ChatMessegeItem.MessageTypes) {
        self.UnixTime = UnixTime
        self.ContractCase = type
    }
    func SetSocketAndHosId(socket: ChatSocketModel,hospitalId: Int, hospitalName: String){
        self.socket = socket
        self.HospitalId = hospitalId
        self.hospitalName = hospitalName
    }
    func shareSetting(departCode: Int,pubkey:String){
        self.departCode = departCode
        self.pubkey = pubkey
    }
    func EditSetting(index: Int,hash:String){
        self.index = index
        self.hash = hash
    }
//    저장요청 수락
    func Confirm(token: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let account = self.GetUserAccountString(token: token)
                if !account.status {
                    continuation.resume(returning: false)
                    return
                }
                print("TxManager UnixTime: \(self.UnixTime)")
                print("TxManager HospitalId: \(self.HospitalId!)")
                Task {
                    let account = self.GetUserAccountString(token: token)
                    if !account.status {
                        continuation.resume(returning: false)
                        return
                    }
                    let addr = self.GetWalletPublicKey(account: account.account)
                    if !addr.success {
                        print("공개키 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let WalletAddr = await self.walletHttp.CheckAndGetContractAddress(token: token, uid: getDeviceUUID(), address: addr.addres)
                    if !WalletAddr.success {
                        print("Http요청 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    
                    let password = self.GetPasswordKeystore(account: account.account)
                    if !password.seccess {
                        print("비밀번호 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let privateKeyData = self.getWalletPrivateKey(account: account.account, password: password.password)
                    if !privateKeyData.success {
                        print("개인키 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let callConfirmSaveRecord = await self.callConfirmReqeust(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, hospitalID: UInt32(self.HospitalId!), date: BigUInt(self.UnixTime), password: password.password)
                    if callConfirmSaveRecord.success {
                        print("호출 성공?")
                        let success = await self.socket!.SendTransactionMsg(from: account.account, to: String(self.HospitalId!) , name: self.hospitalName!, blockHash: callConfirmSaveRecord.txHash, message: "저장요청을 수락 하셨습니다.")
                        if success{
                            print("메시지 전송 성공")
                        }else{
                            print("메시지 전송 실패")
                        }
                        continuation.resume(returning: success)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
//   공유 요청 수락
    func ConfirmToShare(token: String) async {
        Task{
            let account = GetUserAccountString(token: token)
            if !account.status {
                print("어카운트 실패")
                return
            }
            let addr = GetWalletPublicKey(account: account.account)
            if !addr.success {
                print("❌공개키 가져오기 실패")
                return
            }
            let WalletAddr = await walletHttp.CheckAndGetContractAddress(token: token, uid: getDeviceUUID(), address: addr.addres)
            if !WalletAddr.success {
                print("❌Http요청 실패")
                return
            }
            let password = GetPasswordKeystore(account: account.account)
            if !password.seccess {
                print("❌비밀번호 가져오기 실패")
                return
            }
            let privateKeyData = getWalletPrivateKey(account: account.account, password: password.password)
            if !privateKeyData.success {
                print("❌개인키 가져오기 실패")
                return
            }
            let callConfirmSaveRecord = await recodeRead(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, param1: BigUInt(departCode!), param2: BigUInt(HospitalId!), methodName: "getRecordToShare")
            if !callConfirmSaveRecord.success {
                print("❌컨트랙트 가져오기 실패")
                return
            }
            print(callConfirmSaveRecord.result)
            let ParseContract = ReturningUnDecodArray(dic: callConfirmSaveRecord.result)
            if !ParseContract.success{
                print("❌pase 실패")
                return
            }
            let setSymetricKey = getSymetricKeys(array: ParseContract.contractResult!, account: account.account)
            if !setSymetricKey.success{
                print("❌개인키 가져오기 실패")
            }
            var paramArray: [SharedData] = []
            for indexItem in setSymetricKey.contractResult!{
                paramArray.append(SharedData(index: indexItem.index, hospital_id: BigUInt(HospitalId!), hospital_key: CryptoSecKey(pubkey: pubkey!, decodeString: indexItem.patient_key)))
            }
            print(paramArray)
            let shareContract = await callShaerReqeust(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, param: paramArray, password: password.password)
            if shareContract.success{
                print("호출 성공?")
                let success = await self.socket!.SendTransactionMsg(from: account.account, to: String(self.HospitalId!) , name: self.hospitalName!, blockHash: shareContract.txHash, message: "공유요청을 수락 하셨습니다.")
                if success{
                    print("메시지 전송 성공")
                }else{
                    print("메시지 전송 실패")
                }
                print(shareContract.txHash)
            }
        }
        
    }
    
//    진료기록 수정요청 수락
    func ConfirmToEdit(token: String) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .background).async {
                let account = self.GetUserAccountString(token: token)
                if !account.status {
                    continuation.resume(returning: false)
                    return
                }
                print("TxManager UnixTime: \(self.UnixTime)")
                print("TxManager HospitalId: \(self.HospitalId!)")
                Task {
                    let account = self.GetUserAccountString(token: token)
                    if !account.status {
                        continuation.resume(returning: false)
                        return
                    }
                    let addr = self.GetWalletPublicKey(account: account.account)
                    if !addr.success {
                        print("공개키 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let WalletAddr = await self.walletHttp.CheckAndGetContractAddress(token: token, uid: getDeviceUUID(), address: addr.addres)
                    if !WalletAddr.success {
                        print("Http요청 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    
                    let password = self.GetPasswordKeystore(account: account.account)
                    if !password.seccess {
                        print("비밀번호 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let privateKeyData = self.getWalletPrivateKey(account: account.account, password: password.password)
                    if !privateKeyData.success {
                        print("개인키 가져오기 실패")
                        continuation.resume(returning: false)
                        return
                    }
                    let callConfirmSaveRecord = await self.callEditReqeust(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, hospitalID: UInt32(self.HospitalId!), date: BigUInt(self.UnixTime), password: password.password,index: BigUInt(self.index!))
                    if callConfirmSaveRecord.success {
                        print("호출 성공?")
                        let success = await self.socket!.SendTransactionMsg(from: account.account, to: String(self.HospitalId!) , name: self.hospitalName!, blockHash: callConfirmSaveRecord.txHash, message: "수정요청을 수락 하셨습니다.")
                        if success{
                            print("메시지 전송 성공")
                        }else{
                            print("메시지 전송 실패")
                        }
                        continuation.resume(returning: success)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    }
    struct SharedData {
        let index: BigUInt
        let hospital_id :BigUInt
        let hospital_key: String
    }
    private func CryptoSecKey(pubkey: String,decodeString:String) -> String{
        print("✅ pubkey")
        print(pubkey)
        print("✅ CRYPTOSTRING")
        print(decodeString)
        let der = Data(base64Encoded: pubkey, options: .ignoreUnknownCharacters)!
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits): der.count * 8
        ]
        let key = SecKeyCreateWithData(der as CFData, attributes as CFDictionary, nil)!
        // An example message to encrypt
        let plainText = decodeString.data(using: .utf8)!
        
        //        되는거
        let PK = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, plainText as CFData, nil)! as Data
        let asdfg = PK.base64EncodedString()
        return asdfg
        
    }
    private func ReturningUnDecodArray(dic: [String:Any]) -> (success: Bool, contractResult: getShaerFromSmartContract?){
        do{
            let smartContract = try getShaerFromSmartContract(from: dic)
            print("✅contract parse success")
            //            print("contract parse value : \(smartContract.items[0].doctorRecode)")
            return (true, smartContract)
        }catch{
            return (false, nil)
        }
    }
    struct getShaerFromSmartContract {
        let items: [ShareStructForm]
        let success: Bool
        
        init(from dictionary: [String: Any]) throws {
            guard let success = dictionary["_success"] as? Bool else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid _success key"])
            }
            guard let data = dictionary["0"] as? [[Any]] else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data array"])
            }
            self.success = success
            self.items = try data.map { array in
                do {
                    return try ShareStructForm(from: array)
                } catch {
                    print("Failed to parse Item from array: \(array), error: \(error.localizedDescription)")
                    throw error
                }
            }
        }
    }
    struct ShareStructForm: Codable {
        var index: BigUInt
        var patient_key: String
        
        init(index: BigUInt,patient_key: String){
            self.index = index
            self.patient_key = patient_key
        }
        init(from array: [Any]) throws {
            guard array.count == 2 else {
                throw NSError(domain: "Invalid Array", code: 1, userInfo: [NSLocalizedDescriptionKey: "Array does not contain exactly 8 elements"])
            }
            guard let index = array[0] as? BigUInt else {
                throw NSError(domain: "Invalid id", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(array[0])"])
            }
            guard let patient_key = array[1] as? String else {
                throw NSError(domain: "Invalid value", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid value"])
            }
            self.index = index
            self.patient_key = patient_key
            
        }
    }
    
    private func getSymetricKeys(array: getShaerFromSmartContract, account: String) -> (success: Bool, contractResult: [ShareStructForm]?){
        var returnItem: [ShareStructForm] = []
        guard let privatKey = getPrivateKeyFromKeyChain(account: account) else{
            return (false,nil)
        }
        for item in array.items{
            //            대칭키 복호화 후 새로운 배열 리턴
            let symetricKey = prkeyDecoding(privateKey: privatKey, encodeKey: item.patient_key)
            if symetricKey.success{
                print("✅decode Key success")
                print("decode key value : \(symetricKey.decodeKey)")
                returnItem.append(ShareStructForm(index: item.index, patient_key: symetricKey.decodeKey))
                
            }else{
                print("❌시메트릭키 뽑아오기 실패")
//                print("Undecode key value : \(item.patientKey)")
            }
        }
        return (true, returnItem)
    }
}
