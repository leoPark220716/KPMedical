//
//  SecurityKey.swift
//  KPMadical
//
//  Created by Junsung Park on 4/4/24.
//

import Foundation

class AppPasswordKeyChain{
//    비밀번호 저장
    func savePassword(password: String, account: String) -> Bool{
        guard let passwordData = password.data(using: .utf8) else{
            print("passward Data 변환 실패")
            return false
        }
        let query: [String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "knp.kpmadical.com.OPTPass_\(account)",
            kSecValueData as String: passwordData
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
//    비밀번호 검증
    func verifyPassword(password: String, account: String) -> Bool{
        let query: [String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "knp.kpmadical.com.OPTPass_\(account)",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let passwordData = item as? Data, let savedPassword = String(data: passwordData, encoding: .utf8) else {
                return false
            }
        return password == savedPassword
    }
//    비밀번호 키체인 있는지 조회
    func checkPasswordExists(account: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "knp.kpmadical.com.OPTPass_\(account)",
            kSecReturnData as String: kCFBooleanFalse!, // 데이터 반환하지 않음
            kSecMatchLimit as String: kSecMatchLimitOne // 최대 하나의 결과만 매칭
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
//    JWT Account 추출
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
//    모든 키체인 데이터 삭제
    func deleteAllKeyChainItems(){
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
            for secItemClass in secItemClasses {
                let dictionary = [kSecClass as String: secItemClass]
                let status = SecItemDelete(dictionary as CFDictionary)
                
                switch status {
                case errSecSuccess:
                    print("\(secItemClass) items deleted successfully.")
                case errSecItemNotFound:
                    print("No items were found to delete for \(secItemClass).")
                default:
                    print("An error occurred while deleting items for \(secItemClass): \(status)")
                }
            }
    }
}
