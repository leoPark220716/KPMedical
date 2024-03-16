//
//  SingleOPTView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/14/24.
//

import SwiftUI
import Combine
struct SingleOTPView: View {
    @Binding var account: String
    @Binding var password: String
    @Binding var name: String
    @Binding var dob: String
    @Binding var sex_code: String

    @Binding var smsCheck: Bool
    @Binding var smsCheckInt: String
    @Binding var mobileNum: String
    @State private var otp: String = ""
    @State private var Token: String = ""
    @State private var timeRemaining = 60
    @State private var CheckBool: Bool = false
    @State private var CheckClick: Bool = false
    @Environment(\.dismiss) var dismiss
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @FocusState private var otpFocused: Bool
    var body: some View {
        VStack {
            Text("휴대전화 인증")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Spacer()
            
            Text("인증번호를 입력해주세요.")
                .font(.headline)
            
            Text("\(mobileNum) 로 전송됨")
                .font(.subheadline)
                .padding(.bottom, 20)
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
                        requestMoblieCheck(mobile: mobileNum) { isSuccess, response in
                            if isSuccess{
                                Token = response
                            }
                        }
                    }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(!CheckBool && CheckClick ? Color.red : Color("ConceptColor"), lineWidth: 2)
            )
            if CheckClick && !CheckBool{
                Text("일치하지 않습니다.")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 80)
            }
            Spacer()
            Button("확인 (\(timeRemaining)s)") {
                CheckClick = true
                print(CheckBool)
                print(CheckClick)
                requestSmsCheck(mobile: mobileNum, Token: Token, CheckNum: otp){ isSuccess, res in
                    if isSuccess{
                        print("SmsCheck OK")
                        if res == 200 {
                            CheckBool = true
                            requestSignUp(account: account, password: password, moblie: mobileNum, name: name, dob: "19"+dob, sex_code: sex_code){
                                isSuccess, res in
                                if isSuccess {
                                    print("SIgunUp OK")
                                    NotificationCenter.default.post(name: .CloseLoginChanel, object: nil)
                                }
                            }
                        }else{
                            CheckBool = false
                        }
                    }else{
                        CheckBool = false
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
                    dismiss()
                }
            }
        }
        .padding()
    }
}
