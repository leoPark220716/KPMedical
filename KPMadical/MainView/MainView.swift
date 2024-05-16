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
        
//            myreservationView(userInfo: authViewModel)
        case .tab:
            tabView()
        case .myWallet:
            KNPWalletView(userInfo:authViewModel)
        case .Login:
            LoginView(sign: sign)
        case .Splash:
            Splash()
        case .findPassword:
            PasswordFind()
        }
    }
}
struct tabView: View {
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @StateObject private var loginManager = LoginManager(LoginStatus: false)
    @State private var title: String = ""
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    var body: some View {
        NavigationStack(path: $router.routes){
            TabView (selection: $router.exportTapView){
                HomeView(logined: loginManager.LoginStatus)
                    .tabItem {
                        Label("홈", systemImage: "house")
                    }
                    .tag(BottomTab .home)
                ChatList()
                    .tabItem {
                        Label("상담", systemImage: "message")
                    }
                    .tag(BottomTab .chat)
                myHospital()
                .tabItem {
                    Label("내병원", systemImage: "stethoscope")
                }
                .tag(BottomTab .hospital)
                newAccountView()
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
                    case 10:
                        UserInfoView()
                    case 11:
                        accountDeep(data: item)
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
                case .pass(item: let item):
                    switch item.page{
                    case 1:
                        currentPass()
                    case 2:
                        newPassword(data: item)
                    case 3:
                        NewPhoneNumberView()
                    case 4:
                        MobileOPT(data: item)
                    default:
                        EmptyView()
                    }
                }
            }
            
        }
        .onAppear{
            print("📟 OnAppearTabView")
        }
    }
}
