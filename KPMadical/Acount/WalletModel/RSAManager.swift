//
//  RSAManager.swift
//  KPMadical
//
//  Created by Junsung Park on 4/4/24.
//

import Foundation
import web3swift
import Web3Core
import CryptoSwift
import BigInt
class RSAKeyManager: KeystoreKeyChain{
//    RSA KeyPair 생성 및 각 키 키체인에 저장
    func generateRSAKeyPair(keySize: Int = 1024,account: String) -> (success: Bool,pubKey: SecKey?, priKey: SecKey?) {
        let attributes: [String: Any] = [
            //            SecItem.h 에 정의된 KeyType 설정
            kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
            //            요청된 키 크기의 비트단위. CFNumberRef , CFStringRef 값이여야한다.
            kSecAttrKeySizeInBits as String:      keySize,
            //            키값 딕셔너리 에 설정될 수 잇다.
            kSecPrivateKeyAttrs as String: [
                //                키체인 저장
                kSecAttrIsPermanent as String:    true,
                //                키체인 식별자.
                kSecAttrApplicationTag as String: "com.knp.KpMadical.privatekey_\(account)".data(using: .utf8)!
            ],
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String:    true,
                kSecAttrApplicationTag as String: "com.knp.KpMadical.publickey_\(account)".data(using: .utf8)!
            ]
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Failed to generate private key: \(error!.takeRetainedValue() as Error)")
            return (false,nil, nil)
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to generate public key from private key.")
            return (false,nil, nil)
        }
        
        return (true,publicKey, privateKey)
    }
//    RSA 개인키 밑 스트링 값 추출
    func getStringRSAPrivateKey(account: String)->(success: Bool, privateKey: String, publickey: String){
        let privateKeyTag = "com.knp.KpMadical.privatekey_\(account)"
        let publicKeyTag = "com.knp.KpMadical.publickey_\(account)"
        let privateQuery: [String:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: privateKeyTag.data(using: .utf8)!,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true
        ]
        let publicQuery: [String:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: publicKeyTag.data(using: .utf8)!,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true
        ]
        var privateKeyRef: CFTypeRef?
        let pristatus = SecItemCopyMatching(privateQuery as CFDictionary, &privateKeyRef)
        guard pristatus == errSecSuccess else{
            print("RSA 개인키 가져오기 실패 \(pristatus)")
            return(false,"","")
        }
        var publicKeyRef: CFTypeRef?
        let pubstatus = SecItemCopyMatching(publicQuery as CFDictionary, &publicKeyRef)
        guard pubstatus == errSecSuccess else{
            print("RSA 공개키 가져오기 실패 \(pubstatus)")
            return(false,"","")
        }
        guard let privateKeyRef = privateKeyRef else {
            print("개인키 nil")
            return(false,"","")
        }
        var error: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKeyRef as! SecKey, &error) as Data? else{
            print(error!.takeRetainedValue() as Error)
            return(false,"","")
        }
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKeyRef as! SecKey, &error) as Data? else{
            print(error!.takeRetainedValue() as Error)
            return(false,"","")
        }
        return (true,privateKeyData.base64EncodedString(),publicKeyData.base64EncodedString())
    }
    
    
    //    RSA 개인키 암호화
    func RSAPrivateKeyCrypto(privateKey: String, RSAprivatKey: String) -> (success: Bool,rsaSecPrivateKey: String){
        //        대칭키 암호화에 사용될 Nonce
        let NonceString = "1997b0211a19980131252955df21d7f3"
        //        전달된 개인키 String 값을 활용하여 sha256 비밀키 생성
        let secKey = Array(privateKey.sha256().bytes.prefix(32))
        //        암호화 할 RSA 개인키
        guard let encodeRSA = RSAprivatKey.data(using: .utf8) else{
            print("RSA 개인키 데이터 변환 실패")
            return (false,"")
        }
        guard let iv = NonceString.hexaBytes else{
            print("iv 반환 실패")
            return (false,"")
        }
        do{
            //            aes 객체 생성 암호화에 사용될 키, iv 패딩값 설정
            let aes = try AES(key: secKey, blockMode: CBC(iv: iv), padding: .pkcs7)
            //            aes 객체로 RSA 개인키 암호화
            let encryptedData = try aes.encrypt(encodeRSA.bytes)
            //            암호화된 RSA 개인키 데이터 형식으로 반환
            let encryptedDataOBJ = Data(encryptedData)
            let StringRSASecPriKey = encryptedDataOBJ.base64EncodedString()
            return (true,StringRSASecPriKey)
        }catch{
            print("RSA 개인키 암호화 진행\(error)")
            return (false,"")
        }
    }
//    RSA 개인키 복호화
    func recoverRSAPrivateKey(account: String,encodeString: String, password: String) -> (success: Bool, RSAPrivate: String){
        let NonceString = "1997b0211a19980131252955df21d7f3"
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: account)else{
            print("키스토어 데이터 불러오기 실패")
            return (false,"")
        }
        guard let keystore = BIP32Keystore(keystoreData) else{
            print("keystore 객채 생성 실패")
            return (false,"")
        }
        guard let accountAddress = keystore.addresses?.first else{
            print("계정주소 불러오기 실패")
            return (false,"")
        }
        guard let encryptedData = Data(base64Encoded: encodeString) else{
            print("디코딩 실패")
            return (false,"")
        }
        guard let iv = NonceString.hexaBytes else{
            print("iv 추출 실패")
            return (false,"")
        }
        do{
//            개인키를 가져온다.
            let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: password, account: accountAddress)
//            개인키 String 반환
            let privateKeyHexString = privateKeyData.toHexString()
//            반환된 개인키 sha256 키 생성
            let seckey = Array(privateKeyHexString.sha256().bytes.prefix(32))
//            secKey 로 대칭키 생성
            let aes = try AES(key: seckey, blockMode: CBC(iv: iv), padding: .pkcs7)
//            해독할 데이터 byte 로 변환
            let decrypteBytes = try aes.decrypt(encryptedData.bytes)
//            byte String 으로 변환
            if let decyptedString = String(data: Data(decrypteBytes), encoding: .utf8){
                return (true,decyptedString)
            }else{
                return (false,"")
            }
        }
        catch{
            print("recoverRSAPrivateKey Err : \(error)")
            return (false,"")
        }
        
    }
    func savePrivateKeyToKeyChain(privateKeyString: String,account: String) -> Bool{
        guard let keyData = Data(base64Encoded: privateKeyString)else{
            print("키 데이터 변환 실패")
            return false
        }
        let reGanerateKey: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(keyData as CFData, reGanerateKey as CFDictionary, &error) else{
            print("개인키 생성 실패 : \(String(describing: error?.takeRetainedValue()))")
            return false
        }
        
        let attributes: [String:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: "com.knp.KpMadical.privatekey_\(account)".data(using: .utf8)!,
            kSecValueRef as String: privateKey
        ]
        let deletiQuery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: "com.knp.KpMadical.privatekey_\(account)".data(using: .utf8)!
        ]
        SecItemDelete(deletiQuery as CFDictionary)
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        
        if status == errSecSuccess{
            return true
        }else{
            return false
        }
    }
//    지갑 복구 해서 저장된 개인키를 활용하여 공개키 암호화 밑 개인키 복호화 테스트
    func TestDecodeEncode(pubkey: String,account: String){
        let privateKeyTag = "com.knp.KpMadical.privatekey_\(account)"
        
        let privateQuery: [String:Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: privateKeyTag.data(using: .utf8)!,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true
        ]
        var privateKeyRef: CFTypeRef?
        let pristatus = SecItemCopyMatching(privateQuery as CFDictionary, &privateKeyRef)
        guard pristatus == errSecSuccess else{
            print("RSA 개인키 가져오기 실패 \(pristatus)")
            return
        }
        guard let privateKey = privateKeyRef else {
            print("개인키 nil")
            return
        }
        guard let secKey = privateKey as! SecKey? else{
            print("SecKey 생성 실패")
            return
        }
        
        let decoder = Data(base64Encoded: pubkey, options: .ignoreUnknownCharacters)!
        let attributes: [String:Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits): decoder.count * 8
        ]
        let pubKey = SecKeyCreateWithData(decoder as CFData, attributes as CFDictionary, nil)!
        
        let EncodeData = "가나다라 마바사".data(using: .utf8)!
//    암호화
        let Sec = SecKeyCreateEncryptedData(pubKey, .rsaEncryptionOAEPSHA256, EncodeData as CFData,nil)! as Data
        let DecodeString = Sec.base64EncodedString()
        guard let encryptedData = Data(base64Encoded: DecodeString) else {
            print("Base64 디코딩 실패")
            return
        }
//         복호화
        guard SecKeyIsAlgorithmSupported(secKey, .decrypt, .rsaEncryptionOAEPSHA256) else{
            print("알고리즘 지원 안됨")
            return
        }
        guard let decryptedData = SecKeyCreateDecryptedData(secKey, .rsaEncryptionOAEPSHA256, encryptedData as CFData, nil) as Data? else{
            print("복호화 실패")
            return
        }
        if let decryptedString = String(data: decryptedData, encoding: .utf8) {
            print("복호화 데이터 : \(decryptedString)")
        } else {
            print("복호화된 데이터를 문자열로 변환 실패")
        }
    }
}
