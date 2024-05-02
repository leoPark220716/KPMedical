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
            EmptyView()
//            myreservationView(userInfo: authViewModel)
        case .tab:
            tabView()
        case .findHospital:
            EmptyView()
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
                
                AccountView()
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
            .navigationBarTitleDisplayMode(router.exportTapView == .home ? .inline : .large)
            .navigationDestination(for: Route.self){ route in
                switch route {
                case .item(item: let item):
                    switch item.page{
                    case 1:
                        FindHospitalView()
                    case 3:
                        ChooseDepartment()
                    case 4:
                        ChooseDorcor()
                    case 5:
                        ChooseDate()
                    case 6:
                        ChooseTime()
                    case 7:
                        symptomTextFiledView()
                    case 8:
                        reservationSuccessView()
                    case 9:
                        myreservationView()
                    default:
                        EmptyView()
                    }
                case .chat(data: let data):
                    Chat(data: data)
                case .hospital(item: let item):
                    switch item.name{
                    case "hospitalDitailView":
                        HospitalDetailView(data: item)
                    default:
                        EmptyView()
                    }
                case .reservation(item: let item):
                    ReservationDetailView(data: item)
                }
            }
            
        }
        .onAppear{
            print("📟 OnAppearTabView")
        }
    }
}
