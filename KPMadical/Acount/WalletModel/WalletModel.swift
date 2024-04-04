//
//  WalletModel.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import Foundation
import CryptoSwift
import web3swift
import Web3Core
import Security
import CryptoKit
import BigInt

class KNPWallet: RSAKeyManager{
    let walletHttp = WalletAPIRequest()
    func generateMnmonics() -> String{
        do {
            guard let newMnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128, language: .korean) else {
                return "니모닉 생성에 실패했습니다. 다시 시도해주세요."
            }
            return newMnemonics
        } catch {
            return "니모닉 생성에 실패했습니다. 다시 시도해주세요."
        }
    }
    //    지갑 생성 KeyChain 저장. 밑 개인키 반환
    func generateWallet(mnemonics: String, password: String, account: String) -> (success: Bool,privateKey: String, WalletPublicKey: String) {
        guard !mnemonics.isEmpty else {
            print("니모닉 빈배열")
            return (false,"","")
        }
        do {
            //            keystore 생성.
            guard let keystore = try BIP32Keystore(mnemonics: mnemonics, password: password) else {
                print("keystore 생성 실패")
                return (false,"","")
            }
            // 새로운 계정을 생성합니다.
            try keystore.createNewChildAccount(password: password)
            //            keystore 직렬화
            guard let keystoreData = try keystore.serialize()else{
                print("직렬화 실패")
                return (false,"","")
            }
            //            직렬화 keystore keychain 에 저장
            let saveStatus = saveToKeyChain(keystoreData: keystoreData, service: "com.knp.KpMadical_Wallet", account: account)
            if saveStatus != errSecSuccess {
                print("직렬화??? \(saveStatus)")
                return (false,"","")
            }
            // 첫 번째 주소를 가져옵니다.
            if let address = keystore.addresses?.first {
                let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: password, account: address)
                let privateKeyHexString = privateKeyData.toHexString()
                return (true,privateKeyHexString,address.address)
            } else {
                print("지갑 주소 가져오기 실패")
                return (false,"","")
            }
        } catch {
            print("지갑생성 에러 \(error)")
            return (false,"","")
        }
    }
    //    JWT 토큰을 가지고 유저 Account 추출
    func GetUserAccountString(token: String) -> (status: Bool,account:String){
        let sections = token.components(separatedBy: ".")
        if sections.count > 2 {
            if let payloadData = Data(base64Encoded: sections[1], options: .ignoreUnknownCharacters),
               let payloadJSON = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
               let userId = payloadJSON["user_id"] as? String {
                // user_id 값 출력
                return (true,userId)
            } else {
                print("Payload decoding or JSON parsing failed")
                return (false,"")
            }
        } else {
            print("Invalid JWT Token")
            return (false,"")
        }
    }
//    스마트 컨트랙트 배포
    func SmartContractDeploy(account: String, password:String, contractPara: String) async -> (success: Bool, ContractAddress: String){
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false, "")
        }
        guard let providerURL = URL(string: "http://203.234.103.157:3222") else {
            print("Invalid URL or address")
            return (false, "")
        }
        
        guard let keystore = BIP32Keystore(keystoreData)else{
            print("keystore 생성 실패")
            return (false, "")
        }
        let keystoreManager = KeystoreManager([keystore])
        do{
            let provider = try await Web3HttpProvider(url: providerURL, network: nil, keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            //            keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false, "")
            }
            //        abi 값 추출
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "json"), let abiString = try? String(contentsOf: abiUrl) else{
                print("ABI 파일 실패")
                return (false, "")
            }
            //            solidityCode 추출
            guard let bytecodeUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "bin"),
                  let bytecodeString = try? "0x"+String(contentsOf: bytecodeUrl) else {
                print("Bytecode 파일을 로드할 수 없습니다.")
                return (false, "")
            }
            //            solidityCode Data 형식으로 변환
            guard let bytecodeData = Data.fromHex(bytecodeString) else {
                print("바이트코드 문자열을 Data로 변환할 수 없습니다.")
                return (false, "")
            }
//            트랜젝션에 사용할 nonce 값 추출
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
//            배포할 컨트랙트 객체 생성
            let contract = Web3.Contract(web3: web3, abiString: abiString, at: accountAddress, abiVersion: 2)
//             배포 옵션 설정
            let deployOption = contract?.prepareDeploy(bytecode: bytecodeData, constructor: contract?.contract.constructor, parameters: [contractPara])
//            트랜잭션 설정
            deployOption?.transaction.nonce = currentNonce
            deployOption?.transaction.chainID = BigUInt(142536)
            deployOption?.transaction.to = .contractDeploymentAddress()
            deployOption?.transaction.from = accountAddress
            
            if let result = try await deployOption?.writeToChain(password: password, sendRaw: true){
                print("Transaction 전송 성공 \(result.hash)")
                guard let resultData = Data.fromHex(result.hash) else{
                    return (false, "")
                }
                do{
                    if let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData),
                       let contractAddress = receipt.contractAddress?.address {
                        print("트랜잭션 로그: \(String(describing: receipt.logs))")
                        print("트랜잭션 주소: \(contractAddress)")
                        return (true, contractAddress)
                    } else {
                        // receipt이 nil이거나 contractAddress가 nil일 때의 처리
                        print("올바른 트랜잭션 영수증 또는 계약 주소를 받지 못했습니다.")
                        return (false, "")
                    }
                }
                catch{
                    print("receipt \(error.localizedDescription)")
                    return (false, "")
                }
            }else{
                print("트랜잭션 실행 실패")
                return (false, "")
            }
            
        }catch{
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return (false, "")
        }
    }
//    트랜젝션 레시피 대기 메서드 200 초 동안 대기
    func getTransactionReceipt(web3: Web3, transactionHash: Data) async throws -> TransactionReceipt? {
        
        // 영수증 조회를 위한 반복 시도
        for _ in 0..<10 {
            if let receipt = try? await web3.eth.transactionReceipt(transactionHash) {
                return receipt
            }
            // 영수증이 아직 준비되지 않았다면 잠시 대기
            try await Task.sleep(nanoseconds: 2_000_000_000) // 예: 2초 대기
        }
        return nil // 영수증을 받지 못한 경우
    }
//    지갑 계정 복구
    func recoverWallet(mnemonics: String,account:String , password: String) -> (success:Bool, recoverAddres: String) {
        do {
            guard let keystore = try BIP32Keystore(mnemonics: mnemonics, password: password) else {
                return (false,"")
            }
            //            keystore 직렬화
            guard let keystoreData = try keystore.serialize()else{
                print("직렬화 실패")
                return (false,"")
            }
            //            직렬화 keystore keychain 에 저장
            let saveStatus = saveToKeyChain(keystoreData: keystoreData, service: "com.knp.KpMadical_Wallet", account: account)
            if saveStatus != errSecSuccess {
                print("직렬화??? \(saveStatus)")
                return (false,"")
            }
            // 복구된 계정의 첫 번째 주소를 가져옵니다.
            guard let address = keystore.addresses?.first else {
                print("계정 찾기 실패")
                return (false,"")
            }
            return(true, address.address)
        } catch {
            print("recover Error \(error)")
            return (false,"")
        }
    }
//    지갑 복구 버튼 클릭
    func OnTapRecoverButton(mnemonics: String , password: String, token: String) async -> Bool{
        let account = GetUserAccountString(token: token)
        if !account.status {
            print("계정 상태가 유효하지 않음")
            // 계정 상태가 유효하지 않을 때의 처리
            return false
        }
        let recover = recoverWallet(mnemonics: mnemonics, account: account.account, password: password)
        if !recover.success{
            print("계정 복구 실패")
            return false
        }
        let GetRSAEncode = await walletHttp.RecoverWalletWithRSA(token: token, uid: getDeviceUUID(), address: recover.recoverAddres, rsa: "", type: 1)
        if !GetRSAEncode.success{
            print("서버 저장 실패")
            return false
        }
        let decodeRSAString = recoverRSAPrivateKey(account: account.account, encodeString: GetRSAEncode.rsaEncrypt, password: password)
        if !decodeRSAString.success{
            print("RSA 개인키 복호화 실패")
            return false
        }
        let saveDecodeRSAKey = savePrivateKeyToKeyChain(privateKeyString: decodeRSAString.RSAPrivate, account: account.account)
        if !saveDecodeRSAKey{
            print("복호화 된 RSA 개인키 키채인에 저장 실패")
        }
        return saveDecodeRSAKey
    }
    
    
//    지갑 생성 버튼 눌렀을때 동작 함수.
    func OnTapOkButton(token: String, password: String, Mnemonics: String) async -> Bool{
        // 계정 상태 확인 및 처리
        let account = GetUserAccountString(token: token)
        if !account.status {
            print("계정 상태가 유효하지 않음")
            // 계정 상태가 유효하지 않을 때의 처리
            return false
        }
        
        // Wallet keychain 저장 후 privateKey 가져오기
        let walletKeys = generateWallet(mnemonics: Mnemonics, password: password, account: account.account)
        if !walletKeys.success {
            print("Wallet key 생성 실패")
            // Wallet key 생성 실패 시 처리
            return false
        }
        
        // RSA 공개키 및 개인키 생성 후 키체인에 저장
        let RSAKeys = generateRSAKeyPair(account: account.account)
        if !RSAKeys.success {
            print("RSA 키 쌍 생성 실패")
            // RSA 키 쌍 생성 실패 시 처리
            return false
        }
        
        // RSA 공개키 및 개인키 String으로 출력
        let StringRSAKeys = getStringRSAPrivateKey(account: account.account)
        if !StringRSAKeys.success {
            print("RSA 키 String 변환 실패")
            // RSA 키 String 변환 실패 시 처리
            return false
        }
        
        // 지갑 개인키로 RSA 개인키 암호화
        let RSASecKey = RSAPrivateKeyCrypto(privateKey: walletKeys.privateKey, RSAprivatKey: StringRSAKeys.privateKey)
        if !RSASecKey.success {
            print("RSA 개인키 암호화 실패")
            // RSA 개인키 암호화 실패 시 처리
            return false
        }
        print("rsa public Key : \(StringRSAKeys.publickey)")
        // 모든 작업이 성공적으로 완료되면, 지갑 정보를 서버에 저장
        let saveWalletInfo = await walletHttp.SaveWalletWithRSA(token: token, uid: getDeviceUUID(), address: walletKeys.WalletPublicKey, rsa: RSASecKey.rsaSecPrivateKey, type: 0)
        if !saveWalletInfo{
            print("서버 저장 실패")
            return false
        }
        let ContractOk =  await SmartContractDeploy(account: account.account, password: password, contractPara: StringRSAKeys.publickey)
        if !ContractOk.success{
            print("컨트랙트 배포 실패")
            return false
        }
        let SaveContractOk =  await walletHttp.SaveContractAddress(token: token, uid: getDeviceUUID(), contract: ContractOk.ContractAddress)
        if !SaveContractOk{
            print("컨트랙트 주소 저장 실패")
            return false
        }
        print("성공")
        return true
    }
}
