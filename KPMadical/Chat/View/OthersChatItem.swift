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
    @State private var url1 = "https://picsum.photos/200/300"
    var index: Int
    @State var imageUrls: [URL] = []
    var stringUrls: [String]
    var body: some View {
        HStack(alignment: .top,spacing: 3){
            if items[index-1].amI != .other{
                AsyncImage(url: URL(string: url1)){ image in
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
                    if items[index-1].amI != .other{
                        Text(item.HospitalName!)
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
                        DynamicImageViewManual3(images: imageUrls,totalWidth: 210, imageHeight: 70, oneItem: 210)
                            .cornerRadius(10)
                    case .file:
                        EmptyView()
                    case .notice:
                        NotiveChatView(message: item.messege!)
                            .cornerRadius(10)
                    case .unowned:
                        EmptyView()
                    }
                    VStack(alignment: .leading){
                        if item.showETC{
                            Text(item.time)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            .padding(.leading,3)
            Spacer()
        }
        .padding(.bottom,5)
        .padding(.leading)
        .padding(.trailing,20)
        .onAppear{
            if !stringUrls.isEmpty{
                for _ in 0 ..< stringUrls.count{
                    imageUrls = stringUrls.compactMap { URL(string: $0) }
                }
            }
        }
    }
}
