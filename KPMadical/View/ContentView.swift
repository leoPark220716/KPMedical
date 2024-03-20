//
//  ContentView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI

//enum BottomTab {
//    case home,chat,hospital,account
//}
enum BottomTab{
    case home,chat,hospital, account
}
struct ContentView: View {
    @ObservedObject var authViewModel: UserObservaleObject
    @StateObject private var countModel = CountModel(sentCount: 0)
    @StateObject private var loginManager = LoginManager(LoginStatus: false)
    @State private var tabState: BottomTab = .home
//    @Environment(\.dismiss) private var dismiss  // 뷰를 닫기 위한 환경 변수 추가
    var body: some View {
//        그냥 테스트 해보기
        NavigationStack{
            ZStack{
                Color.white.edgesIgnoringSafeArea(.all)
                TabView {
                    HomeView(authViewModel: authViewModel, logined: loginManager.LoginStatus)
                        .tabItem {
                            Label("홈", systemImage: "house")
                        }
                    Chat()
                        .badge(countModel.sentCount)
                        .tabItem {
                            Label("상담", systemImage: "message")
                        }
                    Hospital(Count: countModel)
                        .tabItem {
                            Label("내병원", systemImage: "stethoscope")
                        }
                    AccountView(authViewModel: authViewModel)
                        .tabItem {
                            Label("내정보", systemImage: "person.crop.circle")
                        }
                    
                }
            }
            .navigationTitle("\(authViewModel.name)님 안녕하세요!") // 이 부분을 ScrollView 밖으로 이동
            .navigationBarTitleDisplayMode(.inline) // 필요한 경우 타이틀 표시 모드를 조정
        }
    }
}
//#Preview {
//    ContentView()
//}

