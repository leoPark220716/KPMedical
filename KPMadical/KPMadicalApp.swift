//
//  KPMadicalApp.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//
import UIKit
import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject{
    var app: KPMadicalApp?
    let gcmMessageIDKey = "gcm.message_id"
    
    // 앱이 켜졌을 때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // Setting Up Notifications...
        // 원격 알림 등록
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOption,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        
        // Setting Up Cloud Messaging...
        // 메세징 델리겟
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate{
    private func extractName(from userInfo: [AnyHashable: Any]) -> String {
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let title = alert["title"] as? String {
            return title
        } else {
            return "Failed to extract title."
        }
    }
    private func extractMessage(from userInfo: [AnyHashable: Any]) -> String {
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? [String: Any],
           let body = alert["body"] as? String {
            return body
        } else {
            return "Failed to extract title."
        }
    }
    private func extractId(from userInfo: [AnyHashable: Any]) -> String {
        if let chat = userInfo["chat"] as? [String: Any] {
            return extractFromField(from: chat)
        } else if let chatString = userInfo["chat"] as? String,
                  let chatData = chatString.data(using: .utf8) {
            return decodeChatData(chatData)
        } else {
            print("Chat data is not in the expected format or missing.")
            return ""
        }
    }
    private func extractFromField(from chat: [String: Any]) -> String {
        if let from = chat["from"] as? String {
            return from
        } else {
            return ""
        }
    }
    
    private func decodeChatData(_ data: Data) -> String {
        do {
            if let chatDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return extractFromField(from: chatDict)
            } else {
                print("Failed to decode chat JSON.")
                return ""
            }
        } catch {
            print("Error decoding chat JSON: \(error)")
            return ""
        }
    }
    private func extractTimestamp(from userInfo: [AnyHashable: Any]) -> String {
        if let chat = userInfo["chat"] as? [String: Any],
           let timestamp = chat["timestamp"] as? String {
            return timestamp
        } else if let chatString = userInfo["chat"] as? String,
                  let chatData = chatString.data(using: .utf8) {
            return decodeTimestamp(chatData)
        } else {
            return "Timestamp not available."
        }
    }

    private func decodeTimestamp(_ data: Data) -> String {
        do {
            if let chatDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let timestamp = chatDict["timestamp"] as? String {
                return timestamp
            } else {
                return "Failed to decode timestamp."
            }
        } catch {
            return "Error decoding chat JSON for timestamp: \(error)"
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        //        노티피케이션이 탭됐을 때 오는 댈리게이트
        let userInfo = response.notification.request.content.userInfo
        let name = extractName(from: userInfo)
        let id = extractId(from: userInfo)
        // Handle or display the results as needed
        print(name)
        print(id)
        let stringURL = "KpMedicalApp://chat?id=0&name=\(name)&hos_id=\(id)"
        let url = URL(string: stringURL)
        app?.handleDeeplink(from: url!)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        print("call in UNUserNotificationCenter : \(userInfo)")
        let id = extractId(from: userInfo)
        let msg = extractMessage(from: userInfo)
        let timeStemp = extractTimestamp(from: userInfo)
        print("👀 TimeStemp \(timeStemp)")
        app?.authViewModel.UpdateChatItem(hospitalId: id, msg: msg,timestemp: timeStemp)
        return [.sound,.badge,.banner,.list]
    }
}
extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("토큰을 받았다")
        // Store this token to firebase and retrieve when to send message to someone...
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        if let token = dataDict["token"] {
            print("토큰 :  \(token)")
            app?.SetFCMToken(fcmtoken: token)
        } else {
            print("Token not found")
        }
        print("토근값 : \(dataDict)")
    }
}
@main
struct KPMadicalApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var authViewModel = UserInformation()
    @StateObject var router = GlobalViewRouter()
    let UserData = LocalDataBase.shared
    let AutoLogin = LoginTockenFunc()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(router)
                .environmentObject(authViewModel)
                .onOpenURL(perform: { url in
                    print("onOpenURL")
                    print(url)
                    authViewModel.isActivatedByURL = true
                    Task {
                        let autoLoginCheck = await CheckLogin(url: url,call: "onOpenURL")
                         print(autoLoginCheck)
                        if autoLoginCheck {
                            authViewModel.TokenToServer(httpMethod: "PATCH")
                        }
                    }
                })
                .onAppear{
                    appDelegate.app = self
                    print("onAppear")
                    if !authViewModel.isActivatedByURL{
                        Task {
                            let autoLoginCheck = await CheckLogin(call: "onAppear")
                            print(autoLoginCheck)
                            if autoLoginCheck {
                                authViewModel.TokenToServer(httpMethod: "PATCH")
                            }
                        }
                    }
                }
        }
    }
    private func CheckLogin(url: URL? = nil,call: String) async -> Bool {
        print(call)
        UserData.createTable()
        let checkNilUserDb = UserData.readUserDb(userState: authViewModel)
        if !checkNilUserDb{
            //   초기화
            authViewModel.SetData(name: "", dob: "", sex: "", token: "")
            //  DB 에 저장된 정보 정보 전부 삭제
            UserData.removeAllUserDB()
            print("SetData LoginView")
            router.push(baseView: .Login)
            return false
        }
        let tokenResult = await AutoLogin.checkToken(token: authViewModel.token, uid: getDeviceUUID())
        print(tokenResult.success)
        if !tokenResult.success{
            //   초기화
            authViewModel.SetData(name: "", dob: "", sex: "", token: "")
            //  DB 에 저장된 정보 정보 전부 삭제
            UserData.removeAllUserDB()
            print("checkToken LoginView")
            router.push(baseView: .Login)
            return false
        }
        if tokenResult.tokenUpdate{
            authViewModel.token = tokenResult.newToken
            print(tokenResult.newToken)
            print("Call tokenUpdate")
        }
        if url != nil{
            print("URL is not nil")
            handleDeeplink(from: url!)
            return true
        }
        print("👀 App 초기화 과정 끝남")
        router.push(baseView: .tab)
        return true
//        이부분에서 패치 시도
        
    }
}
extension KPMadicalApp{
    func handleDeeplink(from url: URL) {
        let routerFinder = RouteFinder()
        let route = routerFinder.find(from: url)
        guard route.route != nil else{
            return
        }
        if route.page == "chat"{
            router.exportTapView = .chat
        }
        router.push(baseView: .tab,to:route.route)
    }
    func SetFCMToken(fcmtoken : String){
//        authViewModel.FCMToken = fcmtoken
        authViewModel.SetFCMToken(fcmToken: fcmtoken)
    }
    func TokenToServer(fcmToken: String,httpMethod: String){
        let BodyData = FcmToken.FcmTokenSend.init(fcm_token: fcmToken)
        let httpStruct = http<FcmToken.FcmTokenSend?, KPApiStructFrom<FcmToken.FcmTokenResponse>>.init(
            method: httpMethod,
            urlParse: "v2/fcm",
            token: authViewModel.token,
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
