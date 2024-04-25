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
            List(authViewModel.chatItem.indices, id: \.self){ index in
                ChatListItem(item: authViewModel.chatItem[index])
                    .onTapGesture {
                        router.routes.append(Route.chat(data: parseParam(id: authViewModel.chatItem[index].chat_id, name: authViewModel.chatItem[index].hospital_name,hospital_id: authViewModel.chatItem[index].hospital_id)))
                    }
            }
        }
        .onAppear{
            let httpStruct = http<Empty?, KPApiStructFrom<ChatHTTPresponseStruct.ChatList>>.init(method:"GET", urlParse: "v2/chat?service_id=1", token: authViewModel.token, UUID: getDeviceUUID())
            Task{
                let result = await HttpRequest(HttpStructs: httpStruct)
                if !result.success{
                    return
                }
                authViewModel.chatItem = result.data?.data.chats ?? []
                print("👀  Caht List Open \(String(describing: result.data?.data.chats.first?.last_message))")
            }
        }
        .onDisappear{
            authViewModel.RemoveChatItems()
        }
    }
}
