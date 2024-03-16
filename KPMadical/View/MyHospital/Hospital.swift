//
//  SignUp.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI

struct Hospital: View {
    @Environment(\.dismiss) private var dismiss  // 뷰를 닫기 위한 환경 변수 추가
    @ObservedObject var Count: CountModel
    @State private var isFullScreen = false // Add this line

    var body: some View {
        VStack{
            Text("내병원").onTapGesture {
                isFullScreen = true
//                Count.sentCount += 1
//                dismiss()
            }
                .frame(width: 300, height: 200)
                .fullScreenCover(isPresented: $isFullScreen){
                    ntentView()
                }
        }
    }
}
extension Notification.Name {
    static let test = Notification.Name("test")
}
struct ntentView: View {
    @State private var isShowingDetailView = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            NavigationLink(destination: DetailView()){
                Text("gogo")
            }
        }.onReceive(NotificationCenter.default.publisher(for: .test)) { _ in
            // 이벤트 감지 시 부모 뷰를 닫음
            dismiss()
        }
    }
}

struct DetailView: View {

    var body: some View {
        VStack{
            Button("Close All Views") {
                NotificationCenter.default.post(name: .test, object: nil)
            }.padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
            NavigationLink(destination: SecondDetailView()){
                Text("go")
            }
        }
    }
}

struct SecondDetailView: View {
    var body: some View {
        Button("Close All Views") {
            NotificationCenter.default.post(name: .test, object: nil)
        }.padding()
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

//#Preview {
//    SignUp()
//}
