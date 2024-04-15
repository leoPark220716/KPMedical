//
//  othersChatItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/7/24.
//

import SwiftUI

struct OthersChatItem: View {
    @Binding var item: ChatMessegeItem
    @State private var url1 = "https://picsum.photos/200/300"
    var body: some View {
        HStack(alignment: .top){
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
            .padding(.leading)
            HStack(alignment: .bottom,spacing: 3){
                VStack(alignment: .leading){
                    Text(item.HospitalName!)
                    Text(item.messege!)
                        .font(.system(size: 17))
                        .padding(10)
                        .foregroundColor(.black)
                        .background(.white)
                        .cornerRadius(10)
                }
                VStack(alignment: .leading){
                    Text("1")
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                    Text("오후 9:25")
                        .font(.system(size: 13))
                }
                Spacer()
            }
            .padding(.trailing,20)
            .padding(.bottom,10)
        }
    }
}
