//
//  NewPhoneNumberView.swift
//  KPMadical
//
//  Created by Junsung Park on 5/16/24.
//

import SwiftUI

struct NewPhoneNumberView: View {
    @State private var phoneNumber: String = ""
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    private var infomation = UserInfoRequest()
    var body: some View {
        VStack {
            // 상단 바
            HStack {
                Text("새로운 휴대전화번호를 입력해 주세요.")
                    .font(.title3)
                    .bold()
                    .padding()
                Spacer()
            }
//            HStack{
//                Text("본인 명의의 휴대전화번호만 등록 가능해요.")
//                    .font(.subheadline)
//                    .padding(.horizontal)
//                Spacer()
//            }
            VStack(alignment: .leading, spacing: 16) {
                
                Text("휴대전화번호")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    TextField("휴대폰번호", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color("ConceptColor"), lineWidth: 2)
                        )
                        .onChange(of: phoneNumber){
                            if phoneNumber.count > 11{
                                phoneNumber = String(phoneNumber.prefix(11))
                            }
                        }
                    Button(action: {
                        phoneNumber = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
                
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                // 확인 버튼 액션
                Task{
                    let actions = await infomation.getOptMoblie(mobile: phoneNumber)
                    if actions.success {
                        DispatchQueue.main.async {
                            router.tabPush(to: Route.pass(item: PassViewPathAddress(token: actions.token, id: phoneNumber, page: 4, type: 2)))
                        }
                    }
                }
            }) {
                Text("확인")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(phoneNumber.count == 11 ?  Color("ConceptColor") : Color.gray.opacity(0.6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("내 정보 수정")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NewPhoneNumberView()
}
