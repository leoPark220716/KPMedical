//
//  TabViewManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import Foundation

enum ViewTypes{
    case findHospital, tab, MyReservation, myWallet, chat, Login, Splash
}
enum BottomTab{
    case home,chat,hospital, account
}
// 전역 상태를 관리하는 클래스 정의
class GlobalViewRouter: ObservableObject {
    @Published var currentView: ViewTypes = .tab
    @Published var exportTapView: BottomTab = .home
    @Published var userId: String = ""
    @Published var routes = [Route]()
    @Published var toast = false
    func push(baseView:ViewTypes ,to screen: Route? = nil){
        print("Call push")
        if screen != nil{
            guard !routes.contains(screen!) else {
                currentView = baseView
            return
            }
            print("screen nil")
            print(screen!)
            currentView = baseView
            routes.append(screen!)
            print(currentView)
        }else{
            print("screen !nil")
            currentView = baseView
        }
        print("pushFinish")
    }
    func goBack(){
        _ = routes.popLast()
    }
    func reset(){
        routes = []
    }
    func TitleString(Tabs: BottomTab,name: String) -> String{
        switch Tabs{
        case .home:
            return "안녕하세요 \(name)님!"
        case .chat:
            return "상담내역"
        case .hospital:
            return "내 병원"
        case .account:
            return "내 계정"
        }
    }
}
