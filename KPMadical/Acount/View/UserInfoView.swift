//
//  UserInfoView.swift
//  KPMadical
//
//  Created by Junsung Park on 5/15/24.
//
import SwiftUI

struct UserInfoView: View {
    @State private var name: String = "박준성"
    @State private var birthDate: String = "1997.02.11"
    @State private var gender: String = "남성"
    @StateObject private var infomation = UserInfoRequest()
    @EnvironmentObject var authViewModel: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    let appKeyChain = AppPasswordKeyChain()
    let Account_handler = AccountViewHandler()
    let UserDb = LocalDataBase.shared
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 사용자 정보
            HStack {
                VStack(alignment: .leading) {
                    Text(name)
                        .font(.title)
                        .fontWeight(.bold)
                    Text("📲\(infomation.formatPhoneNumber(infomation.phoneNumber))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                getImage(for: gender)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            }
            .padding()
            // 내 계좌
            HStack {
                Text("💶 내 지갑")
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            // 전자서명
            HStack {
                Text("✍️ 서명")
                    .font(.body)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            HStack {
                Text("로그아웃")
                    .font(.body)
                    .foregroundStyle(Color.red)
                
                Spacer()
            }
            .onTapGesture {
                Task{
                    let success = await Account_handler.TokenToServer(httpMethod: "DELETE", token: authViewModel.token, FCMToken: authViewModel.FCMToken)
                    if success {
                        UserDb.removeAllUserDB()
                        router.ReservationDeInit()
                        appKeyChain.deleteAllKeyChainItems()
                        DispatchQueue.main.async{
                            authViewModel.initData()
                            router.currentView = .Login
                        }
                    }else{
                        print("삭제 요청 실패")
                    }
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .onAppear{
            infomation.getMoblie(token: authViewModel.token)
        }
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button(action:{
                    router.tabPush(to: Route.item(item: ViewPathAddress(name: infomation.phoneNumber, page: 11, id: 11)))
                }){
                    Text("수정")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.blue)
                }
            }
        }
        .background(Color.white)
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func getImage(for gender: String) -> Image {
        return gender == "남성" ? Image("man") : Image("woman")
    }
}

#Preview {
    UserInfoView()
}
