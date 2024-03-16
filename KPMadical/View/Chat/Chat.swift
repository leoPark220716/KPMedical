//
//  Chat.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI

struct Chat: View {
    @State private var isVisible: Bool = false // 뷰의 표시 여부를 결정하는 상태 변수

     var body: some View {
         VStack {
            
             Button("클릭 시 사라짐") {
                 isVisible = true // 버튼 클릭 시 isVisible의 값을 반전시켜 뷰를 표시하거나 숨김
             }
             .fullScreenCover(isPresented: $isVisible){
                 ParentView()
             }
             .padding()
             .background(Color.blue)
             .foregroundColor(.white)
             .clipShape(Capsule()) // 버튼 디자인을 조금 더 꾸며주기 위해 추가
         }
     }
 }


#Preview {
    Chat()
}

    
import SwiftUI
import Combine

extension Notification.Name {
    static let closeParentView = Notification.Name("closeParentView")
}


struct ParentView: View {
    @State private var isChildViewPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack{
                Button("자식 뷰 열기") {
                    isChildViewPresented = true
                }
                .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                .navigationDestination(isPresented: $isChildViewPresented) {
                    ChildView(isPresented: $isChildViewPresented)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeParentView)) { _ in
            // 이벤트 감지 시 부모 뷰를 닫음
            dismiss()
        }
    }
}



struct ChildView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("??")
            Button("닫기") {
                // 자식 뷰를 닫음
                isPresented = false
                // NotificationCenter를 통해 이벤트 방송
                NotificationCenter.default.post(name: .closeParentView, object: nil)
            }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}
