//
//  TestFunc.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//
import Foundation
import CryptoSwift
import web3swift
import Web3Core
import Security
import CryptoKit

class RSATest{
    let baseKey = "MIICXgIBAAKBgQCkYaHh2oi5lFWEncs1Gjqxh44zpVwvfmZWQSIqwSN9IiXY/MsWNqjsaPA7dApNKPN8XANvBRhXY1sr6IasOqyp3UUy7hDTvSDeUwimTS5D0xEG0oHORJYT7GrWioo7gP5TGDXzg9QuiNEDt/DN0w3QUfk8wdFGd79uRufFMQ2KewIDAQABAoGBAKJwpKNm7HPPhM7fi973A4dJ+JlK0JVSaFjWVqg/Yg2XQCV0clCKRVYRwUxPOJrVW//Jgc8lDs/UrFTwnJz4AoTjFj0WiS1gRMgDgWRbChOHClbGgCvUvIVkmglH5lm8OmgkCVXJUkqmj49zOAYmwKte937YX316eyjHUU1b8jXBAkEA8Sic+g+O3zNV44iBRlBL7Y8aIvJS19Qw9NmtxUY6jjBEMsGdqKKIf8sHdOfxFRNy+a8niD7qffLyaSWoP1WYGwJBAK5/ajIagy2iDDkmoN5hSNfPs7i3LfXxxnBNSvaTQ6Scz9OR2ywW1hpP+q14x0553DKwrzizZN+yBreLpc67vSECQQCKaNLfuno3pJERDFGV95P8fntzvzzI3uJSRXU0mkAVR6J8tx8zoEVTg0V+VXjKreT5ZQv9aI7RRtTWgGR2JTwtAkEAnTZUUiHKz8EwrAjeZJxXiYAq1p/Ku8wBUcqBYFfbWKKjJ2VAhp9odDpcig/H2S83MUA4DaiqmFOHc7RQRUqloQJAU1hpHPBobdwEBP/Yol1l7G/e94guPbidUfJQIHg0prtzpMZQ6Eh00ojKLEnWXhlV6SMeTV92FqZSwDUeBABiOw=="
    let publicKeyBase64 = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCyfpz1n52R3EOO4qdvzBSDOP98oyAnWJWbvtD9U+LYHbVWg03hDrhBVr0p3cvasBCfFjv6jJ7jdN5Hkptj5Qf76g9BQH72Hodevc5zEi379h9ZTmP0oTtLxw9U13MyPCPwFSC0kyeWrqZc0KSmbLbDxe/7tYv+AbqdpL2pvTDQ/wIDAQAB"
    
    
    
    let message = "IYsWjpiQFw/JXRhDAX5vcMr6DHbWdwr2yRQohR7mORyZuKN5vke4IhVgOQfKrz9Hl6ejSUCgABN71lhkUo52SHxFNp1KIUqYhvJeEQl+ubw2RN5NgeGfe4LREnHvpx6fOzuWyomf+EuwL8zHD/bDv8BpN/J9ofJL0HFzcTFISoc="
    
    
    var pem = "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAs6AofVx+UAXcVjnIU0Z5SAGO/LPlTunA9zi7jNDcIrZTR8ULHTrm\naSAg/ycNR1/wUeac617RrFeQuoPSWjhZPRJrMa3faVMCqTgV2AmaPgKnPWBrY2ir\nGhnCnIAvD3sitCEKultjCstrTA71Jo/BuVaj6BVgaA/Qn3U9mQ+4JiEFiTxy4kOF\nes1/WwTLjRQYVf42oG350bTKw9F0MklTTZdiZKCQtc3op86A7VscFhwusY0CaZfB\nlRDnTgTMoUhZJpKSLZae93NVFSJY1sUANPZg8TzujqhRKt0g5HR/Ud61icvBbcx8\n+a3NzmuwPylvp5m6hz/l14Y7UZ8UT5deywIDAQAB\n-----END RSA PUBLIC KEY-----\n"
    
    
    let pr = "MIICXAIBAAKBgQCuo3HFgBHW6ACMgXRyWkJwH/J1GbBedXDRcYqtxTKoyDyvb7VsSMfrW1m8xP2jiiHg7UadFqcQe9YAK9403273J6jFX15iXSqiDWr+mLHizfvJ7pO/1jxw0knRD4eDdfs+cVHECyLwunCEEhZE6J+c24AzYf17w4tfWNDIyp5O/wIDAQABAoGARUnPz/5aFZwC67xJCT3KclYail9g3HlYA6E61msRCGo5uZlmr8nImBasafr2bzZU7rr1c0oTirS3WWYOSYgErB6v9WHr1pg/Rnh0Ts134Oybch/lsa6EpNYbRWAzImPviVvAXyOBvyeMhdBBNzj8umyqdcvYg05+2DNPcg+6r1ECQQDjsQarLmOrMrwnxxeaR3qDA8Cyt9XsCSHl0YF3WX6G/yQGvY/Fx6Ub3duN2LJ2moOzHETjF7UrVN6ceHiHceejAkEAxFnYAflJ7tBuPR5n83X7Ubgc0Bzgt5eFZpdZRJFQauFFhsdfLajt/yPEGICGoQCsc2xaz83SBmat7LB5sy/g9QJAa6gJGikt8QVlF324ODcxwv6kPxxS5m6O+4XqrA7Bl3zNgO5iK0axV5K3u8LI5vE58hccry9HdvyC4QLJImmF9wJBAK1cAcqkVnGDF4HhAbjEF1PscYwRoxqVrlOJF2jhwBXNtbws9Uz0FMWqx202tScb2CbEqV1GBMRgDfmnSpw5jq0CQBH6CqkihxH1AnIiVRRcdpw/UPqkHq8+BunBKNdXeOLl7ClOtfMKmc/f7H866tE6/HBq9UV+jJo7SMaRT7MTL+M="
    let target = "QnPV7AIBUyDtpcVs2IVZLy+l4BGTX2KQ2dn2a5vSQy07e5A6C2t9Tlh4sXmVP5+AmC0RK+PstNScN3WXVszEtwfCOzv2qyi2gJofcEoBWTgI5b+2ApjuzKj11PFQ5t0+U4uIF2h6xtBxGlQmDnCyB8ZygY4COmR9lIIza09p2S4="
    
    // Construct DER data from the remaining PEM data
//    내 개인키로 대칭키 복호화
    func prkeyDecoding() {
        guard let encryptedData = Data(base64Encoded: target) else {
            print("Base64 디코딩 실패")
            return
        }
        
        guard let privateKeyData = Data(base64Encoded: pr) else {
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
//            .rsaEncryptionOAEPSHA1
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

    //    상대 공개키로 암호화
    func createRSA(){
        let der = Data(base64Encoded: publicKeyBase64, options: .ignoreUnknownCharacters)!
        let attributes: [String: Any] = [
            String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
            String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
            String(kSecAttrKeySizeInBits): der.count * 8
        ]
        let key = SecKeyCreateWithData(der as CFData, attributes as CFDictionary, nil)!
        // An example message to encrypt
        let plainText = "박지원".data(using: .utf8)!
        
        //        되는거
        let PK = SecKeyCreateEncryptedData(key, .rsaEncryptionPKCS1, plainText as CFData, nil)! as Data
        let asdfg = PK.base64EncodedString()
        
        
        
        
        //
        //
        //        print("PK : \(asdfg)")
        
        //        print(privateKeyBase64)
        
        //        내 개인키로 복호화
        //        if let privateKeyData = Data(base64Encoded: baseKey){
        //            do{
        //                let rsaPrivateKey = try RSA(rawRepresentation: privateKeyData)
        //                print("RSA 키 생성 성공 : \(rsaPrivateKey)")
        //                if let encryptedMessage = Data(base64Encoded: message){
        //                    let encryptedMessage = Array(encryptedMessage)
        //                    do {
        //                        let decryptedBytes = try rsaPrivateKey.decrypt(encryptedMessage)
        //                        if let msg = String(data: Data(decryptedBytes),encoding: .utf8){
        //                            print(msg)
        //                        }
        //                    }
        //                }
        //            }catch{
        //                print("RSA 키 생성 실패: \(error)")
        //            }
        //        }else{
        //            print("Base64 디코딩 실패")
        //        }
        
        //
        //
        //
        ////
        //        do{
        //            // Alice Generates a Private Key
        //            let alicesPrivateKey = try RSA(keySize: 1024)
        //            let privateKeyData = try alicesPrivateKey.externalRepresentation()
        //            // Data 객체를 Base64 인코딩된 문자열로 변환합니다.
        //            let privateKeyBase64 = privateKeyData.base64EncodedString()
        //            // Alice shares her **public** key with Bob
        //            let alicesPublicKeyData = try alicesPrivateKey.publicKeyExternalRepresentation()
        //            let publicKeyBase64 = alicesPublicKeyData.base64EncodedString()
        //            // Bob receives the raw external representation of Alices public key and imports it
        //            let bobsImportOfAlicesPublicKey = try RSA(rawRepresentation: alicesPublicKeyData)
        //
        //            // Bob can now encrypt a message for Alice using her public key
        //            let message = "박지원"
        //            let privateMessage = try bobsImportOfAlicesPublicKey.encrypt(message.bytes)
        //
        //            // This results in some encrypted output like this
        //            // URcRwG6LfH63zOQf2w+HIllPri9Rb6hFlXbi/bh03zPl2MIIiSTjbAPqbVFmoF3RmDzFjIarIS7ZpT57a1F+OFOJjx50WYlng7dioKFS/rsuGHYnMn4csjCRF6TAqvRQcRnBueeINRRA8SLaLHX6sZuQkjIE5AoHJwgavmiv8PY=
        //
        //            // Bob can now send this encrypted message to Alice without worrying about people being able to read the original contents
        //
        //            // Alice receives the encrypted message and uses her private key to decrypt the data and recover the original message
        //            let originalDecryptedMessage = try alicesPrivateKey.decrypt(privateMessage)
        //            print("private Key : \(privateKeyBase64)")
        //            print("public Key : \(publicKeyBase64)")
        //            print("privateMessage : \(privateMessage)")
        //            print(String(data: Data(originalDecryptedMessage), encoding: .utf8))
        //            // "Hi Alice! This is Bob!"
        //        } catch{
        //            print("failed")
        //        }
    }
    //     키 생성
    func generateRSAKeyPair(keySize: Int = 1024) -> (publicKey: SecKey?, privateKey: SecKey?) {
        let attributes: [String: Any] = [
            //            SecItem.h 에 정의된 KeyType 설정
            kSecAttrKeyType as String:            kSecAttrKeyTypeRSA,
            //            요청된 키 크기의 비트단위. CFNumberRef , CFStringRef 값이여야한다.
            kSecAttrKeySizeInBits as String:      keySize,
            //            키값 딕셔너리 에 설정될 수 잇다.
            kSecPrivateKeyAttrs as String: [
                //                키체인 저장
                kSecAttrIsPermanent as String:    false,
                //                키체인 식별자.
                //                kSecAttrApplicationTag as String: "com.knp.KpMadical.privatekey".data(using: .utf8)!
            ],
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String:    false,
                //                kSecAttrApplicationTag as String: "com.knp.KpMadical.publickey".data(using: .utf8)!
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Failed to generate private key: \(error!.takeRetainedValue() as Error)")
            return (nil, nil)
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to generate public key from private key.")
            return (nil, nil)
        }
        
        return (publicKey, privateKey)
    }
    
    //    키 저장
    func SaveRSAKeyToKeyChain(key: SecKey, tag: String, isPrivateKey: Bool) -> OSStatus{
        var err: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(key, &err) as Data? else{
            print("키 변환 실패 \(err!.takeRetainedValue() as Error)")
            return errSecParam
        }
        let query: [String: Any] = [
            kSecClass as String:kSecClassKey,
            kSecAttrKeyType as String: SecKeyGetTypeID(),
            kSecAttrApplicationTag as String: tag.data(using: .utf8)!,
            kSecValueData as String: keyData,
            kSecAttrKeyClass as String: (isPrivateKey ? kSecAttrKeyClassPrivate : kSecAttrKeyClassPublic),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
}


class RSAManager: ObservableObject {
    @Published var publicKey: SecKey?
    @Published var privateKey: SecKey?
    
    init() {
        generateRSAKeyPair(keySize: 1024)
    }
    
    func generateRSAKeyPair(keySize: Int = 1024) {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: keySize,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ],
            kSecPublicKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Failed to generate private key: \(error!.takeRetainedValue() as Error)")
            return
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            print("Failed to generate public key from private key.")
            return
        }
        
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    func publicKeyToString(publicKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            print("공개키를 Data 객체로 변환하는 데 실패했습니다: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        return publicKeyData.base64EncodedString()
    }
    func privateToString(privateKey: SecKey) -> String? {
        var error: Unmanaged<CFError>?
        guard let privateKeyData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
            print("개인키 Data 객체로 변환하는 데 실패했습니다: \(error!.takeRetainedValue() as Error)")
            return nil
        }
        return privateKeyData.base64EncodedString()
    }
    
    
}



func decryptAES256() -> String? {
    let symatickey = "cd7e3533f4dd9af3e2d6e60f4f10b42cffeae4fa4d66274d02f7a92c2e3ef4f9"
    let data = "n05I/Ub/GC/mzQRmlNTl7w=="
    let iv = "4963b7334a46352623252955df21d7f3"
    // Base64 인코딩된 데이터를 디코딩
    guard let encryptedData = Data(base64Encoded: data) else {
        print("Invalid data")
        return nil
    }
    
    // 16진수 키를 바이트 배열로 변환
    guard let key = symatickey.hexaBytes else {
        print("Invalid key")
        return nil
    }
    
    // Base64 인코딩된 IV를 디코딩
    guard let iv = iv.hexaBytes else {
        print("Invalid IV")
        return nil
    }
    
    do {
        // AES 객체 생성
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        // 데이터 복호화
//        let decryptedBytes = try aes.decrypt(encryptedData.bytes)
        let decryptedBytes = try aes.decrypt(encryptedData.bytes)
    
        // 복호화된 데이터를 문자열로 변환
        if let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) {
            // 성공적으로 문자열로 변환됨
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
func decryptAES256(data base64EncodedData: String, key hexKey: String, iv base64IV: String) -> String? {
    // Base64 인코딩된 데이터를 디코딩
    guard let encryptedData = Data(base64Encoded: base64EncodedData) else {
        print("Invalid data")
        return nil
    }
    
    // 16진수 키를 바이트 배열로 변환
    guard let key = hexKey.hexaBytes else {
        print("Invalid key")
        return nil
    }
    
    // Base64 인코딩된 IV를 디코딩
    guard let iv = Data(base64Encoded: base64IV)?.bytes else {
        print("Invalid IV")
        return nil
    }
    
    do {
        // AES 객체 생성
        let aes = try AES(key: key, blockMode: CBC(iv: iv), padding: .pkcs7)
        // 데이터 복호화
        let decryptedBytes = try aes.decrypt(encryptedData.bytes)
        // 복호화된 데이터를 문자열로 변환
        guard let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) else {
            print("Decryption failed")
            return nil
        }
        return decryptedString
    } catch {
        print("Error in decryption: \(error)")
        return nil
    }
}
class AES256Util {
    // 키값 32바이트: AES256(24bytes: AES192, 16bytes: AES128)
    let SECRET_KEY = "de9efcfb0decd3e4f4c224ac28786d116737a2065094c99352d521d275134508"
    let IV = "uOSSUcI7emSg1JPht3VuAg=="
    
    func encrypt(string: String) -> String? {
        guard !string.isEmpty else { return "" }
        do {
            let aes = try getAESObject()
            let encrypted = try aes.encrypt(string.bytes)
            return encrypted.toBase64()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    func decrypt() -> String? {
        let dataU = "U2FsdGVkX1+5weKe4QF79cCVx7e0bQLsixdLj4YEWRJhR9XVazr2vtRqT3Mj09bCojR+Og4CYTpgxV3yymBdGEIHGaM0bpbZgZKe5wqMybQ="
        guard let data = Data(base64Encoded: dataU), !data.isEmpty else {
            print("nil")
            return nil
        }
        do {
            let decrypted = try getAESObject().decrypt(data.bytes)
            print("?")
            return String(bytes: decrypted, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
    
    func getAESObject() throws -> CryptoSwift.AES {
        guard let iv = Data(base64Encoded: IV)?.bytes else {
            throw NSError(domain: "InvalidIV", code: 0, userInfo: nil)
        }
        
        guard let keyDecodes = SECRET_KEY.hexaBytes else {
            throw NSError(domain: "InvalidKey", code: 0, userInfo: nil)
        }
        
        return try AES(key: keyDecodes, blockMode: CBC(iv: iv), padding: .pkcs7)
    }
}



//원하는 문자열로 key 생성 AES
//// 원하는 문자열
//let mySecretKeyString = "MyVerySecretKey"
//
//// 문자열의 SHA-256 해시를 생성하여 AES-256 키로 사용
//guard let key = mySecretKeyString.sha256().bytes.prefix(32).array else {
//    fatalError("Failed to generate key")
//}
