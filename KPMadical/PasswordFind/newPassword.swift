//
//  newPassword.swift
//  KPMadical
//
//  Created by Junsung Park on 5/3/24.
//

import SwiftUI

struct newPassword: View {
    @State var password:String = ""
    @State var Checkpassword:String = ""
    @State private var passCheck = false
    @FocusState private var focus: FocusableField?
    let passApi = passwordDataRequest()
    let data: PassViewPathAddress
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        VStack{
            PassTextField(title: "비밀번호", placeholder: "비밀번호", text: $password,checktext: $Checkpassword, isNumberInput: false, validator: {$0.count >= 8},limit: 30,FocusEnum: .passwordfiled,focus: _focus, isChecked: $passCheck)
                .padding()
            Spacer()
            Text("다음")
                .padding()
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.white)
                .background(passCheck ? Color("ConceptColor") : Color.gray)
                .cornerRadius(5)
                .padding()
                .bold()
                .onTapGesture {
                    if passCheck{
                        if data.type == 2{
                            Task{
                                let success = await passApi.patchPassword(type: 2, new_pass: Checkpassword, pass: data.id, token:  data.token)
                                if success{
                                    router.routes.removeLast(2)
                                }else{
                                    router.toast = true
                                    router.goBack()
                                }
                            }
                        }else{
                            Task{
                                let success = await passApi.patchPassword(type: 1, new_pass: Checkpassword, pass: "", token:  data.token)
                                if success{
                                    DispatchQueue.main.async {
                                        router.currentView = .Login
                                        router.passRoutes.removeAll()
                                    }
                                }
                            }
                        }
                    }
                }
        }
        .navigationTitle("새비밀번호 등록")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    newPassword()
//}
