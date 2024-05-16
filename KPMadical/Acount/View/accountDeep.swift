//
//  accountDeep.swift
//  KPMadical
//
//  Created by Junsung Park on 5/16/24.
//

import SwiftUI

struct accountDeep: View {
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @StateObject private var infomation = UserInfoRequest()
    let data: any PathAddress
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 10){
                Text("이름")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(authViewModel.name)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("생년월일")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(authViewModel.dob)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("전화번호")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text(infomation.formatPhoneNumber(infomation.phoneNumber))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .onTapGesture {
                        router.tabPush(to: Route.pass(item: PassViewPathAddress(token: authViewModel.token, id: "", page: 3, type: 2)))
                    }
                Text("비밀번호")
                    .font(.subheadline)
                    .foregroundStyle(Color.gray)
                Text("*******")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .onTapGesture {
                        router.tabPush(to: Route.pass(item: PassViewPathAddress(token: authViewModel.token, id: "", page: 1, type: 2)))
                    }
                Spacer()
                    
            }
            .onAppear{
                infomation.getMoblie(token: authViewModel.token)
            }
            .padding()
        }
    }
}


