//
//  othersChatItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/7/24.
//

import SwiftUI

struct OthersChatItem: View {
    @Binding var item: ChatMessegeItem
    @Binding var items: [ChatMessegeItem]
    @Binding var image: String
    var index: Int
    @State var imageUrls: [URL] = []
    var stringUrls: [String]
    @EnvironmentObject var router: GlobalViewRouter
    let HospitalName: String
    @Binding var isOPT: Bool
    var body: some View {
        HStack(alignment: .top,spacing: 3){
            if index < items.count - 1 && items[index+1].amI != .other{
                AsyncImage(url: URL(string: image)){ image in
                    image.resizable() // 이미지를 resizable로 만듭니다.
                        .aspectRatio(contentMode: .fill) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
                } placeholder: {
                    ProgressView()
                }
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                .shadow(
                    radius: 10,
                    x: 5, y:5
                )
            }else{
                Text("")
                    .frame(width: 40)
            }
            VStack(alignment: .leading,spacing: 3){
                HStack{
                    if index < items.count - 1 && items[index+1].amI != .other{
                        Text(HospitalName)
                            .font(.system(size: 12))
                    }
                }
                HStack(alignment: .bottom,spacing: 3){
                    switch item.type{
                    case .text:
                        Text(item.messege!)
                            .font(.system(size: 14))
                            .padding(10)
                            .foregroundColor(.black)
                            .background(.white)
                            .cornerRadius(10)
                    case .photo:
                        DynamicImageView(images: imageUrls,totalWidth: 210, imageHeight: 70, oneItem: 210)
                            .cornerRadius(10)
                    case .file:
                        if !stringUrls.isEmpty{
                            FileChatView(urlString: stringUrls[0])
                        }
                    case .notice:
                        if item.noticeMsgNine{
                            ConfirmChatView(message: item.messege!, hospitalName: HospitalName, hash: item.hash!)
                                .cornerRadius(10)
                        }else{
                            if item.unixTime != 0 {
                                RequestConfirmChatView(message: item.messege!, hospitalName: HospitalName)
                                    .cornerRadius(10)
                            }else{
                                NotiveChatView(message: item.messege!)
                                    .cornerRadius(10)
                            }
                        }
                            
                    case .unowned:
                        EmptyView()
                    case .share:
                        RequestConfirmChatView(message: item.messege!, hospitalName: HospitalName)
                            .cornerRadius(10)
                    case .edit:
                        RequestConfirmChatView(message: item.messege!, hospitalName: HospitalName)
                            .cornerRadius(10)
                    }
                    VStack(alignment: .leading){
                        if item.showETC{
                            Text(item.time)
                                .font(.system(size: 12))
                        }
                    }
                }
                .padding(.top,3)
            }
            .padding(.leading,3)
            Spacer()
        }
        .padding(.top, index < items.count - 1 && items[index + 1].amI == .other ? 0 : 10)
        .padding(.bottom, index > 0 && items[index - 1].amI == .user ? 20 : 0)

        .padding(.leading)
        .padding(.trailing,20)
        .onAppear{
            if !stringUrls.isEmpty {
                imageUrls = stringUrls.compactMap { urlString in
                    urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap { URL(string: $0) }
                }
            }
        }
        .onTapGesture {
            if item.type == .notice && item.unixTime != 0 {
                router.TransactionManagerInit(unixTime: item.unixTime,type: item.type)
                isOPT.toggle()
            }else if item.type == .share{
                router.TransactionManagerInit(unixTime: item.unixTime,type: item.type)
                router.transactionManager?.shareSetting(departCode: item.departmentCode!, pubkey: item.pubKey!)
                isOPT.toggle()
                
            }else if item.type == .edit {
                router.TransactionManagerInit(unixTime: item.unixTime,type: item.type)
                router.transactionManager?.EditSetting(index: item.index!, hash: item.hash!)
                isOPT.toggle()
            }
            
        }
    }
}
