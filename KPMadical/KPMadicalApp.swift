//
//  KPMadicalApp.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI
//import KakaoSDKCommon
//import KakaoSDKAuth

@main
struct KPMadicalApp: App {
//    init() {
//        KakaoSDK.initSDK(appKey: "dd6e3740b058d253b94f109014c713d2")
//    }
    var router = GlobalViewRouter()
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(router)
//            Chat()
//            __()
        }
    }
}
