//
//  ChatListItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/22/24.
//

import SwiftUI

struct ChatListItem: View {
    let item: ChatHTTPresponseStruct.ChatListArray
    
    let time = TimeHandler()
    var body: some View {
        HStack{
            AsyncImage(url: URL(string: item.icon)){ image in
                image.resizable() // 이미지를 resizable로 만듭니다.
                    .aspectRatio(contentMode: .fill) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
            } placeholder: {
                ProgressView()
            }
            VStack(alignment:.leading){
                HStack{
                    Text(item.hospital_name)
                        .bold()
                        .font(.system(size: 17))
                    if item.unread_cnt != 0{
                        Text("\(item.unread_cnt)")
                            .font(.caption2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 2)
                Text(item.last_message.message)
            }
            .padding(.leading,3)
            Spacer()
            Text(time.returnyyyy_MM_dd(time: item.last_message.timestamp).chatTime)
                .font(.system(size: 13))
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ChatListItem(item:
                    ChatHTTPresponseStruct.ChatListArray(chat_id: 1, hospital_id: 1, hospital_name: "진해병원", icon: "https://picsum.photos/200/300", patient_id: "1", patient_name: "ㅁㄴㅇㄹ", room_key: "ㅁㄴㅇㄹ", last_connected_time: "123", unread_cnt: 6, last_message: ChatHTTPresponseStruct.LastMessage(timestamp: "2024-04-22T15:28:22.880", message: "ㅁㄴㅇㄹ")))
    
}
