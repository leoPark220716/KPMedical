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
    @State var chatItem: [ChatHTTPresponseStruct.ChatListArray] = []
    var body: some View {
    
        VStack{
            List(chatItem.indices, id: \.self){ index in
                ChatListItem(item: chatItem[index])
                    .onTapGesture {
                        router.routes.append(Route.chat(data: parseParam(id: chatItem[index].chat_id, name: chatItem[index].hospital_name,hospital_id: chatItem[index].hospital_id)))
                    }
            }
        }
        .onAppear{
            let chatHttpRequest = ChatHttpRequest()
            let httpStruct = http<Empty?, KPApiStructFrom<ChatHTTPresponseStruct.ChatList>>.init(method:"GET", urlParse: "v2/chat?service_id=1", token: authViewModel.token, UUID: getDeviceUUID())
            Task{
                let result = await chatHttpRequest.HttpRequest(HttpStructs: httpStruct)
                if !result.success{
                    return
                }
                chatItem = result.data?.data.chats ?? []
                print(result.data?.data.chats.first?.last_message ?? "????")
            }
        }
    }
}
