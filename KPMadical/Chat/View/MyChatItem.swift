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
    @Binding var img: String
    @Binding var isOPT: Bool
    let HospitalName: String
    var index: Int
    var body: some View {
        switch item.amI{
        case .user:
            MyChatItem(item: $item, stringUrls: item.ImageArray ?? [],HospitalName: HospitalName)
        case .other:
            OthersChatItem(item: $item,items: $items, image: $img,index: index, stringUrls: item.ImageArray ?? [],HospitalName: HospitalName,isOPT: $isOPT)
        case .sepDate:
            ChatdateView(time: item.chatDate)
        }
    }
}
struct MyChatItem: View {
    @Binding var item: ChatMessegeItem
    @State var imageUrls: [URL] = []
    var stringUrls: [String]
    let HospitalName: String
    var body: some View {
        HStack(alignment: .bottom,spacing: 3){
            Spacer()
            VStack(alignment: .trailing){
                if item.progress && item.type != .photo{
                    ProgressView()
                }else{
                    if !item.progress {
                        if !item.ReadCount{
                            Text("1")
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                        }else{
                            Text("")
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                        }
                        if item.showETC{
                            Text(item.time)
                                .font(.system(size: 12))
                        }else{
                            Text("")
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            switch item.type{
            case .text:
                Text(item.messege!)
                    .font(.system(size: 14))
                    .padding(10)
                    .foregroundColor(.black)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(10)
            case .photo:
                if item.progress{
                    ImageProgressView()
                }else{
                    DynamicImageView(images: imageUrls,totalWidth: 270, imageHeight: 90, oneItem: 270)
                        .cornerRadius(10)
                }
            case .file:
                if !stringUrls.isEmpty{
                    FileChatView(urlString: stringUrls[0])
                }
            case .notice:
                ConfirmChatView(message: item.messege!, hospitalName: HospitalName, hash: item.hash!)
                    .cornerRadius(10)
            case .unowned:
                EmptyView()
            case .share:
                EmptyView()
            case .edit:
                EmptyView()
            }
        }
        .padding(.trailing)
        .padding(.leading,20)
        .padding(.bottom,3)
        .onAppear{
            if !stringUrls.isEmpty {
                imageUrls = stringUrls.compactMap { urlString in
                    urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap { URL(string: $0) }
                }
            }
        }
        .onChange(of:item.progress){
            if !stringUrls.isEmpty {
                imageUrls = stringUrls.compactMap { urlString in
                    urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap { URL(string: $0) }
                }
            }
        }
        .onTapGesture {
            if !stringUrls.isEmpty{
                print("URL 값 확인 : \(stringUrls[0])")
            }
        }
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


