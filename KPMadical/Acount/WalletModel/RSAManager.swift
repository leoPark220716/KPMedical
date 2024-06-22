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
    func getPrivateKeyFromKeyChain(account: String) -> SecKey? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: "com.knp.KpMadical.privatekey_\(account)".data(using: .utf8)!,
            kSecReturnRef as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            print("Failed to retrieve private key with error code: \(status)")
            return nil
        }
        
        guard let key = item else {
            print("Failed to cast retrieved item to SecKey")
            return nil
        }
        
        return (key as! SecKey)
    }
    func convertSecKeyToPEM(privateKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        guard let cfdata = SecKeyCopyExternalRepresentation(privateKey, &error) else {
            print("Failed to extract private key data: \(error!.takeRetainedValue())")
            return nil
        }
        let keyData = cfdata as Data
        let base64Key = keyData.base64EncodedString(options: [.lineLength64Characters, .endLineWithLineFeed])
        let pemKey = """
           -----BEGIN PRIVATE KEY-----
           \(base64Key)
           -----END PRIVATE KEY-----
           """
        return pemKey
    }
    func decryptAES(encryptedData: String, aesKey: Data, iv: [UInt8]) -> String? {
        guard let data = Data(base64Encoded: encryptedData) else {
            print("Failed to convert base64 string to Data")
            return nil
        }
        
        do {
            let decrypted = try AES(key: aesKey.bytes, blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(data.bytes)
            let decryptedData = Data(decrypted)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption failed: \(error.localizedDescription)")
            return nil
        }
    }

    func tests(account: String) {
        let encryptedDataBase64 = "l0NXg5xFWpEShpvgYpyMAOrnccgAHlhMMcURq0vT+TMS5thgXvWTTpETtyOonunp9irYDwwI/7CUhE0NowArh2b6TOLFUIzZCrXcYitUzEluwv6tXyAoTXGMRMKe208i7DFm5EovH+6+/DCL27DJyk8lnQRiKpv2u9NdPSBNe4U="
        let ivHexString = "8890a77a0d69739305599bbb8f8773d0"

        if let privateKey = getPrivateKeyFromKeyChain(account: account) {
            guard let encryptedData = Data(base64Encoded: encryptedDataBase64) else {
                print("Failed to convert encrypted data from base64 string")
                return
            }
            
            // RSA 개인키를 사용하여 데이터를 복호화하여 AES 키를 추출합니다.
            var error: Unmanaged<CFError>?
            guard let aesKeyData = SecKeyCreateDecryptedData(privateKey, .rsaEncryptionOAEPSHA256, encryptedData as CFData, &error) as Data? else {
                print("Decryption failed: \(String(describing: error?.takeRetainedValue()))")
                return
            }
            
            // IV 값을 바이트 배열로 변환합니다.
            let iv = ivHexString.hexaBytes
            
            // AES 키와 IV를 사용하여 데이터를 복호화합니다.
            if let decryptedString = decryptAES(encryptedData: encryptedDataBase64, aesKey: aesKeyData, iv: iv!) {
                print("Decrypted string: \(decryptedString)")
            } else {
                print("Failed to decrypt data")
            }
        } else {
            print("Failed to retrieve private key")
        }
    }
//    개인키 복호화
    func prkeyDecoding(privateKey: SecKey,encodeKey: String) -> (success: Bool,decodeKey: String) {
        let encryptedDataBase64 = encodeKey
        guard let encryptedData = Data(base64Encoded: encryptedDataBase64) else {
            print("Base64 디코딩 실패")
            return (false, "")
        }
        
        let algo: SecKeyAlgorithm = .rsaEncryptionPKCS1
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algo) else {
            print("알고리즘 지원 안됨")
            return (false, "")
        }
        
        var error: Unmanaged<CFError>?
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algo, encryptedData as CFData, &error) as Data? else {
            print("복호화 실패: \(error!.takeRetainedValue())")
            return (false, "")
        }
        
        if let decryptedString = String(data: decryptedData, encoding: .utf8) {
            print("복호화 데이터: \(decryptedString)")
            return (true, decryptedString)
        } else {
            print("복호화된 데이터를 문자열로 변환 실패")
            return (false, "")
        }
    }
//    대칭키로 암호화 데이터 복호화
    func decodeMedicalData(symatricKey: String, encodeData: String) -> (success:Bool,result:String){
        let ivString = "8890a77a0d69739305599bbb8f8773d0"
        
        guard let encryptedData = Data(base64Encoded: encodeData) else{
            print("❌ 복호화 데이터 디코딩 실패")
            return (false,"")
        }
        guard let keyData = Data(base64Encoded: symatricKey) else {
            print("❌ 키 디코딩 실패")
            return (false,"")
        }
        guard let iv = ivString.hexaBytes else{
            print("❌ IV 디코딩 실패")
            return (false,"")
        }
        if iv.count != 16{
            print("❌ IV 길이")
            return (false,"")
        }
        do{
            // AES 객체 생성
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
            // 데이터 복호화
            let decryptedBytes = try aes.decrypt(encryptedData.bytes)
            
            // 복호화된 데이터를 문자열로 변환
            if let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) {
                // 성공적으로 문자열로 변환됨
                print("✅ success decode data : \(decryptedString)")
                return (true,decryptedString)
            } else {
                // UTF-8 문자열로 변환 실패. 데이터의 처음 몇 바이트를 로깅
                let sampleData = Data(decryptedBytes.prefix(20)) // 처음 20바이트 예제
                print("❌Decryption failed. Data sample (first 20 bytes): \(sampleData.map { String(format: "%02x", $0) }.joined())")
                return (false,"")
            }
        }catch{
            print("❌Error in decryption: \(error)")
            return (false,"")
        }
    }
    
    func prkeyDecoding2(privateKeyString: String) {
        let encryptedDataBase64 = "BBU2d/FLT/rXEKz9m3KDzNMYbB8RXJ1IqPv4u4JHDfVH6DmLU+6SzLq7hYb5/0s2w9kHxxOFalnuZ8jxoyC4JlzL7RTiPvbjAXzC8c2KFdUAtxNjUMA5D/QKqoXWDpvE8X6vjecIbmddNUB29xWfcx7UdTN3JGKzvyDZ7Ol7HsY="
        print(privateKeyString)
        guard let encryptedData = Data(base64Encoded: encryptedDataBase64) else {
            print("Base64 디코딩 실패")
            return
        }
        guard let privateKeyData = pemToBase64EncodedData(pemString:privateKeyString) else {
            print("Base64 디코딩 실패")
            return
        }
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: 1024,
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateWithData(privateKeyData as CFData, attributes as CFDictionary, &error) else {
            print("개인키 생성 실패: \(error!.takeRetainedValue())")
            return
        }
        
        let algo: SecKeyAlgorithm = .rsaEncryptionPKCS1
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, algo) else {
            print("알고리즘 지원 안됨")
            return
        }
        
        guard let decryptedData = SecKeyCreateDecryptedData(privateKey, algo, encryptedData as CFData, &error) as Data? else {
            print("복호화 실패: \(error!.takeRetainedValue())")
            return
        }
        
        if let decryptedString = String(data: decryptedData, encoding: .utf8) {
            print("복호화 데이터\(decryptedString)")
        } else {
            print("복호화된 데이터를 문자열로 변환 실패")
        }
    }
    func pemToBase64EncodedData(pemString: String) -> Data? {
        // PEM 형식의 헤더와 푸터를 제거
        let cleanedPemString = pemString
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
        print(cleanedPemString)
        // Base64 디코딩
        guard let base64Data = Data(base64Encoded: cleanedPemString) else {
            print("Base64 디코딩 실패")
            return nil
        }
        
        return base64Data
    }
    func createRSA(){
        let htpubkey = "MIGJAoGBAK/XHqcstk7n9adlBPORG6nMYBi97YtpbS/M4PUt1OTatjfwSskvYRfBe/iJQk7E98DdF0DJaCqmgcyhyPi8iCT7V/FJly8Jlv4scqIg4/cYJqnBelZG+B3pr2KAlHpSZS0VjazEbpUA16Xc6veMXQztV65sEwbAaRY54Ub0n1elAgMBAAE="
        let der = Data(base64Encoded: htpubkey, options: .ignoreUnknownCharacters)!
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits): der.count * 8
        ]
        let key = SecKeyCreateWithData(der as CFData, attributes as CFDictionary, nil)!
        // An example message to encrypt
        let plainText = "박지원 사랑해".data(using: .utf8)!
        //        되는거
        let PK = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, plainText as CFData, nil)! as Data
        let asdfg = PK.base64EncodedString()
        print("PK : \(asdfg)")
    }
    func decryptAES256() -> String? {
        let symatickey = "knzSMj6gRpwfLtyCTQ/qbQ4MVrqII/6S+O03H6oRn7U="
        let data = "U2FsdGVkX18znwjGeglKLITLpdawK0RUG1CrzAe35vw="
        let ivHexString = "8890a77a0d69739305599bbb8f8773d0"
        
        // Base64 인코딩된 데이터를 디코딩
        guard let encryptedData = Data(base64Encoded: data) else {
            print("Invalid data")
            return nil
        }
        print("Encrypted data: \(encryptedData.map { String(format: "%02x", $0) }.joined())")
        
        // Base64 인코딩된 키를 디코딩
        guard let keyData = Data(base64Encoded: symatickey) else {
            print("Invalid key")
            return nil
        }
        print("Key data: \(keyData.map { String(format: "%02x", $0) }.joined())")
        
        // IV를 바이트 배열로 변환
        guard let iv = ivHexString.hexaBytes as [UInt8]? else {
            print("Invalid IV")
            return nil
        }
        print("IV data: \(iv.map { String(format: "%02x", $0) }.joined())")
        
        do {
            // AES 객체 생성
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
            // 데이터 복호화
            let decryptedBytes = try aes.decrypt(encryptedData.bytes)
            
            // 복호화된 데이터를 문자열로 변환
            if let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) {
                return decryptedString
            } else {
                // UTF-8 문자열로 변환 실패. 데이터의 처음 몇 바이트를 로깅
                let sampleData = Data(decryptedBytes.prefix(20)) // 처음 20바이트 예제
                print("Decryption failed. Data sample (first 20 bytes): \(sampleData.map { String(format: "%02x", $0) }.joined())")
                return nil
            }
            
        } catch {
            print("Error in decryption: \(error)")
            return nil
        }
    }
    
}

extension String {
    var hexaBytes: [UInt8]? {
        var bytes = [UInt8]()
        var startIndex = index(startIndex, offsetBy: 0)
        
        while startIndex < endIndex {
            let endIndex = index(startIndex, offsetBy: 2, limitedBy: endIndex) ?? endIndex
            let hexStr = String(self[startIndex..<endIndex])
            if let byte = UInt8(hexStr, radix: 16) {
                bytes.append(byte)
            } else {
                return nil
            }
            startIndex = endIndex
        }
        return bytes
    }
}


