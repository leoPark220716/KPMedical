//
//  SplashView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI
import Combine
struct SplashView: View {
    @State var isActive: Bool = false
    let UserData = LocalDataBase.shared
    let AoutoLogin = LoginTockenFunc()
    @StateObject private var sign = singupOb()
    @StateObject private var userInfo = UserObservaleObject()
    var body: some View {
            ZStack {
                Color("SplashBack").edgesIgnoringSafeArea(.all) // 화면 전체에 색상 적용
                if self.isActive {
                    if userInfo.isLoggedIn {
                        ContentView(authViewModel: userInfo)
                    }else{
                        LoginView(authViewModel: userInfo, sign: sign)
                    }
                } else {
                    VStack {
                        Text("KP Madical")
                            .font(.system(size: 40))
                            .bold()
                            .foregroundColor(.black) // 텍스트 색상을 밝은 색으로 설정
                            .padding(.top, 100) // 상단 여백 추가
                        Spacer() // 나머지 공간을 모두 차지하도록 설정
                    }
                    Image("Splash")
                        .resizable()
                        .scaledToFit()
                }
            }
            .onAppear {
                UserData.createTable()
                UserData.readUserDb(userState: userInfo)
                AoutoLogin.CheckToken(token: userInfo.token, uid: getDeviceUUID()) { check,TokenCheck,token in
                    if check{
                        //  객체에 저장된 정보 그대로 유지
                        //  DB 유지
                        userInfo.isLoggedIn = true
                        // 토큰이 다를 경우
                        // 메모리 객체 업데이트, DB 업데이트
                        if !TokenCheck {
                            // DB 업데이트
                            UserData.updateToken(token: token)
                            // 메모리 객체 업데이트
                            userInfo.token = token
                        }
                    }else{
                        //  객체 초기화
                        userInfo.SetData(name: "", dob: "", sex: "", token: "")
                        //  DB 에 저장된 정보 정보 전부 삭제
                        UserData.removeAllUserDB()
                    }
                }
//                스플래시 기능임
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation {
                        print(userInfo.isLoggedIn)
                        print(userInfo.name)
                        print(userInfo.dob)
                        print(userInfo.sex)
                        print(userInfo.token)
                        self.isActive = true
                    }
                }
            }
        }
    }
#Preview {
    SplashView()
}
