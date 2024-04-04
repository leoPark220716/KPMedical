//
//  KeyChain.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import Foundation
import web3swift
import Web3Core
import BigInt

class KeystoreKeyChain {
//    키체인 keystore 저장
    func saveToKeyChain(keystoreData: Data, service: String, account: String) ->OSStatus {
        let query: [String:Any] = [
            //            저장하는 아이템 타입 정의
            kSecClass as String: kSecClassGenericPassword,
            //            서비스 식별 문자열 정의
            kSecAttrService as String: service,
            //            계정 식별 문자열 정의
            kSecAttrAccount as String: account,
            //            실제 저장하는 데이터 정의
            kSecValueData as String: keystoreData
        ]
        //        동일한 서비스와 계정에 대한 아이템 제거 중복저장 방지.
        SecItemDelete(query as CFDictionary)
        //        새로운 Keychain 추가.
        return SecItemAdd(query as CFDictionary, nil)
    }
//    키체인에 저장된 keystore 가져오기
    func loadFromKeychain(service: String, account: String) ->Data?{
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
        //        쿼리에 해당하는 아이템 검색, 검색에 성공하면 item 변수에 저장되고 errSecSuccess 반환.
        let status = SecItemCopyMatching(query as CFDictionary,&item)
        guard status == errSecSuccess else{
            print("오브젝트 생성 실패")
            return nil
        }
        return item as? Data
    }
}