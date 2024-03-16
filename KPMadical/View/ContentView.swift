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

struct ContentView: View {
//    @State var currentTab : BottomTab = .home
    @State var userId: String = ""
    @State var roomNo: String = ""
    @State private var isShowSignUp = false
    @Environment(\.dismiss) private var dismiss  // 뷰를 닫기 위한 환경 변수 추가
    var body: some View {
        NavigationView{
                   VStack {
                       TextField("씨발 왜안됨?.", text: $userId)
                           .background(Color.gray)
                           .textFieldStyle(.roundedBorder)
                           .padding()
                       
                       TextField("방 번호를 입력해주세요.", text: $roomNo)
                           .background(Color.gray)
                           .textFieldStyle(.roundedBorder)
                           .padding()
                       Button("화면전환"){
                           isShowSignUp = true
                       }
                       .fullScreenCover(isPresented: $isShowSignUp){
//                           SignUp()
                       }
                       
                   }
                   .padding()
        }
//                TabView{
//                    Text("the First Tab")
//                        .tabItem {
//                            Image(systemName: "1.square.fill")
//                            Text("First")
//                        }
//                    Text("the Second Tab")
//                        .tabItem {
//                            Image(systemName: "1.square.fill")
//                            Text("First")
//                        }
//                    Text("the Therd Tab")
//                        .tabItem {
//                            Image(systemName: "1.square.fill")
//                            Text("First")
//                        }
//                    Text("the First Tab")
//                        .tabItem {
//                            Image(systemName: "1.square.fill")
//                            Text("First")
//                        }
//                }
    }
}

#Preview {
    ContentView()
}

