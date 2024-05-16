//
//  AccountViewHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 5/2/24.
//

import Foundation

class AccountViewHandler{
    func TokenToServer(httpMethod: String, token: String,FCMToken: String) async -> Bool{
        print("👀 FCMToken server Call : \(httpMethod)")
        print("👀 FCMToken server token : \(token)")
        print("👀 FCMToken server FCMToken : \(FCMToken)")
        let BodyData = FcmToken.FcmTokenSend.init(fcm_token: FCMToken)
        let httpStruct = http<FcmToken.FcmTokenSend?, KPApiStructFrom<FcmToken.FcmTokenResponse>>.init(
            method: httpMethod,
            urlParse: "v2/fcm",
            token: token ,
            UUID: getDeviceUUID(),
            requestVal: BodyData
        )
        let result = await KPWalletApi(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            return true
        }else{
            print(result.data?.message ?? "Option Null")
            return false
        }
    }
}
