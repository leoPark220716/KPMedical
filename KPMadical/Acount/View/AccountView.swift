//
//  AccountView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/13/24.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var authViewModel: UserInformation
    let UserDb = LocalDataBase.shared
    @EnvironmentObject var router: GlobalViewRouter
    let CheckPassword = AppPasswordKeyChain()
    @State var isOPT = false
    @State var create = true
    let appKeyChain = AppPasswordKeyChain()
    var body: some View {
        
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(Color("ConceptColor"))
                        .font(.system(size: 25))
                        .padding(.leading)
                    Text("내 정보")
                    Spacer()
                }
                .padding(.top)
                .background(Color.white)
                .onTapGesture {
                    appKeyChain.deleteAllKeyChainItems()
                }
                HStack{
                    Image(systemName: "menubar.dock.rectangle")
                        .foregroundStyle(Color("ConceptColor"))
                        .font(.system(size: 21))
                        .padding(.leading)
                    Text("KnP Wallet")
                    Spacer()
                }
                .padding(.top)
                .background(Color.white)
                .onTapGesture {
                    let account = CheckPassword.GetUserAccountString(token: authViewModel.token)
                    if !account.status{
                        return
                    }
                    if CheckPassword.checkPasswordExists(account: account.account){
                        print("있음")
                        create = false
                        isOPT.toggle()
                    }else{
                        isOPT.toggle()
                    }
                }
                .sheet(isPresented: $isOPT){
                    if create{
                        AppPasswordView(userInfo: authViewModel, TitleString: "인증번호를 생성해주세요.",isCreate: $create)
                    }else{
                        AppPasswordView(userInfo: authViewModel, TitleString: "인증번호를 입력해주세요.",isCreate: $create)
                    }
                }
                
                HStack{
                    Image(systemName: "doc.text")
                        .foregroundStyle(Color("ConceptColor"))
                        .font(.system(size: 27))
                        .padding(.leading)
                    Text("진료기록")
                    Spacer()
                }
                .padding(.top)
                .background(Color.white)
                .onTapGesture {
                    let BodyData = FcmToken.FcmTokenSend.init(fcm_token: authViewModel.FCMToken)
                    let httpStruct = http<FcmToken.FcmTokenSend?, KPApiStructFrom<FcmToken.FcmTokenResponse>>.init(
                        method: "POST",
                        urlParse: "v2/fcm",
                        token: authViewModel.token,
                        UUID: getDeviceUUID(),
                        requestVal: BodyData
                    )
                    Task{
                     let result = await KPWalletApi(HttpStructs: httpStruct)
                        if result.success{
                            print(result.data?.message ?? "Option Null")
                        }else{
                            print(result.data?.message ?? "Option Null")
                        }
                    }
                }
                Spacer()
            }
            
            .navigationTitle("내 계정")
            .navigationBarTitleDisplayMode(.automatic)
        
    }
}

