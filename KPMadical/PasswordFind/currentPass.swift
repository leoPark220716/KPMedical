//
//  currentPass.swift
//  KPMadical
//
//  Created by Junsung Park on 5/16/24.
//

import SwiftUI

struct currentPass: View {
    @State var password = ""
    @State var checkBool = false
    @FocusState private var focus: FocusableField?
    @EnvironmentObject var router: GlobalViewRouter
    @EnvironmentObject var authViewModel: UserInformation
    @State private var toast: normal_Toast? = nil
    var body: some View {
        VStack{
            SinglPassField(title: "비밀번호", placeholder: "비밀번호", text: $password, limit: 30, FocusEnum: .passwordfiled,focus: _focus, check: $checkBool)
                .padding(.horizontal)
            Spacer()
            Button{
                if checkBool{
                    router.tabPush(to: Route.pass(item: PassViewPathAddress(token: authViewModel.token, id: password, page: 2, type: 2)))
                }
            } label: {
                customButton(text: "인증번호 전송")
                    .background(checkBool ? Color("ConceptColor") : Color.gray)
            }
        }
        .onChange(of: router.toast){
            if router.toast == true{
                print("show Toast")
                toast = normal_Toast(message: "비밀번호가 올바르지 않습니다.")
                router.toast = false
            }
        }
        .normalToastView(toast: $toast)
        .navigationTitle("현재 비밀번호")
    }
}

#Preview {
    currentPass()
}
