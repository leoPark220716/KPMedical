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
                    }
                }
                HStack(alignment: .bottom,spacing: 3){
                    Text(item.messege!)
                        .font(.system(size: 17))
                        .padding(10)
                        .foregroundColor(.black)
                        .background(.white)
                        .cornerRadius(10)
                    VStack(alignment: .leading){
                        if item.showETC{
                            Text("1")
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                            Text(item.time)
                                .font(.system(size: 12))
                        }else{
                            Text("1")
                                .foregroundStyle(.red)
                                .font(.system(size: 12))
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.bottom,5)
        .padding(.leading)
        .padding(.trailing,20)
    }
}
