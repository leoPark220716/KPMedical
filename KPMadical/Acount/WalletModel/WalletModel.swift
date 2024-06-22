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
    func GetWalletPublicKey(account: String) -> (success: Bool, addres: String) {
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false, "")
        }
        guard let keystore = BIP32Keystore(keystoreData)else{
            print("키스토어 생성 실패")
            return (false, "")
        }
        guard let accountAddress = keystore.addresses?.first else {
            print("계정 주소를 찾을 수 없습니다.")
            return (false, "")
        }
        print("공개키 키복 \(accountAddress.address)")
        return (true,accountAddress.address)
        
    }
    func getWalletPrivateKey(account: String,password: String) -> (success: Bool, key: Data?){
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false, nil)
        }
        guard let keystore = BIP32Keystore(keystoreData)else{
            print("키스토어 생성 실패")
            return (false, nil)
        }
        guard let accountAddress = keystore.addresses?.first else {
            print("계정 주소를 찾을 수 없습니다.")
            return (false, nil)
        }
        do{
            let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: password, account: accountAddress)
            print("공개키 키복 \(accountAddress.address)")
            print(privateKeyData.toHexString())
            return (true,privateKeyData)
        }catch{
            return (false, nil)
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
        guard let providerURL = URL(string: "https://kp-medical-chain.com") else {
            print("Invalid URL or address")
            return (false, "")
        }
        
        guard let keystore = BIP32Keystore(keystoreData)else{
            print("keystore 생성 실패")
            return (false, "")
        }
        let keystoreManager = KeystoreManager([keystore])
        do{
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            //            keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false, "")
            }
            //        abi 값 추출
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "json"), let abiString = try? String(contentsOf: abiUrl) else{
                print("ABI 파일 실패")
                return (false, "")
            }
            //            solidityCode 추출
            guard let bytecodeUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "bin"),
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
            print("공개키")
            print(contractPara)
            print("여기까지")
            
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
    func callConfirmSaveRecord(account: String, key: Data, contractAddress: String, hospitalID: UInt32, date: BigUInt,password: String) async -> (success:Bool,txHash: String) {
        print( "💶 HospitalID \(hospitalID)")
        print( "💶 unixTime \(date)")
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false,"")
        }
        let url = "https://kp-medical-chain.com"
        guard let providerURL = URL(string:url) else {
            print("Invalid URL or address")
            return (false,"")
        }
        guard let keystore = BIP32Keystore(keystoreData) else {
            print("keystore 생성 실패")
            return (false,"")
        }
        let keystoreManager = KeystoreManager([keystore])
        
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            
            // keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false,"")
            }
            print("👀 \(accountAddress.address)")
            print("👀 \(contractAddress)")
            // abi 값 추출
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "json"),
                  let abiString = try? String(contentsOf: abiUrl) else {
                print("ABI 파일 실패")
                return (false,"")
            }
            let contract = Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(contractAddress), abiVersion: 2)
            print("Create Contract")
            // 함수 호출 트랜잭션 생성
            guard let transaction = contract?.createWriteOperation(
                "confirmSaveRecord",
                parameters: [hospitalID,date] as [AnyObject],
                extraData: Data()
            ) else {
                print("트랜잭션 생성 실패")
                return (false,"")
            }
            print("Create Transaction")
            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            let gasPrice = try await web3.eth.gasPrice()
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            
            guard gasPrice <= maxGasPrice else {
                print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                return (false,"")
            }
            print("Create Nonce")
            // 트랜잭션 설정
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
            let increasedGasPrice = gasPrice * 120 / 100

            print("Current nonce: \(currentNonce)")
            transaction.transaction.nonce = currentNonce
            transaction.transaction.from = accountAddress
            transaction.transaction.chainID = BigUInt(142536)
            transaction.transaction.gasPrice = increasedGasPrice
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            let estimatedGasLimit = try await web3.eth.estimateGas(for: transaction.transaction, onBlock: .latest)
            transaction.transaction.gasLimit = estimatedGasLimit
            try! transaction.transaction.sign(privateKey: key)
            let result = try await transaction.writeToChain(password: password, sendRaw: true)
            guard let resultData = Data.fromHex(result.hash) else {
                return (false,"")
            }
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(estimatedGasLimit))")
            do{
                print("Transaction Hash")
                print(result.hash)
                if let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData){
                    print("트랜잭션 로그: \(String(describing: receipt.logs))")
                    print("트랜잭션 로그: \(String(describing: receipt.logs[0].data))")
                    if let firstLog = receipt.logs.first {
                        print("Address: \(firstLog.address.address)")
                        print("Block Hash: \(firstLog.blockHash.toHexString())")
                        print("Block Number: \(firstLog.blockNumber)")
                        print("Data: \(firstLog.data.toHexString())")
                        let hexString = firstLog.data.toHexString()
                        if let hexValue = BigUInt(hexString, radix: 16) {
                            let decimalValue = String(hexValue)
                            print("16진수 값: \(hexString)")
                            print("10진수 값: \(decimalValue)")
                        } else {
                            print("잘못된 16진수 값")
                        }
                        print("Log Index: \(firstLog.logIndex)")
                        print("Removed: \(firstLog.removed)")
                        print("Topics: \(firstLog.topics.map { $0.toHexString()})")
                        print("Transaction Hash: \(firstLog.transactionHash.toHexString())")
                        print("Transaction Index: \(firstLog.transactionIndex)")
                    }
                    return (true,result.hash)
                }else{
                    print("레시피를 받지 못함")
                    return (false,"")
                }
            }
            catch{
                print("receipt \(error.localizedDescription)")
                return (false,"")
            }
        } catch {
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return (false,"")
        }
    }
    func setRecordToShareSaveRecord(account: String, key: Data, contractAddress: String, param: [TransactionManager.SharedData], password: String) async -> (success: Bool, txHash: String) {
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false, "")
        }
        let url = "https://kp-medical-chain.com"
        guard let providerURL = URL(string: url) else {
            print("Invalid URL or address")
            return (false, "")
        }
        guard let keystore = BIP32Keystore(keystoreData) else {
            print("keystore 생성 실패")
            return (false, "")
        }
        let keystoreManager = KeystoreManager([keystore])
        
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false, "")
            }
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "json"),
                  let abiString = try? String(contentsOf: abiUrl) else {
                print("ABI 파일 실패")
                return (false, "")
            }
            let contract = Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(contractAddress), abiVersion: 2)
            
            // SharedData 구조체 배열을 스마트 컨트랙트가 기대하는 튜플 형식으로 변환
            let paramArray: [[AnyObject]] = param.map { sharedData in
                return [sharedData.index, sharedData.hospital_id, sharedData.hospital_key] as [AnyObject]
            }
            
            guard let transaction = contract?.createWriteOperation(
                "setRecordToShare",
                parameters: [paramArray] as [AnyObject],
                extraData: Data()
            ) else {
                print("트랜잭션 생성 실패")
                return (false, "")
            }
            
            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            let gasPrice = try await web3.eth.gasPrice()
            
            guard gasPrice <= maxGasPrice else {
                print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                return (false, "")
            }
            
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
            let increasedGasPrice = gasPrice * 120 / 100
            
            transaction.transaction.nonce = currentNonce
            transaction.transaction.from = accountAddress
            transaction.transaction.chainID = BigUInt(142536)
            transaction.transaction.gasPrice = increasedGasPrice
            
            let estimatedGasLimit = try await web3.eth.estimateGas(for: transaction.transaction, onBlock: .latest)
            transaction.transaction.gasLimit = estimatedGasLimit
            try transaction.transaction.sign(privateKey: key)
            let result = try await transaction.writeToChain(password: password, sendRaw: true)
            
            guard let resultData = Data.fromHex(result.hash) else {
                return (false, "")
            }
            
            if let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData) {
                print("트랜잭션 로그: \(String(describing: receipt.logs))")
                if let firstLog = receipt.logs.first {
                    print("Address: \(firstLog.address.address)")
                    print("Block Hash: \(firstLog.blockHash.toHexString())")
                    print("Block Number: \(firstLog.blockNumber)")
                    print("Data: \(firstLog.data.toHexString())")
                    if let hexValue = BigUInt(firstLog.data.toHexString(), radix: 16) {
                        print("16진수 값: \(firstLog.data.toHexString())")
                        print("10진수 값: \(String(hexValue))")
                    } else {
                        print("잘못된 16진수 값")
                    }
                    print("Log Index: \(firstLog.logIndex)")
                    print("Removed: \(firstLog.removed)")
                    print("Topics: \(firstLog.topics.map { $0.toHexString() })")
                    print("Transaction Hash: \(firstLog.transactionHash.toHexString())")
                    print("Transaction Index: \(firstLog.transactionIndex)")
                }
                return (true, result.hash)
            } else {
                print("레시피를 받지 못함")
                return (false, "")
            }
        } catch {
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return (false, "")
        }
    }
    func callConfirmEditRecord(account: String, key: Data, contractAddress: String, hospitalID: UInt32, date: BigUInt,password: String,index: BigUInt) async -> (success:Bool,txHash: String) {
        print( "💶 HospitalID \(hospitalID)")
        print( "💶 unixTime \(date)")
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false,"")
        }
        let url = "https://kp-medical-chain.com"
        guard let providerURL = URL(string:url) else {
            print("Invalid URL or address")
            return (false,"")
        }
        guard let keystore = BIP32Keystore(keystoreData) else {
            print("keystore 생성 실패")
            return (false,"")
        }
        let keystoreManager = KeystoreManager([keystore])
        
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            
            // keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false,"")
            }
            print("👀 \(accountAddress.address)")
            print("👀 \(contractAddress)")
            // abi 값 추출
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "json"),
                  let abiString = try? String(contentsOf: abiUrl) else {
                print("ABI 파일 실패")
                return (false,"")
            }
            let contract = Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(contractAddress), abiVersion: 2)
            print("Create Contract")
            // 함수 호출 트랜잭션 생성
            guard let transaction = contract?.createWriteOperation(
                "confirmEditRecord",
                parameters: [index,hospitalID,date] as [AnyObject],
                extraData: Data()
            ) else {
                print("트랜잭션 생성 실패")
                return (false,"")
            }
            print("Create Transaction")
            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            let gasPrice = try await web3.eth.gasPrice()
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            
            guard gasPrice <= maxGasPrice else {
                print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                return (false,"")
            }
            print("Create Nonce")
            // 트랜잭션 설정
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
            let increasedGasPrice = gasPrice * 120 / 100

            print("Current nonce: \(currentNonce)")
            transaction.transaction.nonce = currentNonce
            transaction.transaction.from = accountAddress
            transaction.transaction.chainID = BigUInt(142536)
            transaction.transaction.gasPrice = increasedGasPrice
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            let estimatedGasLimit = try await web3.eth.estimateGas(for: transaction.transaction, onBlock: .latest)
            transaction.transaction.gasLimit = estimatedGasLimit
            try! transaction.transaction.sign(privateKey: key)
            let result = try await transaction.writeToChain(password: password, sendRaw: true)
            guard let resultData = Data.fromHex(result.hash) else {
                return (false,"")
            }
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(estimatedGasLimit))")
            do{
                print("Transaction Hash")
                print(result.hash)
                if let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData){
                    print("트랜잭션 로그: \(String(describing: receipt.logs))")
                    print("트랜잭션 로그: \(String(describing: receipt.logs[0].data))")
                    if let firstLog = receipt.logs.first {
                        print("Address: \(firstLog.address.address)")
                        print("Block Hash: \(firstLog.blockHash.toHexString())")
                        print("Block Number: \(firstLog.blockNumber)")
                        print("Data: \(firstLog.data.toHexString())")
                        let hexString = firstLog.data.toHexString()
                        if let hexValue = BigUInt(hexString, radix: 16) {
                            let decimalValue = String(hexValue)
                            print("16진수 값: \(hexString)")
                            print("10진수 값: \(decimalValue)")
                        } else {
                            print("잘못된 16진수 값")
                        }
                        print("Log Index: \(firstLog.logIndex)")
                        print("Removed: \(firstLog.removed)")
                        print("Topics: \(firstLog.topics.map { $0.toHexString()})")
                        print("Transaction Hash: \(firstLog.transactionHash.toHexString())")
                        print("Transaction Index: \(firstLog.transactionIndex)")
                    }
                    return (true,result.hash)
                }else{
                    print("레시피를 받지 못함")
                    return (false,"")
                }
            }
            catch{
                print("receipt \(error.localizedDescription)")
                return (false,"")
            }
        } catch {
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return (false,"")
        }
    }
    func sendTxForConfirm(account: String, key: Data) async -> Bool {
        
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return false
        }
        let url = "https://kp-medical-chain.com"
        guard let providerURL = URL(string:url) else {
            print("Invalid URL or address")
            return false
        }
        guard let keystore = BIP32Keystore(keystoreData) else {
            print("keystore 생성 실패")
            return false
        }
        let keystoreManager = KeystoreManager([keystore])
        
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            
            // keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return false
            }
            
            print("Create Nonce")
            // 트랜잭션 설정
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
            
            let tos = "0x1099530d4F290CcAb9bcdfb059CFF84922827526"
            var tx: CodableTransaction = .emptyTransaction
            tx.from = accountAddress
            tx.value = 0
            tx.nonce = currentNonce
            tx.gasLimit = BigUInt(21000)// 기본 가스 한도 (필요 시 조정)
            tx.gasPrice = BigUInt(2000000000)
            tx.chainID = BigUInt(142536)
            guard let toAddress = EthereumAddress(tos) else {
                print("Invalid 'to' address")
                return false
            }
            tx.to = toAddress
            try tx.sign(privateKey: key)
            print("개인키 데이터 길이: \(key.count) 바이트")
            guard let transactionEncode = tx.encode() else{
                print("트렌젝션 인코딩 실패")
                return false
            }
            
            let result = try await web3.eth.send(raw: transactionEncode)
            guard let resultData = Data.fromHex(result.hash) else{
                return false
            }
            do{
                print("Transaction Hash")
                print(result.hash)
                if let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData){
                    print("트랜잭션 로그: \(String(describing: receipt.logs))")
                    return true
                }else{
                    print("레시피를 받지 못함")
                    return false
                }
            }
            catch{
                print("receipt \(error.localizedDescription)")
                return false
            }
        } catch {
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return false
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
        let saveKeystorepassword = saveKeystorePassword(password: password, account: account.account)
        if !saveKeystorepassword{
            print("키스토어 비밀번호 저장 실패")
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
        let saveKeystorepassword = saveKeystorePassword(password: password, account: account.account)
        if !saveKeystorepassword{
            print("키스토어 비밀번호 저장 실패")
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
        print(StringRSAKeys.publickey)
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
        print("Wallet public Key : \(walletKeys.WalletPublicKey)")
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
    
    func recodeRead(account: String, key: Data, contractAddress: String, param1: BigUInt?, param2: BigUInt?,methodName: String) async -> (success: Bool, result: [String: Any]) {
        
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account) else {
            print("Failed to load keystore")
            return (false,[:])
        }
        let url = "https://kp-medical-chain.com"
        guard let providerURL = URL(string:url) else {
            print("Invalid URL or address")
            return (false,[:])
        }
        guard let keystore = BIP32Keystore(keystoreData) else {
            print("keystore 생성 실패")
            return (false,[:])
        }
        let keystoreManager = KeystoreManager([keystore])
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: .Custom(networkID: BigUInt(142536)), keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            
            // keystore 에 있는 계정 주소 뽑아옴
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return (false,[:])
            }
            print("👀 \(accountAddress.address)")
            print("👀 \(contractAddress)")
            // abi 값 추출
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords_sol_PersonalRecords", withExtension: "json"),
                  let abiString = try? String(contentsOf: abiUrl) else {
                print("ABI 파일 실패")
                return (false,[:])
            }
            let contract = Web3.Contract(web3: web3, abiString: abiString, at: EthereumAddress(contractAddress), abiVersion: 2)
            print("Create Contract")
            // 함수 호출 트랜잭션 생성
            guard let transaction = contract?.createReadOperation(
                methodName,
                parameters: [param1,param2] as [AnyObject],
                extraData: Data()
            ) else {
                print("트랜잭션 생성 실패")
                return (false,[:])
            }
            print("Create Transaction")
            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            let gasPrice = try await web3.eth.gasPrice()
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            
            guard gasPrice <= maxGasPrice else {
                print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                return (false,[:])
            }
            print("Create Nonce")
            // 트랜잭션 설정
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)

            print("Current nonce: \(currentNonce)")
            transaction.transaction.nonce = currentNonce
            transaction.transaction.from = accountAddress
            transaction.transaction.chainID = BigUInt(142536)
            transaction.transaction.gasPrice = gasPrice
            print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
            let estimatedGasLimit = try await web3.eth.estimateGas(for: transaction.transaction, onBlock: .latest)
            transaction.transaction.gasLimit = estimatedGasLimit
            try! transaction.transaction.sign(privateKey: key)
            let result: [String: Any]
            do{
                result = try await transaction.callContractMethod()
                return (true,result)
            }catch{
                print("Error: \(error)")
                return (false,[:])
            }
        } catch {
            print("트랜잭션 실패 에러: \(error.localizedDescription)")
            return (false,[:])
        }
    }
//    저장요청 컨트랙트 작성
    func callConfirmReqeust(account: String, key: Data, contractAddress: String, hospitalID: UInt32, date: BigUInt,password: String) async -> (success:Bool,txHash:String) {
        let firstConfirmSave = await callConfirmSaveRecord(account: account, key: key, contractAddress: contractAddress, hospitalID: hospitalID, date: date, password: password)
        if firstConfirmSave.success{
            return (firstConfirmSave)
        }
        let sendTx = await sendTxForConfirm(account: account, key: key)
        if !sendTx{
            return (false,"")
        }
        let secondConfirmSave = await callConfirmSaveRecord(account: account, key: key, contractAddress: contractAddress, hospitalID: hospitalID, date: date, password: password)
        return secondConfirmSave
    }
//    공유요청 컨트랙트
    func callShaerReqeust(account: String, key: Data, contractAddress: String, param: [TransactionManager.SharedData],password: String) async -> (success:Bool,txHash:String) {
        let firstConfirmSave = await setRecordToShareSaveRecord(account: account, key: key, contractAddress: contractAddress, param: param, password: password)
        if firstConfirmSave.success{
            return (firstConfirmSave)
        }
        let sendTx = await sendTxForConfirm(account: account, key: key)
        if !sendTx{
            return (false,"")
        }
        let secondConfirmSave = await setRecordToShareSaveRecord(account: account, key: key, contractAddress: contractAddress, param: param, password: password)
        return secondConfirmSave
    }
//    진료기록 수정요청 허가 컨트랙트
    func callEditReqeust(account: String, key: Data, contractAddress: String, hospitalID: UInt32, date: BigUInt,password: String,index: BigUInt) async -> (success:Bool,txHash:String) {
        let firstConfirmSave = await callConfirmEditRecord(account: account, key: key, contractAddress: contractAddress, hospitalID: hospitalID, date: date, password: password, index: index)
        if firstConfirmSave.success{
            return (firstConfirmSave)
        }
        let sendTx = await sendTxForConfirm(account: account, key: key)
        if !sendTx{
            return (false,"")
        }
        let secondConfirmSave = await callConfirmEditRecord(account: account, key: key, contractAddress: contractAddress, hospitalID: hospitalID, date: date, password: password, index: index)
        return secondConfirmSave
    }
    
    
}
//            let tos = "0x1099530d4F290CcAb9bcdfb059CFF84922827526"
//            var tx: CodableTransaction = .emptyTransaction
//            tx.from = accountAddress
//            tx.value = BigUInt(0.1) * BigUInt(10).power(18)
//            tx.nonce = 1
//            tx.gasLimit = BigUInt(21000)// 기본 가스 한도 (필요 시 조정)
//            tx.gasPrice = BigUInt(2000000000)
//            tx.chainID = BigUInt(142536)
//            guard let toAddress = EthereumAddress(tos) else {
//                print("Invalid 'to' address")
//                return false
//            }
//            tx.to = toAddress
//                try tx.sign(privateKey: key)
//                print("개인키 데이터 길이: \(key.count) 바이트")
//                guard let transactionEncode = tx.encode() else{
//                    print("트렌젝션 인코딩 실패")
//                    return false
//                }

//                let result = try await web3.eth.send(raw: transactionEncode)
//                guard let resultData = Data.fromHex(result.hash) else{
//                    return false
//                }
