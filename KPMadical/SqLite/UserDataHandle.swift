//
//  UserDataHandle.swift
//  KPMadical
//
//  Created by Junsung Park on 3/18/24.
//

import Foundation
import UIKit
public class UserInformation: ObservableObject {
    @Published var name: String = ""
    @Published var dob: String = ""
    @Published var sex: String = ""
    @Published var token: String = ""
    @Published var isLoggedIn = false
    @Published var traceTab: String = ""
    @Published var isActivatedByURL = false
    @Published var FCMToken = ""
    @Published var chatItem: [ChatHTTPresponseStruct.ChatListArray] = []
    var getRecode: ReacoderModel?
    var hasHandlerURL = false
    func SetData(name: String, dob: String, sex: String, token: String) {
            self.name = name
            self.dob = dob
            self.sex = sex
            self.token = token
    }
    func initData(){
        name = ""
        dob = ""
        sex = ""
        token = ""
        isLoggedIn = false
        traceTab = ""
        isActivatedByURL = false
        FCMToken = ""
        chatItem = []
    }
    func SetLoggedIn(logged: Bool) {
        DispatchQueue.main.async {
            self.isLoggedIn = logged
        }
    }
    func ReturnLogin() -> Bool{
        if token == ""{
            return false
        }else{
            return true
        }
    }
    func SetFCMToken(fcmToken: String){
        DispatchQueue.main.async{
            self.FCMToken = fcmToken
            print("✅ fcmToken \(self.FCMToken)")
            print("✅ token \(self.token)")
            
            if self.token != "" {
                self.TokenToServer(httpMethod: "POST")
                self.TokenToServer(httpMethod: "PATCH")
            }
        }
    }
    func SetChatItem(chatItems: [ChatHTTPresponseStruct.ChatListArray]){
        DispatchQueue.main.async {
            self.chatItem = chatItems
        }
    }
    func UpdateChatItem(hospitalId: String, msg: String,timestemp: String){
        for index in chatItem.indices{
            if chatItem[index].hospital_id == Int(hospitalId){
                var updatedItem = chatItem[index]
                // 요소의 필드를 업데이트
                updatedItem.unread_cnt += 1
                updatedItem.last_message.message = msg
                updatedItem.last_message.timestamp = timestemp
                // 배열에 업데이트된 요소를 다시 할당
                DispatchQueue.main.async {
                    self.chatItem[index] = updatedItem
                }
                break
            }
        }
    }
    func RemoveChatItems(){
        self.chatItem = []
    }
    func TokenToServer(httpMethod: String){
        print("👀 FCMToken server Call : \(httpMethod)")
        print("👀 FCMToken server token : \(token)")
        print("👀 FCMToken server FCMToken : \(FCMToken)")
        print("👀 FCMToken server UUID : \(getDeviceUUID())")
        if FCMToken != ""{
            let BodyData = FcmToken.FcmTokenSend.init(fcm_token: FCMToken)
            let httpStruct = http<FcmToken.FcmTokenSend?, KPApiStructFrom<FcmToken.FcmTokenResponse>>.init(
                method: httpMethod,
                urlParse: "v2/fcm",
                token: token ,
                UUID: getDeviceUUID(),
                requestVal: BodyData
            )
            Task{
             let result = await KPWalletApi(HttpStructs: httpStruct)
                if result.success{
                    print(result.data?.message ?? "Option Null")
                }else{
                    print(result.data?.message ?? "Option Null")
                }
            }
        }
    }
    
    func CheckRecodeDatas() async -> (success: Bool, item: ReacoderModel.DoctorRecord?){
        getRecode = ReacoderModel()
        let item = await getRecode!.LastRecodeData(token: token)
        getRecode = nil
        return item
//        return (false,nil)
    }
}
class singupOb: ObservableObject {
    @Published var birthday = ""
    @Published var sex = ""
    @Published var message = ""
    @Published var phoneNumber = ""
    @Published var name = ""
    @Published var id = ""
    @Published var password = ""
    @Published var smsCheck = false
    @Published var Checkpassword = ""
    deinit{
        
    }
}
// 디바이스 고유 넘버
func getDeviceUUID() -> String {
    return UIDevice.current.identifierForVendor!.uuidString
}
