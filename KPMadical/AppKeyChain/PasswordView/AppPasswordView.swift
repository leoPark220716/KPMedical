//
//  AppPasswordView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/4/24.
//

import SwiftUI

struct AppPasswordView: View {
    @ObservedObject var userInfo: UserObservaleObject
    @State private var password: String = ""
    private let passwordLength = 6
    @State private var status = "인증번호를 입력해주세요"
    @State var TitleString: String
    @State var FirstPassword: String = ""
    @State private var statusBool = false
    @State private var tabBool = false
    @State var isCreate: Bool
    
    var body: some View {
        if isCreate{
            GeometryReader { geometry in
                VStack {
                    HStack{
                        Text("재설정")
                            .foregroundStyle(Color.red)
                            .onTapGesture {
                                
                            }
                        Spacer()
                    }
                    Spacer()
                    Text(TitleString)
                        .bold()
                        .font(.title3)
                    HStack {
                        ForEach(0..<passwordLength, id: \.self) { index in
                            Circle()
                                .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Circle().fill(password.count > index ? Color.blue : Color.blue.opacity(0.2))
                                )
                                .padding(.horizontal,4)
                        }
                    }
                    .padding()
                    Text(status)
                        .foregroundStyle(tabBool && !statusBool ? Color.red : Color.black)
                    Spacer()
                    NumberPad(password: $password,FirstPassword: $FirstPassword ,maxLength: passwordLength,status: $status, statusBool: $statusBool, tabBool: $tabBool,isCreate: $isCreate)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
struct NumberPad: View {
    @Binding var password: String
    @Binding var FirstPassword: String
    var maxLength: Int
    @Binding var status: String
    @Binding var statusBool: Bool
    @Binding var tabBool: Bool
    @Binding var isCreate: Bool
    @State var rows = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["Re", "0", "<"]
    ]
    
    // 버튼 간의 수직 간격
    let buttonHeight: CGFloat = 70
    let spacing: CGFloat = 0
    // VStack에 적용될 상단 및 하단 패딩
    let verticalPadding: CGFloat = 0
    
    var body: some View {
        let numberOfRows = rows.count
        // 계산된 전체 높이
        let totalHeight = CGFloat(numberOfRows) * buttonHeight + CGFloat(numberOfRows - 1) * spacing + verticalPadding * 2
        return VStack(spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { item in
                        Button(action: {
                            self.buttonAction(item)
                        }) {
                            Text(item)
                                .bold()
                                .font(.system(size: 21))
                                .frame(height: buttonHeight)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: totalHeight)
        .onAppear{
            rearrangeNumbers()
        }
    }
    
    func buttonAction(_ item: String) {
        if item == "<" {
            password = String(password.dropLast())
        }else if item == "Re" {
            rearrangeNumbers()
        }
        else if password.count < maxLength {
            password.append(item)
            if password.count == maxLength{
                if FirstPassword.count == 0{
                    FirstPassword = password
                    password = ""
                }else{
                    password = ""
                    tabBool = true
                }
            }
        }
    }
    func rearrangeNumbers() {
        var numbers = (1...9).map { String($0) } + ["0"] // 숫자 문자열 배열 생성
        numbers.shuffle() // 배열을 랜덤하게 섞는다
        
        // 랜덤하게 섞인 숫자들로 rows 배열 업데이트
        rows[0] = Array(numbers[0..<3])
        rows[1] = Array(numbers[3..<6])
        rows[2] = Array(numbers[6..<9])
        rows[3][0] = "Re"
        rows[3][1] = numbers[9]
        rows[3][2] = "<"
    }
}


