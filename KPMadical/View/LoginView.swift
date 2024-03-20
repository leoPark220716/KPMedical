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

struct LoginView: View {
    let UserData = LocalDataBase.shared
    @ObservedObject var authViewModel: UserObservaleObject
    @ObservedObject var sign: singupOb
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var checkBool: Bool = true
    @Environment(\.dismiss) private var closeLoginView  // 뷰를 닫기 위한 환경 변수
    @FocusState private var focusID
    @State private var toast: FancyToast? = nil
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path){
            ZStack {
                VStack(spacing: 20) { // Reduce spacing between elements in VStack
                    Spacer()
                    Text("Madical Wallet")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("ConceptColor"))
                    
                    TextField("아이디", text: $email)
                        .focused($focusID)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(checkBool ? Color.gray : Color.red, lineWidth: 2)
                        )
                        .padding(.horizontal) // Apply horizontal padding only
                    SecureField("비밀번호", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(checkBool ? Color.gray : Color.red, lineWidth: 2)
                        )
                        .padding(.horizontal)
                    Button(action: {
                        requestLogin(account: email, password: password, uid: getDeviceUUID(),userstate: authViewModel){ isSuccess, token in
                            print("print is Success\(isSuccess)")
                            if isSuccess {
                                UserData.insert(name: authViewModel.name, dob: authViewModel.dob, sex: authViewModel.sex, token: authViewModel.token)
                                authViewModel.SetLoggedIn(logged: true)
                            }else{
                                toast = FancyToast(type: .error, title: "아이디 또는 비밀번호가 올바르지 않습니다.", message: "올바른 아이디, 비밀번호를 작성해주세요")
                                print("no")
                                checkBool = false
                                password = ""
                                focusID = true
                            }
                        }
                    }) {
                        Text("로그인")
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
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
                    
                }.toastView(toast: $toast)
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .navigationDestination(for: Destination.self) { dse in
                switch dse {
                case .signUp:
                    SignUpView(path: $path,id: $sign.id, Checkpassword: $sign.Checkpassword,name: $sign.name , birthday: $sign.birthday ,sex: $sign.sex ,smsCheck: $sign.smsCheck,phoneNumber: $sign.phoneNumber, password: $sign.password,message:$sign.message) // 'DetailView'는 여러분이 네비게이션하고자 하는 대상 뷰입니다.

                case .signUpOPT:
                    SingleOTPView(path: $path,account: $sign.id,password: $sign.Checkpassword,name: $sign.name, dob: $sign.birthday,sex_code: $sign.sex, smsCheck: $sign.smsCheck, mobileNum: $sign.phoneNumber) // 'DetailView'는 여러분이 네비게이션하고자 하는 대상 뷰입니다.
                }
            }
        }
        
    }
}
struct DetailView1: View {
    var body: some View {
        VStack {
            Text("Detail Page")
                .font(.largeTitle)
                .padding()
            
            Divider()
            
            // 내용 목록
            List {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
            }
            
            Spacer() // 아래쪽으로 내용을 밀어냄
        }
        .navigationBarTitle("Detail View", displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
            // 여기에 뒤로 가기 액션을 추가
        }) {
            Text("Back")
        })
    }
}
enum Destination {
    case signUp
    case signUpOPT
    // 다른 뷰 식별자를 추가할 수 있습니다.
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
