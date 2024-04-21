//
//  MainView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/20/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @ObservedObject private var sign = singupOb()
    @State private var path = NavigationPath()
    var body: some View {
        switch router.currentView {
        case .MyReservation:
            myreservationView(userInfo: authViewModel)
        case .tab:
            tabView()
        case .findHospital:
            FindHospitalView()
        case .myWallet:
            KNPWalletView(userInfo:authViewModel)
        case .chat:
            EmptyView()
//            Chat(chatId:14)
        case .Login:
            LoginView(sign: sign)
        case .Splash:
            Splash()
        }
        
    }
    
}


struct tabView: View {
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @StateObject private var loginManager = LoginManager(LoginStatus: false)
    @State private var title: String = ""
    var body: some View {
        NavigationStack(path: $router.routes){
            TabView (selection: $router.exportTapView){
                HomeView(logined: loginManager.LoginStatus)
                    .onAppear{
                        print(router.routes.count)
                    }
                // 이 부분을 ScrollView 밖으로 이동
                // 필요한 경우 타이틀 표시 모드를 조정
                    .tabItem {
                        Label("홈", systemImage: "house")
                    }
                    .tag(BottomTab .home)
                ChatList()
                    .tabItem {
                        Label("상담", systemImage: "message")
                    }
                    .tag(BottomTab .chat)
                
                //                    Hospital(Count: countModel)
                NavigationStack{
                    FindHospitalView()
                }
                .tabItem {
                    Label("내병원", systemImage: "stethoscope")
                }
                .tag(BottomTab .hospital)
                AccountView()
                    .tabItem {
                        Label("내정보", systemImage: "person.crop.circle")
                    }
                    .tag(BottomTab .account)
                
            }
            .navigationTitle(router.TitleString(Tabs: router.exportTapView, name: authViewModel.name))
            .navigationBarTitleDisplayMode(router.exportTapView == .home ? .inline : .automatic)
            .navigationDestination(for: Route.self){ route in
                switch route {
                case .item(let item):
                    EmptyView()
                case .chat(data: let data):
                    Chat(data: data)
                }
            }
        }
    }
}
