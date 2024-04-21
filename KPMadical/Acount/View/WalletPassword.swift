//
//  Profile.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI

struct WalletPassword: View {
    @Binding var path: NavigationPath
    @State var password:String = ""
    @Binding var Checkpassword:String
    @State private var passCheck = false
    @FocusState private var focus: FocusableField?
    @ObservedObject var userInfo: UserInformation
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
                        path.append(2)
                    }
                }
        }
        .navigationTitle("지갑 비밀번호 등록")
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    WalletPassword()
//}
