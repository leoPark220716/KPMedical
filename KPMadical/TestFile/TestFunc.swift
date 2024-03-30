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

class RSATest{
    let baseKey = "MIICXgIBAAKBgQCkYaHh2oi5lFWEncs1Gjqxh44zpVwvfmZWQSIqwSN9IiXY/MsWNqjsaPA7dApNKPN8XANvBRhXY1sr6IasOqyp3UUy7hDTvSDeUwimTS5D0xEG0oHORJYT7GrWioo7gP5TGDXzg9QuiNEDt/DN0w3QUfk8wdFGd79uRufFMQ2KewIDAQABAoGBAKJwpKNm7HPPhM7fi973A4dJ+JlK0JVSaFjWVqg/Yg2XQCV0clCKRVYRwUxPOJrVW//Jgc8lDs/UrFTwnJz4AoTjFj0WiS1gRMgDgWRbChOHClbGgCvUvIVkmglH5lm8OmgkCVXJUkqmj49zOAYmwKte937YX316eyjHUU1b8jXBAkEA8Sic+g+O3zNV44iBRlBL7Y8aIvJS19Qw9NmtxUY6jjBEMsGdqKKIf8sHdOfxFRNy+a8niD7qffLyaSWoP1WYGwJBAK5/ajIagy2iDDkmoN5hSNfPs7i3LfXxxnBNSvaTQ6Scz9OR2ywW1hpP+q14x0553DKwrzizZN+yBreLpc67vSECQQCKaNLfuno3pJERDFGV95P8fntzvzzI3uJSRXU0mkAVR6J8tx8zoEVTg0V+VXjKreT5ZQv9aI7RRtTWgGR2JTwtAkEAnTZUUiHKz8EwrAjeZJxXiYAq1p/Ku8wBUcqBYFfbWKKjJ2VAhp9odDpcig/H2S83MUA4DaiqmFOHc7RQRUqloQJAU1hpHPBobdwEBP/Yol1l7G/e94guPbidUfJQIHg0prtzpMZQ6Eh00ojKLEnWXhlV6SMeTV92FqZSwDUeBABiOw=="
    let publicKeyBase64 = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCyfpz1n52R3EOO4qdvzBSDOP98oyAnWJWbvtD9U+LYHbVWg03hDrhBVr0p3cvasBCfFjv6jJ7jdN5Hkptj5Qf76g9BQH72Hodevc5zEi379h9ZTmP0oTtLxw9U13MyPCPwFSC0kyeWrqZc0KSmbLbDxe/7tYv+AbqdpL2pvTDQ/wIDAQAB"
    
    
    
    let message = "IYsWjpiQFw/JXRhDAX5vcMr6DHbWdwr2yRQohR7mORyZuKN5vke4IhVgOQfKrz9Hl6ejSUCgABN71lhkUo52SHxFNp1KIUqYhvJeEQl+ubw2RN5NgeGfe4LREnHvpx6fOzuWyomf+EuwL8zHD/bDv8BpN/J9ofJL0HFzcTFISoc="
    
    
    var pem = "-----BEGIN RSA PUBLIC KEY-----\nMIIBCgKCAQEAs6AofVx+UAXcVjnIU0Z5SAGO/LPlTunA9zi7jNDcIrZTR8ULHTrm\naSAg/ycNR1/wUeac617RrFeQuoPSWjhZPRJrMa3faVMCqTgV2AmaPgKnPWBrY2ir\nGhnCnIAvD3sitCEKultjCstrTA71Jo/BuVaj6BVgaA/Qn3U9mQ+4JiEFiTxy4kOF\nes1/WwTLjRQYVf42oG350bTKw9F0MklTTZdiZKCQtc3op86A7VscFhwusY0CaZfB\nlRDnTgTMoUhZJpKSLZae93NVFSJY1sUANPZg8TzujqhRKt0g5HR/Ud61icvBbcx8\n+a3NzmuwPylvp5m6hz/l14Y7UZ8UT5deywIDAQAB\n-----END RSA PUBLIC KEY-----\n"

    

    // Construct DER data from the remaining PEM data
    
    
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
}

class TestClass {
    func CreateWallet(){
        do{
            let keystore = try EthereumKeystoreV3.init(password: "adsf")
        } catch{
            print(error.localizedDescription)
        }
        let mnemonic = try! BIP39.generateMnemonics(bitsOfEntropy: 256)!
        let keystore = try! BIP32Keystore(mnemonics: mnemonic, password: "asdf", mnemonicsPassword: "asdf")
    }
}
