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
enum FancyToastStyle {
    case error
    case warning
    case success
    case info
}

extension FancyToastStyle {
    var themeColor: Color {
        switch self {
        case .error: return Color.red
        case .warning: return Color.orange
        case .info: return Color.blue
        case .success: return Color.green
        }
    }
    
    var iconFileName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}
struct FancyToast: Equatable {
    var type: FancyToastStyle
    var title: String
    var message: String
    var duration: Double = 3
}
struct FancyToastView: View {
    var type: FancyToastStyle
    var title: String
    var message: String
    var onCancelTapped: (() -> Void)
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Image(systemName: type.iconFileName)
                    .foregroundColor(type.themeColor)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(message)
                        .font(.system(size: 12))
                        .foregroundColor(Color.black.opacity(0.6))
                }
                
                Spacer(minLength: 10)
                
                Button {
                    onCancelTapped()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color.black)
                }
            }
            .padding()
        }
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(type.themeColor)
                .frame(width: 6)
                .clipped()
            , alignment: .leading
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.25), radius: 4, x: 0, y: 1)
        .padding(.horizontal, 16)
    }
}
struct FancyToastModifier: ViewModifier {
    @Binding var toast: FancyToast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: -30)
                }.animation(.spring(), value: toast)
            ).onReceive(Just(toast)) { _ in
                showToast()
            }
    }
    
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                Spacer()
                FancyToastView(
                    type: toast.type,
                    title: toast.title,
                    message: toast.message) {
                        dismissToast()
                    }
            }
            .transition(.move(edge: .bottom))
        }
    }
    private func showToast() {
        guard let toast = toast else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        if toast.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
               dismissToast()
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}



extension View {
    func toastView(toast: Binding<FancyToast?>) -> some View {
        self.modifier(FancyToastModifier(toast: toast))
    }
}
#Preview {
    SplashView()
}
