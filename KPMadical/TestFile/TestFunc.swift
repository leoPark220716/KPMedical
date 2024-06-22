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
import BigInt

class RSATest{
    let baseKey = "MIICXgIBAAKBgQCkYaHh2oi5lFWEncs1Gjqxh44zpVwvfmZWQSIqwSN9IiXY/MsWNqjsaPA7dApNKPN8XANvBRhXY1sr6IasOqyp3UUy7hDTvSDeUwimTS5D0xEG0oHORJYT7GrWioo7gP5TGDXzg9QuiNEDt/DN0w3QUfk8wdFGd79uRufFMQ2KewIDAQABAoGBAKJwpKNm7HPPhM7fi973A4dJ+JlK0JVSaFjWVqg/Yg2XQCV0clCKRVYRwUxPOJrVW//Jgc8lDs/UrFTwnJz4AoTjFj0WiS1gRMgDgWRbChOHClbGgCvUvIVkmglH5lm8OmgkCVXJUkqmj49zOAYmwKte937YX316eyjHUU1b8jXBAkEA8Sic+g+O3zNV44iBRlBL7Y8aIvJS19Qw9NmtxUY6jjBEMsGdqKKIf8sHdOfxFRNy+a8niD7qffLyaSWoP1WYGwJBAK5/ajIagy2iDDkmoN5hSNfPs7i3LfXxxnBNSvaTQ6Scz9OR2ywW1hpP+q14x0553DKwrzizZN+yBreLpc67vSECQQCKaNLfuno3pJERDFGV95P8fntzvzzI3uJSRXU0mkAVR6J8tx8zoEVTg0V+VXjKreT5ZQv9aI7RRtTWgGR2JTwtAkEAnTZUUiHKz8EwrAjeZJxXiYAq1p/Ku8wBUcqBYFfbWKKjJ2VAhp9odDpcig/H2S83MUA4DaiqmFOHc7RQRUqloQJAU1hpHPBobdwEBP/Yol1l7G/e94guPbidUfJQIHg0prtzpMZQ6Eh00ojKLEnWXhlV6SMeTV92FqZSwDUeBABiOw=="
    let publicKeyBase64 = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCyfpz1n52R3EOO4qdvzBSDOP98oyAnWJWbvtD9U+LYHbVWg03hDrhBVr0p3cvasBCfFjv6jJ7jdN5Hkptj5Qf76g9BQH72Hodevc5zEi379h9ZTmP0oTtLxw9U13MyPCPwFSC0kyeWrqZc0KSmbLbDxe/7tYv+AbqdpL2pvTDQ/wIDAQAB"
    
    let htpubkey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2xkBSA2x9IGy5Z/NjHH6Pzy04Gpyqrfk/XoYPWu5v10CY9CGX7aVHDilSKMIE7PiidNEyj+vd+htsGIKuJW4/R/lXu3w+KxM14ob4tOyqEFdCHDtP1HGLnRB9PP5od+pz6c0e//ElxA2kUwoeQzxxe5jvY/usUTKHIVNfGQ1otqa8+TtzsCsbQ2jgZ9x/vIps9d6pmGbQz+y+MxfYfLKqEEiOX8ieKzg7kHuUbWpFvGRJzoEqBdRMscVO+Mf75OEuQ0Kp2LocxMpFoYykNljwVFzUZdenIhO1z06gPVZkUweBUs2vFhEG8CffwkNZn7fbOTw27sWorUdiz7MSsyNMwIDAQAB"
    
    
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
        let der = Data(base64Encoded: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjz+79EQRDyZXdMhGCtXxn43AsXulZtLAz5Nl84brUD42Da3nPm5STyij8E5JEXa5RU/M13zguZhIN2kwXs7afeEx2+8MXEDkAZIMTOk2ATA2Z6JpKWiqNRMvj1DLrq2TPkDXrCW37UIul6AfXarRB+GwqDOSZxK2JXHtaHGQVNrkO/7yK9mfTPlZt3m8qc0igGrhyoXnWc09eZxyxpqzOudoOo6c2hmuMwRQaU0xTGZhPEItzyMH7gvmwKc5jOokRObjWSM86qCkU1gsGtTkHg8SIse1TrgS2Jf1JgQ+gaIUP+NvA99sj81RHNMguJHfOjjM/uR5w9lG3prm5DFePQIDAQAB", options: .ignoreUnknownCharacters)!
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
//        let symatickey = "cd7e3533f4dd9af3e2d6e60f4f10b42cffeae4fa4d66274d02f7a92c2e3ef4f9"
//        let data = "n05I/Ub/GC/mzQRmlNTl7w=="
//        let ivString = "4963b7334a46352623252955df21d7f3"
    let symatickey = "knzSMj6gRpwfLtyCTQ/qbQ4MVrqII/6S+O03H6oRn7U="
    let data = "K15KmRQKA/7GzInV4cWpA9M4uY31zOqZl4eDzsTl+BEE/hcxBruMDiYcR5J43w1TNMsESJxU4gcouwvZ1DsCtqxWjbQbyal+cfROIVG7Rj+5ee7dLdnpWVcUZqFvklZmQmXQl+PvoES+isXAd8nQXRJrxrF0hBwQjkvAEcqLH+tENrjLK4HJ8o5Le3Wa+EjNMg6Tb0QAel9WvI+UGiJ1lY/dPtaAoZQHF/4lqarQTVl4FY59K65TRyHp/4gcMEZi7RaA58kuVCqDIO9ctnh18QBvnDYe1OxczOGqxbICnTXwNGZTeVO1AD9PlZzLz/2B7N3Qz7Kxx02eCJ+A9kC5Eld78Vvjktq7Z8g+mfOYXYorH9xe0O/WLq2Yn89hC4BOB2uKdfsh8X0MjOdlJ3lSRRkY3bJRqL8Sd00d2R6KlKTXt35XrLzfzhidIj89dmKlUBkUWq6hRMkBEr7T3ccCmpLed4e7fdSSzEsR6PZKNo2abEpwIY8XtzD5qzZ909Toh2T99y1T0glrOwmbwoOZiyk9sm8Uz4fLvpRAPYMvtteUCzBK6mnJGOzZHJYZ4ANs"
//    let data = "6N9fJStPQe4+kTkfBn5GkA=="
    let ivString = "8890a77a0d69739305599bbb8f8773d0"
    // Base64 인코딩된 데이터를 디코딩
    guard let encryptedData = Data(base64Encoded: data) else {
        print("Invalid data")
        return nil
    }
    // Base64 인코딩된 키를 디코딩
        guard let keyData = Data(base64Encoded: symatickey) else {
            print("Invalid key")
            return nil
        }
    // Base64 인코딩된 키를 디코딩
//    guard let key = symatickey.hexaBytes else {
//          print("Invalid key")
//          return nil
//      }
    
    // Base64 인코딩된 IV를 디코딩
    let iv = ivString.hexaBytes!
        if iv.count != 16 {
            print("Invalid IV")
            return nil
        }
    do {
        // AES 객체 생성
        let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
        // 데이터 복호화
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
class GetKeystore: KeystoreKeyChain{
    
    func GetKeystorePrivateKey(){
        let NonceString = "1997b0211a19980131252955df21d7f3"
        //        z키 스토어 데이터 불러오기
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical", account: "test") else {
            print("Failed to load keystore")
            return
        }
        //        키스토어 데이터를 바탕으로 keystore 객채 생성
        guard let keystore = BIP32Keystore(keystoreData) else{
            print("keystore 불러오기 실패")
            return
        }
        //        키스토어 에 있는 공개 주소 가져오기
        guard let accountAddress = keystore.addresses?.first else {
            print("계정 주소 불러오기 실패")
            return
        }
        //        iv 값 textByte 가져오기
        guard let iv = NonceString.hexaBytes else {
            print("Invalid IV")
            return
        }
        do{
            //            개정 주소에 해당하는 개인키 데이터 가져오기
            let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: "strong password", account: accountAddress)
            //            개인키 String 값으로 변환
            let privateKeyHexString = privateKeyData.toHexString()
            //            변환된 개인키를 가지고 sha256 비밀키 생성
            let secKey = Array(privateKeyHexString.sha256().bytes.prefix(32))
            
            //            비밀키로 특정 데이터 암호화 (RSA 비밀키 암호화 예정)
            let dataToEncrypt = "Hello, world!".data(using: .utf8)!
            // secKey를 기반으로 SymmetricKey 생성
            //            let symmetricKey = SymmetricKey(data: secKey)
            
            let aes = try AES(key: secKey, blockMode: CBC(iv: iv), padding: .pkcs7)
            let encryptedData = try aes.encrypt(dataToEncrypt.bytes)
            let encryptedDataAsDataObject = Data(encryptedData)
            // Data 객체를 Base64 인코딩된 문자열로 변환
            let stringData = encryptedDataAsDataObject.base64EncodedString()
            // 암호화된 데이터를 Base64 인코딩된 문자열로 출력
            print(stringData)
        } catch{
            print("Error \(error)")
        }
    }
    //    저장된 RSA 개인키 해독
    func resolveData(){
        let decodeString = "pI317yXuWJ0dkRnsXX4A9PbY+XVIDXSnDayJwgbx5E4F9KzsSnRVlioYJdSjeWbY7icppeLa24IjJKbhV8wX62ud1VuyciC+mKTZhKWNmgrge9GytfmajUt/LyLuYtpxtBa4U+GNEjnfasGojpeiU0wL+Hf5n1YD/3jzbrvcKCj2iSYLI3vlWH5n60xisYCu5P1zl0Z7rF6SsEQWKcTugYTlPhxEwHkPZ0hv/2OELMNjv42a8zZNmFdMNCrKgpibXJBu2XUPFcMIASvzGKucVOY/ai3Ngy26BUGiwhw0Ih74kWw/2qj5OogP+Tv5Kmqs9Pq2T+IYm0CSJ/fhZNi/ZrLo2XVkts2Tp5McY+gu3PRpZy5c2K3fRJOAGt8bP4ZgD1AxB1N2GDMmRntQTfFd5IYWTzF77CDRFdG4a3OPgFySVm9105JRTdNfpu8Z/EudjT5U8y/fBn7ADCj/eewdMZ77f9vjZXFjxVgdq5ntX/QIC7iPgHB/qdJexqrsPtms5oO5iLwxemO+VB1LO4PDkDiE909ICIpBgEa+hZoIjIoFh7GLK2I+eaEaHoO7qFPfyCLohPCU8utnqFYPjb/Ke+w3olo4lABjDH/tkfD3odG+5CzPZMBID25d7BI6p069HCm15fPjdloMvcdH69vB0zhWO5MFc7tgzBAE1HshGp+7c2PWIDGSZn8BLJOLaB06h2Uf5i9uxK9N/R9D/kb7MIwyWneWeNYS3Lp1ciCCn1TkxWhwUg5gIXqibxBVZrWYddny4ZKF2M0FGu3iGis8DdEgCTmZNfygKf82CuqQ0fxVLica56k3z0SxWJLrtoivJHnSbVI6akoQrXDkDs5c8s5ta/hpSyjMbVFPl1+KQN8nWasCfEBqmq1ZNuJ8Hn0DtOncyTK8zOKL8a8xMIv6xdrqDFm8NqWgCdFnQ5q5R3rSTl1k7N24AeK8vrOetyg2g1X/fEmsrOkaKY1LfMcNw+1kDBPSa8C5TO4iZjm9Zoc8MXMDBQxOBfVvI/UECVJ6LsPTYDI7BhFA885CvyktipuVLo42zP+NroILhUs57RPOWNP7lLtjk8ubtwlS3Ajd"
        let NonceString = "1997b0211a19980131252955df21d7f3"
        //        z키 스토어 데이터 불러오기
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical_Wallet", account: "EF00C6C495EDBFF01ACCC7650A1B5128") else {
            print("Failed to load keystore")
            return
        }
        //        키스토어 데이터를 바탕으로 keystore 객채 생성
        guard let keystore = BIP32Keystore(keystoreData) else{
            print("keystore 불러오기 실패")
            return
        }
        //        키스토어 에 있는 공개 주소 가져오기
        guard let accountAddress = keystore.addresses?.first else {
            print("계정 주소 불러오기 실패")
            return
        }
        //        해독할 데이터
        guard let encryptedData = Data(base64Encoded: decodeString) else{
            print("decode base64 실패")
            return
        }
        //        iv 값
        guard let iv = NonceString.hexaBytes else {
            print("Invalid IV")
            return
        }
        do{
            //            개정 주소에 해당하는 개인키 데이터 가져오기
            let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: "asdfasdf12@@", account: accountAddress)
            //            개인키 String 값으로 변환
            let privateKeyHexString = privateKeyData.toHexString()
            //            변환된 개인키를 가지고 sha256 비밀키 생성
            let secKey = Array(privateKeyHexString.sha256().bytes.prefix(32))
            // secKey를 기반으로 SymmetricKey 생성
            let aes = try AES(key: secKey, blockMode: CBC(iv: iv), padding: .pkcs7)
            let decrypteBytes = try aes.decrypt(encryptedData.bytes)
            if let decryptString = String(data: Data(decrypteBytes), encoding: .utf8){
                print(decryptString)
            }
            //            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: encryptedData)
            
        } catch{
            print("Error \(error)")
        }
        
    }
    func ContractCreate() async{
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical", account: "test") else {
            print("Failed to load keystore")
            return
        }
        guard let providerURL = URL(string: "http://203.234.103.157:3222") else {
            print("Invalid URL or address")
            return
        }
        do {
            let keystore = BIP32Keystore(keystoreData)!
            let keystoreManager = KeystoreManager([keystore])
            let provider = try await Web3HttpProvider(url: providerURL, network: nil, keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return
            }
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "json"), let abiString = try? String(contentsOf: abiUrl) else{
                print("ABI 파일 실패")
                return
            }
            print("ABI String : \(abiString)")
            
            guard let bytecodeUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "bin"),
                  let bytecodeString = try? "0x"+String(contentsOf: bytecodeUrl) else {
                print("Bytecode 파일을 로드할 수 없습니다.")
                return
            }
            guard let bytecodeData = Data.fromHex(bytecodeString) else {
                print("바이트코드 문자열을 Data로 변환할 수 없습니다.")
                return
            }
            
            // 개인키 추출
            let privateKeyData = try keystore.UNSAFE_getPrivateKeyData(password: "strong password", account: accountAddress)
            let privateKeyHexString = privateKeyData.toHexString()
            print("Private KeyString: \(privateKeyHexString)")
            
            // 트랜잭션 옵션 생성 및 체인 ID 설정
            
            // 개인키 데이터를 사용하여 필요한 작업 수행
            // 예: 트랜잭션 서명, 메시지 서명 등
            // 여기서는 개인키의 데이터 길이만 출력합니다(보안상 실제 키 값을 출력하지 않음).
            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            let gasLimit = BigUInt(1000000) // 예: 1000000

            let gasPrice = try await web3.eth.gasPrice()
            guard gasPrice <= maxGasPrice else {
                   print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                   return
               }
            
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)
            var transaction = CodableTransaction.emptyTransaction
            transaction.nonce = currentNonce
            transaction.to = .contractDeploymentAddress()
//            transaction.data = bytecodeData + Data(["hashString"])
            transaction.chainID = BigUInt(142536)
            transaction.gasLimit = gasLimit
            transaction.gasPrice = gasPrice
            transaction.from = keystore.addresses?.first
            try transaction.sign(privateKey: privateKeyData)
            print("개인키 데이터 길이: \(privateKeyData.count) 바이트")
            guard let transactionEncode = transaction.encode() else{
                print("트렌젝션 인코딩 실패")
                return
            }
            
            let result = try await web3.eth.send(raw: transactionEncode)
            print("Transaction successful with hash: \(result.hash)")
            guard let resultData = Data.fromHex(result.hash) else { return  }
            do{
                let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData)
                print("트랜잭션 로그: \(String(describing: receipt?.logs))")
                print("트랜잭션 로그: \(String(describing: receipt?.status))")
            }catch{
                print("receipt \(error.localizedDescription)")
            }
        } catch {
            print("Transaction failed with error: \(error.localizedDescription)")
        }
    }
    func waitForTransactionReceipt(web3: Web3, transactionHash: Data) async throws -> TransactionReceipt {
        let pollingTask = TransactionPollingTask(transactionHash: transactionHash, web3Instance: web3)
        let receipt = try await pollingTask.wait()
        return receipt
    }
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
    func returnData(hexString: String) -> Data {
        // `0x` 접두사를 제거한 새로운 문자열을 생성합니다.
        let cleanHexString = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "0x"))

        let len = cleanHexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = cleanHexString.index(cleanHexString.startIndex, offsetBy: i*2)
            let k = cleanHexString.index(j, offsetBy: 2)
            let bytes = cleanHexString[j..<k]
            if let byte = UInt8(bytes, radix: 16) {
                data.append(byte)
            } else {
                // 올바르지 않은 16진수 문자열인 경우 빈 Data 객체를 반환합니다.
                return Data()
            }
        }
        return data
    }
    func ContractCreate2() async{
        guard let keystoreData = loadFromKeychain(service: "com.knp.KpMadical", account: "test") else {
            print("Failed to load keystore")
            return
        }
        guard let providerURL = URL(string: "http://203.234.103.157:3222") else {
            print("Invalid URL or address")
            return
        }
        do {
            let keystore = BIP32Keystore(keystoreData)!
            let keystoreManager = KeystoreManager([keystore])
            let provider = try await Web3HttpProvider(url: providerURL, network: nil, keystoreManager: keystoreManager)
            let web3 = Web3(provider: provider)
            guard let accountAddress = keystore.addresses?.first else {
                print("계정 주소를 찾을 수 없습니다.")
                return
            }
            guard let abiUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "json"), let abiString = try? String(contentsOf: abiUrl) else{
                print("ABI 파일 실패")
                return
            }
            print("ABI String : \(abiString)")
            
            guard let bytecodeUrl = Bundle.main.url(forResource: "PersonalRecords", withExtension: "bin"),
                  let bytecodeString = try? "0x"+String(contentsOf: bytecodeUrl) else {
                print("Bytecode 파일을 로드할 수 없습니다.")
                return
            }
            guard let bytecodeData = Data.fromHex(bytecodeString) else {
                print("바이트코드 문자열을 Data로 변환할 수 없습니다.")
                return
            }

            let maxGasPrice = BigUInt(50) * BigUInt(10).power(9) // 예: 50 Gwei
            

            let gasPrice = try await web3.eth.gasPrice()
            guard gasPrice <= maxGasPrice else {
                   print("Current gas price (\(gasPrice)) exceeds the configured max gas price (\(maxGasPrice))")
                   return
               }
            
            let currentNonce = try await web3.eth.getTransactionCount(for: accountAddress, onBlock: .latest)

            let contract = Web3.Contract(web3: web3, abiString: abiString,at: accountAddress,abiVersion: 2)
            let deployOption = contract?.prepareDeploy(bytecode: bytecodeData, constructor: contract?.contract.constructor, parameters: ["환자 RSA 공개키"])
            deployOption?.transaction.nonce = currentNonce
            print(currentNonce)
            deployOption?.transaction.chainID = BigUInt(142536)
            deployOption?.transaction.to = .contractDeploymentAddress()
            deployOption?.transaction.from = accountAddress
            if let result = try await deployOption?.writeToChain(password: "strong password", sendRaw: true){
                print("Transaction successful with hash: \(result.hash)")
                guard let resultData = Data.fromHex(result.hash) else { return  }
                do{
                    let receipt = try await getTransactionReceipt(web3: web3, transactionHash: resultData)
                    print("트랜잭션 로그: \(String(describing: receipt?.logs))")
                    print("트랜잭션 로그: \(String(describing: receipt?.contractAddress))")
                }catch{
                    print("receipt \(error.localizedDescription)")
                }
            }else{
                print("트랜잭션 실행 실패")
            }
            
        } catch {
            print("Transaction failed with error: \(error.localizedDescription)")
        }
    }

}
extension String {
    var hexaBytess: [UInt8] {
        var bytes = [UInt8]()
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            let hexStr = String(self[startIndex..<endIndex])
            if let byte = UInt8(hexStr, radix: 16) {
                bytes.append(byte)
            } else {
                return []
            }
            startIndex = endIndex
        }
        return bytes
    }
}

func decryptRecord(Symmetric_key: String, encryptedStr: String, ivString: String) -> String? {
    guard let encryptedData = Data(base64Encoded: encryptedStr),
          let keyData = Data(base64Encoded: Symmetric_key),
          keyData.count == 32 else {
        print("Invalid data or key")
        return nil
    }

    let iv = ivString.hexaBytess
    if iv.count != 16 {
        print("Invalid IV")
        return nil
    }

    do {
        let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv), padding: .pkcs7)
        let decryptedBytes = try aes.decrypt(encryptedData.bytes)
        if let decryptedString = String(data: Data(decryptedBytes), encoding: .utf8) {
            return decryptedString
        } else {
            print("Decryption failed. Cannot convert to String.")
            return nil
        }
    } catch {
        print("Error in decryption: \(error)")
        return nil
    }
}
