//
//  SignUp.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI

struct Chat: View {
    @Environment(\.dismiss) private var dismiss  // 뷰를 닫기 위한 환경 변수 추가
    @ObservedObject var Count: CountModel
    var body: some View {
        VStack{
            Text("회원가입").onTapGesture {
                Count.sentCount += 1
                dismiss()
            }
                .frame(width: 300, height: 200)
        }
    }
}

//#Preview {
//    SignUp()
//}
