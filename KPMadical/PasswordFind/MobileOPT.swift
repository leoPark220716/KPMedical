//
//  MobileOPT.swift
//  KPMadical
//
//  Created by Junsung Park on 5/3/24.
//

import SwiftUI
import Combine
struct MobileOPT: View {
    let data: PassViewPathAddress
    @State private var otp: String = ""
    @State private var timeRemaining = 60
    @State private var CheckBool: Bool = false
    @State private var CheckClick: Bool = false
    @State private var GoContentView = false
    @Environment(\.dismiss) var dismiss
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @FocusState private var otpFocused: Bool
    @EnvironmentObject var router: GlobalViewRouter
    let passApi = passwordDataRequest()
    var body: some View {
        VStack {
            Text("휴대전화 인증")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Spacer()
            
            Text("인증번호를 입력해주세요.")
                .font(.headline)
            VStack{
                TextField("인증번호 입력", text: $otp)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(width: 200, height: 30)
                    .cornerRadius(10)
                    .padding()
                    .focused($otpFocused)
                    .onReceive(Just(otp)) { newValue in
                        let filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered != newValue {
                            otp = filtered
                        }
                        otp = String(otp.prefix(6)) // Limit to 6 characters.
                    }
                    .onAppear{
                        otpFocused = true
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(!CheckBool && CheckClick ? Color.red : Color("ConceptColor"), lineWidth: 2)
            )
            if CheckClick && !CheckBool{
                Text("인증번호가 일치하지 않습니다.")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 80)
            }
            Spacer()
            Button("확인 (\(timeRemaining)s)") {
                CheckClick = true
                print("👀 \(data.id)")
                print("👀 \(data.token)")
                print("👀 \(otp)")
                Task{
                    let status = await passApi.checkPasswordChange(otp: otp, account: data.id, token: data.token)
                    if status.0{
                        if status.1{
                            DispatchQueue.main.async{
                                router.passRoutes.append(PassRoute.item(item: PassViewPathAddress(token: status.2, id: data.id, page: 2)))
                            }
                        }
                    }else{
                        DispatchQueue.main.async{
                            router.passRoutes.removeLast()
                        }
                    }
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("ConceptColor"))
            .cornerRadius(20)
            .onReceive(timer) { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }else{
                    router.passRoutes.removeLast()
                }
            }
        }
        .padding()
    }
}


//#Preview {
//    MobileOPT()
//}
