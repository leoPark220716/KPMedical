//
//  NotiveChatView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/17/24.
//

import SwiftUI

struct NotiveChatView: View {
    var message: String
    var body: some View {
        VStack{
            ZStack(alignment:.top){
                VStack(alignment: .leading,spacing: 3){
                    HStack{
                        Text("")
                            .bold()
                        Spacer()
                    }
                    Text(message)
                        .font(.system(size: 14))
                        .padding(10)
                        .padding(.top,20)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                }
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray)
                )
                .overlay(
                    Rectangle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(height:30)
                        .clipped()
                    , alignment: .top
                )
                .cornerRadius(10)
                HStack{
                    Text("알림톡 도착")
                        .bold()
                        .font(.system(size: 14))
                        .padding(.leading, 10)
                        .padding(.top, 8)
                    Spacer()
                }
            }
        }
        .frame(width: 220)
    }
}

#Preview {
    OthersChatItemTest()
}
struct OthersChatItemTest: View {
    
    @State private var url1 = "https://picsum.photos/200/300"
    var body: some View {
        HStack(alignment: .top,spacing: 3){
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
            VStack(alignment: .leading,spacing: 3){
                HStack{
                    Text("wsdf")
                        .font(.system(size: 12))
                }
                HStack(alignment: .bottom,spacing: 3){
                    NotiveChatView(message: "asdf")
                    VStack(alignment: .leading){
                        Text("오후 12:00")
                            .font(.system(size: 12))
                    }
                }
            }
            .padding(.leading,3)
            Spacer()
        }
        .padding(.bottom,5)
        .padding(.leading)
        .padding(.trailing,20)
    }
}
