//
//  recoverWalletView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/4/24.
//

import SwiftUI
import Combine
struct recoverWalletView: View {
    @ObservedObject var userInfo: UserObservaleObject
    @Binding var path: NavigationPath
    @State private var mnimonicText: String = ""
    @State private var isTap: Bool = false
    @State private var password: String = ""
    @State private var checkBool: Bool = true
    let maxCharacters = 500
    @FocusState private var focus: FocusableField?
    let walletHandler = KNPWallet()
    var body: some View {
        VStack{
            ScrollView{
                VStack(alignment: .leading){
                    
                    Text("니모닉 문구 작성란")
                        .bold()
                        .font(.title3)
                        .padding(.leading,20)
                    ZStack{
                        TextEditor(text: $mnimonicText)
                            .font(.custom("Helvetica Nenu", size: 15))
                            .frame(height: 200)
                            .background(Color.white) // 배경 색 설정
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding()
                        // 여기서 모서리를 둥글게 만듭니다.
                            .overlay(
                                RoundedRectangle(cornerRadius: 20) // 모서리가 둥근 사각형 오버레이를 추가하여 테두리 적용
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding(.horizontal)
                            .onReceive(Just(mnimonicText)){
                                mnimonicText = String($0.prefix(100))
                            }
                            .onTapGesture {
                                isTap = true
                            }
                        if !isTap{
                            Text("찾고자 하는 지갑의 니모닉 문구를 작성해주세요.")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("(\(mnimonicText.count)/\(maxCharacters))")
                            .font(.custom("Helvetica Nenu", size: 15))
                            .foregroundColor(maxCharacters == mnimonicText.count ? .red : .blue)
                            .padding(.trailing,30)
                    }
                    SinglPassField(title: "지갑 비밀번호", placeholder: "비밀번호", text: $password, limit: 30, FocusEnum: .passwordfiled,focus: _focus, check: $checkBool)
                        .padding(.horizontal)
                    noticeTextSection
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray)
                        )
                        .padding()
                }
            }
            Spacer()
            Text("지갑 복구")
                .padding()
                .font(.system(size: 20))
                .frame(maxWidth: .infinity)
                .foregroundStyle(Color.white)
                .background(mnimonicText.count > 10 && checkBool ? Color("ConceptColor") : Color.gray)
                .cornerRadius(5)
                .padding()
                .bold()
                .onTapGesture {
                    if mnimonicText.count > 10 && checkBool{
                        print(password)
                        Task{
                           let recoverWallet = await walletHandler.OnTapRecoverButton(mnemonics: mnimonicText, password: password, token: userInfo.token)
                            if recoverWallet{
                                print("성공")
                            }
                        }
                    }
                }
        }
        .navigationTitle("지갑 복구")
    }
    // AttributedString을 처리하는 계산된 속성
    private var noticeTextSection: some View {
        VStack {
            HStack{
                Text("Notice")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            // AttributedString 생성 및 반환
            Text(attributedString)
                .padding()
        }
    }
    
    // "띄어쓰기" 문자열을 파란색으로 강조하는 AttributedString 생성
    private var attributedString: AttributedString {
        var attributedString = AttributedString("니모닉 문구를 사용해 지갑을 복구합니다.\n각 니모닉 단어의 구분은 띄어쓰기로 작성해주세요.")
        if let range = attributedString.range(of: "띄어쓰기") {
            attributedString[range].foregroundColor = .red
        }
        return attributedString
    }
    
}


struct SinglPassField: View{
    let title: String
    var placeholder: String
    @Binding var text: String
    let limit: Int
    let FocusEnum: FocusableField
    @FocusState var focus: FocusableField?
    @StateObject private var passFiledModel = PassFiledModel()
    @Binding var check: Bool
    var body: some View{
        VStack(alignment: .leading, spacing: 5){
            Text(title)
                .font(.system(size: 15))
                    SecureField(placeholder, text: $passFiledModel.text)
//                        .focused($focus, equals: FocusEnum)
                        .onReceive(Just(text)) {
                            text = String($0.prefix(limit))
                            text = passFiledModel.text
                            check = passFiledModel.isTextValid
                        }
                        .autocapitalization(.none)
                        .padding(12)
                        .cornerRadius(10)
                        .onAppear(){
                            focus = FocusEnum
                        }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(passFiledModel.isTextValid ? Color("ConceptColor") :  passFiledModel.text.count > 1 ?Color.red : Color.gray, lineWidth: 2)
                )
            if !passFiledModel.isTextValid && passFiledModel.text.count > 1 {
                    Text("8자 이상 30자리 이하의 숫자, 영문자, 특수문자를 포함한 조합으로 가능합니다.")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
        }
    }
}
