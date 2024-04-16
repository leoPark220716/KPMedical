//
//  MyChaiItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/7/24.
//

import SwiftUI

struct ChatItemView: View {
    @Binding var item: ChatMessegeItem
    @Binding var items: [ChatMessegeItem]
    var index: Int
    var body: some View {
        switch item.amI{
        case .user:
            MyChatItem(item: $item)
        case .other:
            OthersChatItem(item: $item,items: $items,index: index)
        case .sepDate:
            ChatdateView(time: item.chatDate)
        }
    }
}
struct MyChatItem: View {
    @Binding var item: ChatMessegeItem
    var body: some View {
        HStack(alignment: .bottom,spacing: 3){
            Spacer()
            VStack(alignment: .trailing){
                Text("1")
                    .foregroundStyle(.red)
                    .font(.system(size: 12))
                if item.showETC{
                    Text(item.time)
                        .font(.system(size: 12))
                }
            }
            Text(item.messege!)
                .font(.system(size: 17))
                .padding(10)
                .foregroundColor(.black)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.trailing)
        .padding(.leading,20)
    }
}



struct ChatdateView: View {
    var time: String
    var body: some View {
        Text(time)
            .foregroundStyle(Color.white)
            .font(.system(size: 13))
            .padding(10)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(10)
            .padding()
    }
}


