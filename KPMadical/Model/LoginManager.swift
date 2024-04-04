//
//  LoginManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import Foundation


class LoginManager: ObservableObject{
    @Published var LoginStatus: Bool
    
    init(LoginStatus: Bool) {
        self.LoginStatus = LoginStatus
    }
    
}
//회원가입 테스트 구조체
struct SingupRequestModul: Codable {
    let account: String
    let password: String
    let mobile: String
    let name: String
    let dob: String
    let sex_code: String
}
struct LoginModul: Codable {
    let account: String
    let password: String
    let uid: String
}
// 자동로그인 파싱값
struct AutoLoginModel: Codable {
    let access_token: String
    let name: String
    let dob: String
    let sex_code: String
    let isHospitalRegistered: String?
    let staffData: String?
    let error_code: Int?
    let error_stack: String?
}
struct SingupRequest: Codable {
    let status: Int
    let success: String
    let message: String
    let data: Int
}
struct loginResponse: Codable {
    let access_token: String
    let name: String
    let dob:String
    let sex_code: String
}
struct IDCheckResponse: Codable {
    let account: String
}
struct MobileResponse: Codable {
    let verify_token: String
}
struct MobileCheckResponse: Codable {
    let mobile: String
    let service_id: Int
    let iat: Int
    let exp: Int
}
// 'data' 배열 내 각 항목을 나타내는 구조체
struct DataItem: Codable {
    let id: Int
    let title: String
    let content: String
    let insertTime: String
    let additionalField: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, content, additionalField
        case insertTime = "insert_time" // JSON 키와 Swift 프로퍼티 이름이 다른 경우
    }
}


struct Response: Codable {
    let success: Bool
    let result: String
    let message: String
}
// 디바이스 고유 넘버

// SigunUpView 에서 사용되고 있음
// f 부분이 생소할 수 있는데 f 부분은 클로저를 말함.
// 비동기 요청의 결과가 성공적이었는지 여부에 따라 true 또는 false 를 반환함.
// 여기서 사용된 @escaping 속성은 해당 클로저가 함수 실행이 끝난 뒤에도 호출될 수 있음을 의미함.
//클로저란 이름없는 함수라고 생각 하면서 보면 될듯 그래도 이해하기 좀 어려움 처음에
func requestIdCheck(CheckId: String, f: @escaping (Bool) -> Void) {
    print("request ID Check")
//    URL 구성
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/users/\(CheckId)/check"){
        print(url)
//        생성된 URL 로 URLRequest 객채를 생성하고
        var request = URLRequest(url: url)
//        메서드를 GET으로 설정함
        request.httpMethod = "GET"
//        shared = URLSession 을 여는 명령
//        dataTask  비동기적으로 웹 요청을 수행하는 함수 여기서 클로저가 사용됨 해당 클로저는 data res er 세가지 매개 변수를 가지고 있다.
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
//            guard 에 대한 설명 :
//            guard 는 Swift 에서 조건을 검사하는 데 사용됨 보통 guard 조건 else {처리} 형식임
//            조건이 true 일때 다음 코드로 넘어가고 아니면 else 가 실행되는거
//            밑에 코드로 예를 들면 res 가 HTTPURLResponse 타입으로 반환되고 값이 200 ~ 299 값이라면 넘어간다는 말임 그이외는 else 문을 탄다는거임
//            as 에 대한 설명 : 타입 케스팅 검사를 하는거임 변수의 타입에 들어갈 수 있는지 확인한다고 생각하면 됨 res 가 HTTPURLResponse 타입이 맞는지 아닌지 검사하는거
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed")
                f(false)
                return
            }
            guard let data = data else{
                f(false)
                return
            }
            guard let json = try? JSONDecoder().decode(KPApiStructFrom<IDCheckResponse>.self, from: data) else{
                print("JSON error")
                return
            }
            print("중복확인 테스트 status : \(json.status)")
            if json.status == 200{
                f(true)
            }else{
                f(false)
            }
        }.resume()
    }
}
// 인증번호 확인 메서드
func requestMoblieCheck(mobile: String, completionHandrler: @escaping (Bool, String) -> Void) {
    print("request ID Check")
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/mobile?mobile=\(mobile)"){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed")
                completionHandrler(false,"false")
                return
            }
            guard let data = data else{
                completionHandrler(false,"false")
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode( KPApiStructFrom<MobileResponse>.self, from: data) {
                completionHandrler(true,json.data.verify_token)
            }
        }.resume()
    }
}

func requestSmsCheck(mobile: String,Token: String, CheckNum: String, completionHandrler: @escaping (Bool, Int) -> Void) {
    print("request ID Check")
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/mobile/check?mobile=\(mobile)&mobile_code=\(CheckNum)&verify_token=\(Token)"){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed")
                completionHandrler(false,1)
                return
            }
            guard let data = data else{
                completionHandrler(false,1)
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode( KPApiStructFrom<MobileCheckResponse>.self, from: data) {
                completionHandrler(true,json.status)
            }
        }.resume()
    }
}

struct singupResponse: Codable{
    let account: String
}
func POSTrequsetTest(account: String, password: String, moblie: String, name: String, dob: String, sex_code: String){
    print("POST TEST")
    if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/users"){
        let DataModule: SingupRequestModul = .init(account: account, password: password, mobile: moblie, name: name, dob: dob, sex_code: sex_code)
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let requestData = try? JSONEncoder().encode(DataModule){
            request.httpBody = requestData
            if let JsonString = String(data: requestData, encoding: .utf8){
                print(JsonString)
            }
        }
        URLSession.shared.dataTask(with: request){ (data, res, er) in
            guard let data = data else { return }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else
            { print("err http request failed \(String(describing: res))")
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode( KPApiStructFrom<singupResponse>.self, from: data) {
                if json.success == "success" {
                    
                }
            }
            
        }.resume()
    }
}
func requestSignUp(account: String, password: String, moblie: String, name: String, dob: String, sex_code: String, completionHandrler: @escaping (Bool, String) -> Void) {
    print("requestSignUp")
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/users"){
        let DataModule: SingupRequestModul = .init(account: account, password: password, mobile: moblie, name: name, dob: dob, sex_code: sex_code)
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let requestData = try? JSONEncoder().encode(DataModule){
            request.httpBody = requestData
            if let JsonString = String(data: requestData, encoding: .utf8){
                print(JsonString)
            }
        }
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed\(String(describing: res))")
                completionHandrler(false,"1")
                return
            }
            guard let data = data else{
                print("er http request failed\(String(describing: res))")
                completionHandrler(false,"1")
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(SingupRequest.self, from: data) {
                print(json.data)
                print(json.message)
                print(json.success)
                if json.success == "success" {
                    print(json.data)
                    completionHandrler(true,"true")
                }else{
                    completionHandrler(false,"false")
                }
            }
        }.resume()
    }
}
func requestLogin(account: String,password: String, uid: String,userstate:UserObservaleObject, completionHandrler: @escaping (Bool, String) -> Void) {
    print("request ID Check")
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/users/access"){
        let logmodul: LoginModul = .init(account: account, password: password, uid: uid)
        var request = URLRequest.init(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let requestData = try? JSONEncoder().encode(logmodul){
            request.httpBody = requestData
            if let JsonString = String(data: requestData, encoding: .utf8){
                print(JsonString)
            }
        }
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed\(String(describing: res))")
                completionHandrler(false,"1")
                return
            }
            guard let data = data else{
                completionHandrler(false,"1")
                return
            }
            guard let decoder = try? JSONDecoder().decode(KPApiStructFrom<loginResponse>.self, from: data) else {
                completionHandrler(false,"false")
                return
            }
            if decoder.status != 201 {
                completionHandrler(false,"false")
            }else{
                userstate.SetData(name: decoder.data.name, dob: decoder.data.dob, sex: decoder.data.sex_code, token: decoder.data.access_token)
                print(userstate.name)
                completionHandrler(true,decoder.data.access_token)
            }
        }.resume()
    }
}
class LoginTockenFunc {
    
    func CheckToken(token: String, uid: String, completionHandrler: @escaping (Bool,Bool,String) -> Void) {
        if token != ""{
            print("Call Cehck Tokens")
            print(uid)
            if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/users/access/auto?access_token=\(token)&uid=\(uid)"){
                print("url:\(url)")
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                URLSession.shared.dataTask(with: request){data,res,er in
                    if let er = er {
                        print("err : \(er)")
                        completionHandrler(false, false ,"")
                        return
                    }
                    guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else{
                        print("er http request failed \(String(describing: res))")
                        completionHandrler(false, false ,"")
                        return
                    }
                    guard let data = data else{
                        completionHandrler(false, false ,"")
                        return
                    }
                    guard let decoder = try? JSONDecoder().decode(KPApiStructFrom<AutoLoginModel>.self, from: data) else {
                        print("Json pashing failed")
                        completionHandrler(false, false ,"")
                        return
                    }
                    if decoder.status == 200 {
                        if token == decoder.data.access_token{
                            completionHandrler(true, true, "")
                        }else{
                            completionHandrler(true, false, decoder.data.access_token)
                        }
                    }else{
                        completionHandrler(false, false ,"")
                    }
                }.resume()
            }
        }else{
            print("token = null")
        }
    }
    
}

func requesxtSmsCheck(mobile: String,Token: String, CheckNum: String, completionHandrler: @escaping (Bool, Int) -> Void) {
    print("request ID Check")
    if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/mobile/check?mobile=\(mobile)&mobile_code=\(CheckNum)&verify_token=\(Token)"){
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) {data, res, er in
            if let er = er {
                print("err :\(er)")
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("er http request failed")
                completionHandrler(false,1)
                return
            }
            guard let data = data else{
                completionHandrler(false,1)
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode( KPApiStructFrom<MobileCheckResponse>.self, from: data) {
                completionHandrler(true,json.status)
            }
        }.resume()
    }
}
