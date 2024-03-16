//
//  SwiftUIView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI

struct SignUpView: View {
    @State var phoneNumber = ""
    @FocusState private var isPhoneNumberFocused: Bool
    var Coment: String = ""
    
    var body: some View {
        NavigationView {
            // 전체 배경색과 안전 영역 무시 설정
            ZStack {
                Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea()
                
                // ScrollView와 하단 버튼을 포함하는 VStack
                VStack {
                    ScrollView {
                        // 입력 필드를 담고 있는 VStack
                        VStack(spacing: 16) {
                            Group{
                                TextField("휴대폰 번호", text: $phoneNumber)
                                    .keyboardType(.numberPad)
                                    .autocapitalization(.none)
                                    .padding(12)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(phoneNumber.count < 11 || phoneNumber.count > 11  ? Color.red : Color("ConceptColor"), lineWidth: 2)
                                    )
                                    .focused($isPhoneNumberFocused)
                                    .onAppear{
                                        self.isPhoneNumberFocused = true
                                    }
                                if phoneNumber.count < 11 || phoneNumber.count > 11 {
                                    Text("정확하게 입력해주세요")
                                        .font(.system(size: 14))
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                        .padding()
                    }
                    // 하단 버튼을 VStack 밖에 배치하여 화면 하단에 고정
                    Button(action: handleAction) {
                        HStack {
                            Spacer()
                            Text("확인")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                        .background(Color("ConceptColor"))
                        
                        
                    }
                }
            }
            .navigationTitle("회원가입")
        }
    }
    
    private func handleAction() {
        
    }
}

#Preview {
    SignUpView()
}
