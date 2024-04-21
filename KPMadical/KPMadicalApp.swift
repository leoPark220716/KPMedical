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
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
}
extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        //        노티피케이션이 탭됐을 때 오는 댈리게이트
        if let deepLink = response.notification.request.content.userInfo["link"] as? String{
            print("✅ recive deep link\(deepLink)")
        }
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
                        await  CheckLogin(url: url,call: "onOpenURL")
                    }
                })
                .onAppear{
                    print("onAppear")
                    if !authViewModel.isActivatedByURL{
                        Task {
                            await CheckLogin(call: "onAppear")
                        }
                    }
                }
        }
    }
    private func CheckLogin(url: URL? = nil,call: String) async {
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
            return
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
            return
        }
        if url != nil{
            print("URL is not nil")
            handleDeeplink(from: url!)
            return
        }else{
            router.currentView = .Splash
        }
        if tokenResult.tokenUpdate{
            authViewModel.token = tokenResult.newToken
            print("Call tokenUpdate")
            router.push(baseView: .tab)
            return
        }else{
            router.push(baseView: .tab)
        }
        
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
}
//class AppDelegate: NSObject, UIApplicationDelegate{
//    var window: UIWindow?
//    var notificationData = NotificationData()
//    let gcmMessageIDKey = "gcm.message_id"
//
//    // 앱이 켜졌을 때
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//
//        // 파이어베이스 설정
//        FirebaseApp.configure()
//
//        // Setting Up Notifications...
//        // 원격 알림 등록
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOption: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOption,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
//
//
//        // Setting Up Cloud Messaging...
//        // 메세징 델리겟
//        Messaging.messaging().delegate = self
//
//        UNUserNotificationCenter.current().delegate = self
//        return true
//    }
//    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
//            if let windowScene = scene as? UIWindowScene {
//                let window = UIWindow(windowScene: windowScene)
//                let contentView = ChatTEst().environmentObject(notificationData)
//                window.rootViewController = UIHostingController(rootView: contentView)
//                self.window = window
//                window.makeKeyAndVisible()
//            }
//
//            // Handle notification tap
//            if let response = connectionOptions.notificationResponse {
//                handleNotification(response: response)
//            }
//        }
//    func handleNotification(response: UNNotificationResponse) {
//            let userInfo = response.notification.request.content.userInfo
//            if let message = userInfo["test_content"] as? String {
//                DispatchQueue.main.async {
//                    self.notificationData.message = message
//                }
//            }
//        }
//
//    // fcm 토큰이 등록 되었을 때
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
//    }
//    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//        print("Failed to register for remote notifications: \(error)")
//    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        print("userInfo : String : \(userInfo)")
//    }
//
//}
//
//// Cloud Messaging...
//extension AppDelegate: MessagingDelegate{
//
//    // fcm 등록 토큰을 받았을 때
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("토큰을 받았다")
//        // Store this token to firebase and retrieve when to send message to someone...
//        let dataDict: [String: String] = ["token": fcmToken ?? ""]
//
//        // Store token in Firestore For Sending Notifications From Server in Future...
//
//        print(dataDict)
//    }
//}
//
//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfo = notification.request.content.userInfo
//        print("@escapinguserNotificationCenter :  \(userInfo)")
//        // Firebase 메시징 애널리틱스에 메시지 수신 정보 전달
//        Messaging.messaging().appDidReceiveMessage(userInfo)
//            // 기본 알림을 표시할 옵션 지정
////        if let title = userInfo["test_titile"] as? String, let body = userInfo["test_content"] as? String {
////               print("title \(title)")
////               print("test_content \(body)")
////               displayCustomNotification(title: title, body: body)
////               // 커스텀 알림을 처리하므로 기본 알림 표시하지 않음
////               completionHandler([])
////           } else {
//               // 기본 알림을 표시할 옵션 지정
//               completionHandler([.banner, .sound])
////           }
//
//        // 표시할 알림 유형 선택
//    }
//    func displayCustomNotification(title: String, body: String) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = .default
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content,trigger: nil)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            }
//        }
//    }
//
////    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
////        let userInfo = response.notification.request.content.userInfo
////        if let message = userInfo["test_content"] as? String {
////
////        }
////        NotificationCenter.default.post(name: Notification.Name("TestContentReceived"), object: nil, userInfo: userInfo)
////        completionHandler()
////    }
//
//
//    //    func userNotificationCenter(_ center: UNUserNotificationCenter,
//    //                                didReceive response: UNNotificationResponse,
//    //                                withCompletionHandler completionHandler: @escaping () -> Void) {
//    //      let userInfo = response.notification.request.content.userInfo
//    //        let title = userInfo["test_titile"] as! String
//    //        let body = userInfo["test_content"] as! String
//    //    }
//}
//class NotificationData: ObservableObject {
//    @Published var message: String = "Default Message"
//}
