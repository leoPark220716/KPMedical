//
//  mnemonicView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import SwiftUI

struct mnemonicView: View {
    @Binding var path: NavigationPath
    @Binding var password: String
    @State var Mnemonics = ""
    @State var mnemonicArray: [String] = []
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    @State var isMnemonics = false
    @State var testString = ""
    @State private var toast: normal_Toast? = nil
    let walletHandler = KNPWallet()
    @State private var showAlert = false
    @ObservedObject var userInfo: UserObservaleObject
    let getKeystore = GetKeystore()
    @State var isLoading = false
    var body: some View {
        if !isLoading{
            VStack{
                VStack{
                    if !isMnemonics{
                        Text(isMnemonics ? Mnemonics : "니모닉을 생성해 주세요")
                            .foregroundStyle(Color.gray)
                            .bold()
                            .padding()
                            .padding(.top)
                    }else{
                        LazyVGrid(columns: columns){
                            ForEach(mnemonicArray.indices, id: \.self){ value in
                                Text(mnemonicArray[value])
                                    .padding()
                                    .font(.system(size: 14))
                                    .frame(width: 100, height: 40)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }
                    }
                    Text(isMnemonics ? "Copy" : "니모닉 문구 생성")
                        .bold()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(Color("ConceptColor"))
                        .cornerRadius(10)
                        .padding(.top)
                        .onTapGesture {
                            if !isMnemonics{
                                Mnemonics = walletHandler.generateMnmonics()
                                if Mnemonics != "니모닉 생성에 실패했습니다. 다시 시도해주세요." {
                                    isMnemonics = true
                                    mnemonicArray = Mnemonics.components(separatedBy: " ")
                                }
                            }else{
                                let pasteboard = UIPasteboard.general
                                pasteboard.string = Mnemonics
                                toast = normal_Toast(message: "클립보드에 복사되었습니다.")
                            }
                        }
                    
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray)
                )
                .padding()
                VStack{
                    HStack{
                        Text("Notice")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    .padding([.horizontal,.top])
                    Text("니모닉 문구는 귀하의 의료 데이터 정보를 안전하게 보호하는 열쇠입니다.\n이 문구는 지갑 복구에 필수적이며, 분실 시 자산을 영구적으로 잃을 수 있습니다.\n따라서 니모닉 문구를 안전한 곳에 기록해두고, 절대로 타인과 공유되지 않도록 주의해주시기 바랍니다.")
                        .padding()
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray)
                )
                .padding()
                Spacer()
                Text("지갑 생성")
                    .padding()
                    .font(.system(size: 20))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color.white)
                    .background(isMnemonics ? Color("ConceptColor") : Color.gray)
                    .cornerRadius(5)
                    .padding()
                    .bold()
                    .onTapGesture {
                        if isMnemonics{
                            self.showAlert = true
                        }
                    }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("지갑을 생성하시겠습니까?"),
                    message: Text("니모닉 문구는 한 번만 제공되며 다시 확인할 수 없습니다."),
                    primaryButton: .destructive(Text("확인")) {
                        isLoading = true
                        print(walletHandler.GetUserAccountString(token: userInfo.token).account)
                        Task{
                            let success = await walletHandler.OnTapOkButton(token: userInfo.token, password: password, Mnemonics: Mnemonics)
                            if success{
                                toast = normal_Toast(message: "지갑 생성이 완료되었습니다.")
                                path = .init()
                            }
                            isLoading = false
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .normalToastView(toast: $toast)
            .navigationTitle("니모닉 생성")
            .navigationBarBackButtonHidden(isLoading ? true : false)
            .navigationBarTitleDisplayMode(.inline)
        }else{
            SpinnerView(Title: "지갑을 생성하고 있습니다...")
                .navigationBarBackButtonHidden(true)
        }
    }
}

//struct mnemonicView_Previews: PreviewProvider {
//    // 프리뷰를 위한 더미 ObservableObject
//    static var dummyUserInfo = UserObservaleObject()
//    
//    // 프리뷰를 위한 더미 바인딩
//    @State static var dummyPath = NavigationPath()
//    @State static var dummyPassword = "asdfasdf12@@"
//    
//    static var previews: some View {
//        mnemonicView(path: $dummyPath, password: $dummyPassword, userInfo: dummyUserInfo)
//    }
//}
