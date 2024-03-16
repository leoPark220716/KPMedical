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
func getDeviceUUID() -> String {
    return UIDevice.current.identifierForVendor!.uuidString
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
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var checkBool: Bool = true
    @Environment(\.dismiss) private var closeLoginView  // 뷰를 닫기 위한 환경 변수 추가
    @FocusState private var focusID
    @State private var toast: FancyToast? = nil
    
    var body: some View {
        NavigationView {
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
                        requestLogin(account: email, password: password, uid: getDeviceUUID()){ isSuccess, token in
                            print("print is Success\(isSuccess)")
                            if isSuccess {
                                print("Yes")
                                print(token)
                                closeLoginView()
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

                    NavigationLink(destination: SignUpView()) {
                        Text("아직 회원이 아니신가요? 가입하기")
                            .foregroundColor(.blue)
                    }
                    
                }.toastView(toast: $toast)
                .padding(.horizontal)
                .padding(.top, 20)
                
            }
        }.onReceive(NotificationCenter.default.publisher(for: .CloseLoginChanel)){ _ in
            closeLoginView()
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

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
