//
//  SwiftUIView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI
import Combine
// 포커스 이동
// https://phillip5094.tistory.com/117
class IDFieldModel: ObservableObject {
    @Published var text = ""
    @Published var isTextValid = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $text
            .map { text in
                // 텍스트 길이가 6자 이상 30자 이하이고, 숫자와 영문자로만 구성되어 있는지 검사합니다.
                let regex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{6,30}$"
                let isMatchingRegex = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: text)
                return isMatchingRegex
            }
            .assign(to: \.isTextValid, on: self)
            .store(in: &cancellables)
    }
}
class PassFiledModel: ObservableObject {
    @Published var text = ""
    @Published var isTextValid = false
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $text
            .map { text in
                // 텍스트 길이가 8자 이상 30자 이하이고, 숫자, 영문자, 특수문자를 포함하는지 검사합니다.
                let regex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*])[A-Za-z\\d!@#$%^&*]{8,30}$"
                let isMatchingRegex = NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: text)
                return isMatchingRegex
            }
            .assign(to: \.isTextValid, on: self)
            .store(in: &cancellables)
    }
}
struct PassTextField: View{
    let title: String
    var placeholder: String
    @Binding var text: String
    @Binding var checktext: String
    var isNumberInput: Bool = false
    var validator: (String) -> Bool
    let limit: Int
    let FocusEnum: FocusableField
    @FocusState var focus: FocusableField?
    @State var inVisible: Bool = true
    @State private var visable = false
    @StateObject private var passFiledModel = PassFiledModel()
    @Binding var isChecked: Bool
    
    var body: some View{
        VStack(alignment: .leading, spacing: 5){
            Text(title)
                .font(.system(size: 15))
                    SecureField(placeholder, text: $passFiledModel.text)
                        .focused($focus, equals: FocusEnum)
                        .onReceive(Just(text)) {
                            text = String($0.prefix(limit))
                            if !isChecked {
                                return
                            }
                            if passFiledModel.text != checktext{
                                print("text : \(passFiledModel.text)")
                                print("Check pass Test false")
                                isChecked = false
                            }
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
                        .stroke(passFiledModel.isTextValid ? Color("ConceptColor") : Color.red, lineWidth: 2)
                )
                if !passFiledModel.isTextValid {
                    Text("8자 이상 30자리 이하의 숫자, 영문자, 특수문자를 포함한 조합으로 가능합니다.")
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                }
            if passFiledModel.isTextValid {
                Text("비밀번호 확인")
                    .font(.system(size: 15))
                HStack{
                    SecureField(placeholder, text: $checktext)
                        .focused($focus, equals: FocusEnum)
                        .onReceive(Just(checktext)) {
                            if checktext == passFiledModel.text{
                                print(passFiledModel.text)
                                print(checktext)
                                isChecked = true
                            }else {
                                isChecked = false
                            }
                            checktext = String($0.prefix(limit))
                        }
                        .autocapitalization(.none)
                        .padding(12)
                        .cornerRadius(10)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(checktext == passFiledModel.text ? Color("ConceptColor") : Color.red, lineWidth: 2)
                        )
                }
                    if checktext != passFiledModel.text {
                        Text("일치하지 않습니다.")
                            .font(.system(size: 13))
                            .foregroundColor(.red)
                    }
            }
        }
    }
}

struct SignUpTextField: View{
    let title: String
    var placeholder: String
    @Binding var text: String
    var isNumberInput: Bool = false
    var validator: (String) -> Bool
    let limit: Int
    let FocusEnum: FocusableField
    @FocusState var focus: FocusableField?
    @State var inVisible: Bool = true
    @State var isChecked: Bool = true
    @StateObject private var idFieldModel = IDFieldModel()
    @StateObject private var passFiledModel = PassFiledModel()
    @State var nextFiled: Bool = false
    var body: some View{
        VStack(alignment: .leading, spacing: 5){
            Text(title)
                .font(.system(size: 15))
                HStack{
                    TextField(placeholder, text: $text)
                        .focused($focus, equals: FocusEnum)
                        .keyboardType(isNumberInput ? .numberPad : .default)
                        .onReceive(Just(text)) {
                            print("onReceive \(nextFiled)")
                            text = String($0.prefix(limit))
                            if focus == .dobfiled && nextFiled{
                                if text.count == limit && nextFiled{
                                    moveToNextFocus()
                                }
                            }
                        }
                        .onTapGesture{
                            nextFiled = false
                            print("onTapGesture \(nextFiled)")
                        }
                        .autocapitalization(.none)
                        .padding(12)
                        .cornerRadius(10)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(validator($text.wrappedValue) ? Color("ConceptColor") : Color.red, lineWidth: 2)
                )
            }
        
        }

    private func moveToNextFocus(){
        switch FocusEnum{
        case .dobfiled:
            focus = .sexcodefiled
        default:
            break
        }
    }
}
struct MobileTextField: View{
    let title: String
    var placeholder: String
    @Binding var text: String
    var isNumberInput: Bool = false
    var validator: (String) -> Bool
    let limit: Int
    let FocusEnum: FocusableField
    @FocusState var focus: FocusableField?
    @State var inVisible: Bool = true
    @State var isChecked: Bool = true
    @StateObject private var idFieldModel = IDFieldModel()
    var body: some View{
        VStack(alignment: .leading, spacing: 5){
            Text(title)
                .font(.system(size: 15))
                HStack{
                    TextField(placeholder, text: $text)
                        .focused($focus, equals: FocusEnum)
                        .keyboardType(.numberPad)
                        .onReceive(Just(text)) {
                            text = String($0.prefix(limit))
                            
                        }
                        .autocapitalization(.none)
                        .padding(12)
                        .cornerRadius(10)
                }
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(validator($text.wrappedValue) ? Color("ConceptColor") : Color.red, lineWidth: 2)
                )
            }
        
        }
    private func moveToNextFocus(){
        switch FocusEnum{
        case .dobfiled:
            focus = .sexcodefiled
        default:
            break
        }
    }
}
enum IDCheckState {
    case notChecked
    case valid
    case duplicated
}
struct IdTextField: View{
    @State private var idCheckState: IDCheckState = .notChecked
    let title: String
    var placeholder: String
    @Binding var text: String
    var isNumberInput: Bool = false
    var validator: (String) -> Bool
    let limit: Int
    let FocusEnum: FocusableField
    @FocusState var focus: FocusableField?
    @State var inVisible: Bool = true
    @StateObject private var idFieldModel = IDFieldModel()
    @Binding var isChecked: Bool
    var body: some View{
        VStack(alignment: .leading, spacing: 5){
            Text(title)
                .font(.system(size: 15))
            HStack{
                TextField(placeholder, text: $idFieldModel.text)
                    .focused($focus, equals: FocusEnum)
                    .onReceive(Just(text)) {
                        text = String($0.prefix(limit))
//                        test = idFieldModel.isTextValid
                    }
                    .autocapitalization(.none)
                    .padding(12)
                    .cornerRadius(10)
                
                    .onTapGesture {
                        isChecked = false
                    }
                if idFieldModel.isTextValid {
                    if !isChecked{
                        Text("중복확인")
                            .font(.system(size: 15))
                            .foregroundColor(Color("ConceptColor"))
                            .padding(.trailing, 10)
                            .onTapGesture(){
                                requestIdCheck(CheckId: idFieldModel.text){ isSuccess in
                                    if isSuccess{
                                        print("유효성검사 통과")
                                        text = idFieldModel.text
                                        idCheckState = .valid
                                        isChecked = true
                                        focus = nil
                                        print(isChecked)
                                    }else{
                                        idCheckState = .duplicated
                                        print("유효성검사 실패")
                                    }
                                }
                            }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(idFieldModel.isTextValid && isChecked ? Color("ConceptColor") : Color.red, lineWidth: 2)
            )
            if !idFieldModel.isTextValid{
                Text("6자 이상 30자리 이하의 숫자, 영문자 조합으로 가능합니다.")
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }else{
                Text(statusText)
                    .font(.system(size: 13))
                    .foregroundColor(statusTextColor)
            }
        }
    }
    private var statusText: String {
            switch idCheckState {
            case .notChecked:
                return "중복확인을 완료해주세요"
            case .valid:
                return "사용가능한 아이디 입니다."
            case .duplicated:
                return "중복된 아이디가 있습니다."
            }
        }
    private func moveToNextFocus(){
        switch FocusEnum{
        case .dobfiled:
            focus = .sexcodefiled
        default:
            break
        }
    }
    private var statusTextColor: Color {
            switch idCheckState {
            case .notChecked, .duplicated:
                return .red
            case .valid:
                return .blue
            }
        }
}

enum FocusableField: Hashable {
    case accountfiled
    case passwordfiled
    case passcheckfiled
    case mobilefiled
    case namefiled
    case dobfiled
    case sexcodefiled
    
}
struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State var birthday = ""
    @State var sex = ""
    @State var message = ""
    @State var phoneNumber = ""
    @State var name = ""
    @State var id = ""
    @State var password = ""
    @State var Checkpassword = ""
    
    //    뷰 유동적으로 보이게 하는 불리언값들
    @State private var dobView = false
    @State private var mobileView = false
    @State private var nameView = false
    @State private var idView = false
    @State private var passwordView = false
    
    //    아이디 중복확인 했는지 안했는지 불리언, 휴대폰 인증 불리언
    @State private var idCheck = false
    @State private var smsCheck = false
    @State private var passCheck = false
    
    @State private var smsCheckNum = "123456"
    @FocusState private var focus: FocusableField?
    
    private var isFormValid: Bool{
        switch focus {
        case .mobilefiled:
            if phoneNumber.count == 11 {
                return true
            }else {
                return false
            }
        case .dobfiled:
            if birthday.count == 6 && sex.count == 1{
                return true
            }else{
                return false
            }
        case .sexcodefiled:
            if birthday.count == 6 && sex.count == 1{
                return true
            }else{
                return false
            }
        case .namefiled:
            if name.count < 1{
                return false
            }else{
                return true
            }
        case .accountfiled:
            return idCheck
        case .passwordfiled:
            return passCheck
        default:
            return true
        }
    }
    @State private var LinkActive = false
    var body: some View {
        // 전체 배경색과 안전 영역 무시 설정
        //        NavigationStack{
        ZStack {
            // ScrollView와 하단 버튼을 포함하는 VStack
            VStack {
                ScrollView {
                    // 입력 필드를 담고 있는 VStack
                    VStack(spacing: 16) {
                        if mobileView{
                            SignUpTextField(title: "휴대폰", placeholder: "휴대폰 번호", text: $phoneNumber, isNumberInput: true, validator: {$0.count == 11},limit: 11,FocusEnum: .mobilefiled, focus: _focus)
                        }
                        if dobView{
                            HStack{
                                SignUpTextField(title: "주민등록번호", placeholder: "주민번호 앞자리", text: $birthday, isNumberInput: true, validator: { $0.count == 6 },limit: 6, FocusEnum: .dobfiled, focus: _focus)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 30)
                                Text("-")
                                    .padding(.top)
                                SignUpTextField(title: "", placeholder: "1", text: $sex, isNumberInput: true, validator: { $0.count == 1 },limit: 1, FocusEnum: .sexcodefiled,focus: _focus)
                                    .frame(width: 40)
                                Text("● ● ● ● ● ●")
                                    .padding(.top)
                            }
                        }
                        if nameView{
                            SignUpTextField(title: "이름", placeholder: "이름", text: $name, isNumberInput: false, validator: {$0.count > 0},limit: 11, FocusEnum: .namefiled,focus: _focus)
                        }
                        if passwordView{
                            PassTextField(title: "비밀번호", placeholder: "비밀번호", text: $password,checktext: $Checkpassword, isNumberInput: false, validator: {$0.count >= 8},limit: 30,FocusEnum: .passwordfiled,focus: _focus, isChecked: $passCheck)
                        }
                        IdTextField(title: "아이디", placeholder: "아이디", text: $id, isNumberInput: false, validator: {$0.count >= 6},limit: 30, FocusEnum: .accountfiled,focus: _focus, isChecked: $idCheck)
                    }
                    .padding()
                }
                .onAppear(){
                    focus = .accountfiled
                }
                HStack {
                    if CheckList {
                        NavigationLink(destination: SingleOTPView(account:$id,password: $Checkpassword,name: $name, dob: $birthday,sex_code: $sex, smsCheck: $smsCheck,smsCheckInt: $smsCheckNum, mobileNum: $phoneNumber)){
                            Spacer()
                            Text("확인")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                        }
                    }else {
                        Spacer()
                        Text("확인")
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                    }
                }
                .background(isFormValid ? Color("ConceptColor") : Color.gray)
                .contentShape(Rectangle())
                .onTapGesture {
                    print("isFormValid : \(isFormValid)")
                    print("CheckList : \(CheckList)")
                    print("idCheck : \(idCheck)")
                    print("passCheck : \(passCheck)")
                    print("name Count : \(name.count < 1)")
                    print("dob count : \(birthday.count != 6 && sex.count != 1)")
                    print("phoneNumber count : \(phoneNumber.count != 11)")
                    validateAndFocus()
                }
            }
            .navigationTitle("회원가입")
            
        }
    }
    
//    nameView passwordView dobView mobileView
    private func validateAndFocus() {
        if !idCheck {
            print("accountfiled")
            focus = .accountfiled
            return
        }
        
        if !passCheck {
            print("passwordfiled")
            passwordView = true
            return
        }
        
        if name.count < 1 {
            nameView = true
            DispatchQueue.main.async{
                self.focus = .namefiled
            }
            return
        }
        
        if birthday.count != 6 && sex.count != 1 {
            dobView = true
            DispatchQueue.main.async{
                self.focus = .dobfiled
            }
            return
        }
        
        if phoneNumber.count != 11 {
            mobileView = true
            DispatchQueue.main.async{
                self.focus = .mobilefiled
            }
            return
        } else {
            LinkActive = true
        }
    }
    private var CheckList: Bool{
        if !idCheck{
            return false
        }
        if !passCheck{
            return false
        }
        if name.count < 1 {
            return false
        }
        if birthday.count != 6 && sex.count != 1{
            return false
        }
        if phoneNumber.count != 11 {
            return false
        }
        else{
            return true
        }
    }
    private var goToNextLink: Bool{
        switch focus {
        case .mobilefiled:
            if phoneNumber.count == 11 {
                return true
            }else {
                return false
            }
//            return smsCheck
        case .dobfiled:
            if birthday.count == 6 && sex.count == 1{
                return true
            }else{
                return false
            }
        case .sexcodefiled:
            if birthday.count == 6 && sex.count == 1{
                return true
            }else{
                return false
            }
        case .namefiled:
            if name.count < 1{
                return false
            }else{
                return true
            }
        case .accountfiled:
            return idCheck
        case .passwordfiled:
            return passCheck
        default:
            return true
        }
    }
}


private func handleAction() {
    print("Button Click")
}


#Preview {
    SignUpView()
}


