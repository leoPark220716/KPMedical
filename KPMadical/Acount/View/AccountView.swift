//
//  AccountView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/13/24.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var authViewModel: UserObservaleObject
    let UserDb = LocalDataBase.shared
    @State var path = NavigationPath()
    @EnvironmentObject var router: GlobalViewRouter
    let CheckPassword = AppPasswordKeyChain()
    @State var isOPT = false
    var body: some View {
        NavigationStack(path: $path){
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
                    print("내정보")
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
                        print("isE")
                        router.currentView = .myWallet
                    }else{
                        isOPT.toggle()
                    }
                    print("KnP Wallet")
                }
                .sheet(isPresented: $isOPT){
                    AppPasswordView(userInfo: authViewModel, TitleString: "인증번호를 생성해주세요.",isCreate: true)
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
                    print("진료기록")
                }
                Text("임시 로그아웃").onTapGesture {
                    authViewModel.SetLoggedIn(logged: false)
                    UserDb.removeAllUserDB()
                }
                Spacer()
            }
            .onAppear{
                router.RetrunUserId()
            }
            .navigationTitle("내 계정")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}
struct ViewTest: View{
    @State var path = NavigationPath()
    var body: some View{
        NavigationStack(path: $path){
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
                    print("내정보")
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
                
                    print("KnP Wallet")
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
                    print("진료기록")
                }
                Spacer()
            }
            
        }
    }
}

struct ViewTestPreviews: PreviewProvider {
    static var previews: some View {
        ViewTest()
            
    }
}
