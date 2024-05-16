//
//  SwiftUIView.swift
//  KPMadical
//
//  Created by Junsung Park on 5/15/24.
//

import SwiftUI

struct newAccountView: View {
    @EnvironmentObject var authViewModel: UserInformation
    
    @EnvironmentObject var router: GlobalViewRouter
    let CheckPassword = AppPasswordKeyChain()
    @State var isOPT = false
    @State var create = true
    
    var body: some View {
        VStack {
            // 사용자 정보
            HStack {
                VStack(alignment: .leading){
                    Text(authViewModel.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(authViewModel.dob)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .padding([.leading, .trailing])
            .onTapGesture {
                router.tabPush(to: Route.item(item: ViewPathAddress(name: "myProfile", page: 10, id: 1)))
//                로그아웃
//                Task{
//                 let success = await Account_handler.TokenToServer(httpMethod: "DELETE", token: authViewModel.token, FCMToken: authViewModel.FCMToken)
//                    if success {
//                        UserDb.removeAllUserDB()
//                        router.ReservationDeInit()
//                        appKeyChain.deleteAllKeyChainItems()
//                        DispatchQueue.main.async{
//                            authViewModel.initData()
//                            router.currentView = .Login
//                        }
//                    }else{
//                        print("삭제 요청 실패")
//                    }
//                }
            }
            // 나의 프로젝트
            VStack(alignment: .leading) {
                Text("내 병원 관리")
                    .font(.headline)
                    .padding([.top])
                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: 100)
                        .overlay(
                            HStack(spacing: 0) {
                                ProjectInfoView(title: "등록병원", count: "3개")
                                    .onTapGesture {
                                        router.exportTapView = .hospital
                                    }
                                Divider()
                                ProjectInfoView(title: "예약현황", count: "3건")
                                    .onTapGesture {
                                        router.tabPush(to: Route.item(item: ViewPathAddress(name: "MyreservationView", page: 9, id: 9)))
                                    }
                                Divider()
                                ProjectInfoView(title: "정보요청", count: "0건")
                            }
                        )
                        .padding(.bottom)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    Spacer()
                }
                // 와디즈 계좌
                HStack {
                    Text("K&P 지갑")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Text("인증번호만 입력하면 끝🔥")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white) // 배경색을 설정하여 테두리가 더 잘 보이게 함
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("ConceptColor"), lineWidth: 1) // 테두리 설정
                )
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
                .padding(.top)
            }
            .padding([.leading, .trailing])
            // 메시지, 쿠폰, 포인트
            VStack {
                MenuRowView(title: "상담 알림설정", toggleKey: "counselingNotification")
                MenuRowView(title: "이동 알림설정", toggleKey: "movementNotification")
                MenuRowView(title: "정보요청 알림설정", toggleKey: "infoRequestNotification")
            }
            .padding([.leading, .trailing])
            
            Spacer()
        }
        .background(Color.gray.opacity(0.09).edgesIgnoringSafeArea(.all))
    }
}

struct ProjectInfoView: View {
    let title: String
    let count: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom,4)
            Text(count)
                .font(.headline)
        }
        .frame(maxWidth: .infinity) // 추가: 각 요소를 균등하게 분배하기 위해 최대 너비를 사용
        .padding()
    }
}

struct MenuRowView: View {
    let title: String
    let toggleKey: String
    @State private var isToggled: Bool
    
    init(title: String, toggleKey: String) {
        self.title = title
        self.toggleKey = toggleKey
        self._isToggled = State(initialValue: UserDefaults.standard.bool(forKey: toggleKey, defaultValue: false))
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
            Spacer()
            Toggle("", isOn: $isToggled)
                .onChange(of: isToggled) {
                    UserDefaults.standard.setBool(value: isToggled, forKey: toggleKey)
                }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding([.top, .bottom], 5)
    }
}
extension UserDefaults {
    func setBool(value: Bool, forKey key: String) {
        self.set(value, forKey: key)
    }
    
    func bool(forKey key: String, defaultValue: Bool) -> Bool {
        return self.object(forKey: key) as? Bool ?? defaultValue
    }
}
#Preview {
    newAccountView()
}
