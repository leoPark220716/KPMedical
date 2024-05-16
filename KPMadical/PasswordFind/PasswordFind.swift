//
//  PasswordFind.swift
//  KPMadical
//
//  Created by Junsung Park on 5/2/24.
//

import SwiftUI

struct PasswordFind: View {
    
    @EnvironmentObject var router: GlobalViewRouter
    @State var account = ""
    @State var phoneNum = ""
    @State private var idCheck = false
    @FocusState private var focus: FocusableField?
    let passApi = passwordDataRequest()
    var body: some View {
        NavigationStack(path: $router.passRoutes){
            VStack{
                IdTextField(title: "아이디", placeholder: "아이디", text: $account, isNumberInput: false, validator: {$0.count >= 6},limit: 30 ,FocusEnum: .accountfiled,focus: _focus,check: false ,isChecked: $idCheck)
                    .padding(.horizontal)
                Spacer()
                Button{
                    Task{
                        let success = await passApi.getPasswordOpt(account: account)
                        if success.0{
                            if success.1{
                                router.passRoutes.append(PassRoute.item(item: PassViewPathAddress(token: success.2, id: account, page: 1,type: 1)))
                            }else{
                                print("Toast 뷰 띄워야함")
                            }
                        }else{
                            print("요청 실패")
                        }
                    }
                    print(account.count)
                } label: {
                    customButton(text: "인증번호 전송")
                        .background(account.count >= 6 ? Color("ConceptColor") : Color.gray)
                }
            }
            .navigationTitle("가입정보로 찾기")
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button(action:{
                        router.currentView = .Login
                    }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear{
                focus = .accountfiled
            }
            .navigationDestination(for: PassRoute.self) { route in
                switch route{
                case .item(item: let item):
                    if item.page == 1{
                        MobileOPT(data: item)
                    }else if item.page == 2{
                        newPassword(data: item)
                    }
                }
            }
        }
    }
}
struct customButton: View{
    let text: String
    var body: some View{
        HStack {
            Text(text)
                .foregroundStyle(Color.white)
                .padding(.vertical,10)
                .font(.system(size: 18, weight: .semibold))
        }
        .frame(maxWidth: .infinity)
    }
}

struct PasswordFind_Previews: PreviewProvider {
    static var previews: some View {
        // GlobalViewRouter의 인스턴스 생성
        let router = GlobalViewRouter()
        
        // PasswordFind 뷰에 환경 객체 제공
        PasswordFind()
            .environmentObject(router)
    }
}

