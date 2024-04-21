//
//  LoginView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/14/24.
//

import SwiftUI
extension Notification.Name {
    static let CloseLoginChanel = Notification.Name("CloseLoginView")
}

protocol asdf {
    var asdf: String {get}
}
extension Int: asdf {
    var asdf: String {
        return String(self)
    }
}

import SwiftUI

struct LoginView: View {
    let userData = LocalDataBase.shared
    @EnvironmentObject var authViewModel: UserInformation
    @ObservedObject var sign: singupOb
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var checkBool: Bool = true
    @Environment(\.dismiss) private var closeLoginView  // 뷰를 닫기 위한 환경 변수
    @State private var toast: FancyToast? = nil
    @State private var path = NavigationPath()
    @State private var PressLoginButtn = false
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        NavigationStack(path: $path) {
            if !PressLoginButtn {
                VStack(spacing: 20) {
                    Spacer()
                    Text("Medical Wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ConceptColor"))
                    
                    TextField("아이디", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(checkBool ? Color.gray : Color.red, lineWidth: 2)
                        )
                    
                    SecureField("비밀번호", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(checkBool ? Color.gray : Color.red, lineWidth: 2)
                        )
                    
                    Button(action: {
                        PressLoginButtn = true
                        requestLogin(account: email, password: password, uid: getDeviceUUID(),userstate: authViewModel){ isSuccess, token in
                            print("print is Success\(isSuccess)")
                            if isSuccess {
                                Task{
                                    await userData.insert(name: authViewModel.name, dob: authViewModel.dob, sex: authViewModel.sex, token: authViewModel.token)
                                }
                                DispatchQueue.main.async{
                                    router.currentView = .tab
                                }
                            }else{
                                PressLoginButtn = false
                                toast = FancyToast(type: .error, title: "아이디 또는 비밀번호가 올바르지 않습니다.", message: "올바른 아이디, 비밀번호를 작성해주세요")
                                print("no")
                                password = ""
                            }
                        }
                                            
                    }) {
                        Text("로그인")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("ConceptColor"))
                            .cornerRadius(25)
                    }
                    
                    Text("비밀번호를 잊으셨나요?")
                        .foregroundColor(.blue)
                    
                    Divider()
                    
                    Text("간편 로그인")
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 20) {
                        SocialLoginButton(systemName: "message.fill", color: .pink)
                        SocialLoginButton(systemName: "f.circle.fill", color: .blue)
                        SocialLoginButton(systemName: "g.circle.fill", color: .red)
                    }
                    
                    Spacer()
                    
                    Text("아직 회원이 아니신가요? 가입하기")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            path.append(Destination.signUp)
                        }
                }
                .toastView(toast: $toast)
                .padding(.horizontal)
                .padding(.top, 20)
                .navigationDestination(for: Destination.self) { dest in
                    switch dest {
                    case .signUp:
                        SignUpView(path: $path,id: $sign.id, Checkpassword: $sign.Checkpassword,name: $sign.name , birthday: $sign.birthday ,sex: $sign.sex ,smsCheck: $sign.smsCheck,phoneNumber: $sign.phoneNumber, password: $sign.password,message:$sign.message) // 'DetailView'는 여러분이 네비게이션하고자 하는 대상 뷰입니다.
                    case .signUpOPT:
                        SingleOTPView(path: $path,account: $sign.id,password: $sign.Checkpassword,name: $sign.name, dob: $sign.birthday,sex_code: $sign.sex, smsCheck: $sign.smsCheck, mobileNum: $sign.phoneNumber) // 'DetailView'는 여러분이 네비게이션하고자 하는 대상 뷰입니다.
                    }
                }
            }
            else{
                ZStack {
                    VStack {
                        Spacer() // 나머지 공간을 모두 차지하도록 설정
                        Text("로그인 중입니다..")
                            .font(.system(size: 20))
                            .bold()
                            .foregroundColor(.black) // 텍스트 색상을 밝은 색으로 설정
                            .padding(.top, 100) // 상단 여백 추가
                        Spacer() // 나머지 공간을 모두 차지하도록 설정
                    }
                    Color("SplashBack").edgesIgnoringSafeArea(.all) // 화면 전체에 색상 적용
                    Image("Splash")
                        .resizable()
                        .scaledToFit()
                }
            }
        }
    }
    

}

struct SocialLoginButton: View {
    let systemName: String
    let color: Color
    
    var body: some View {
        Image(systemName: systemName)
            .foregroundColor(.white)
            .padding()
            .background(color)
            .clipShape(Circle())
    }
}

enum Destination {
    case signUp
    case signUpOPT
    // 다른 뷰 식별자를 추가할 수 있습니다.
}
