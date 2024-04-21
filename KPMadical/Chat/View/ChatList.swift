//
//  ChatList.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import SwiftUI

struct ChatList: View {
    @EnvironmentObject var router: GlobalViewRouter
    @EnvironmentObject var authViewModel: UserInformation
    @State var ChatViewGo = false
    var body: some View {
    
        VStack{
//            NavigationLink(value: Route.item(item: ViewPathAddress(name: "chat", page: 1,id: 12))) {
//                Text("Hello, World!")
//                    .foregroundStyle(Color.black)
//            }
            NavigationLink(value: Route.chat(data: parseParam(id: "12", des: "asdf"))) {
                Text("테스트 채팅뷰 이동")
                    .foregroundStyle(Color.black)
            }
        }
        .onAppear{
                authViewModel.traceTab = "상담"
            
        }
    }
}
