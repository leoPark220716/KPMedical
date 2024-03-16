//
//  LoginManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import Foundation
import UIKit

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
struct TestResponse<T: Codable>: Codable {
    let status: Int
    let success: String
    let message: String
    let data: [T]
}
struct KPApiStructFrom<T: Codable>: Codable {
    let status: Int
    let success: String
    let message: String
    let data: T
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
func requestTestCheck(completionHandler: @escaping (Bool) -> Void) {
    print("GetSTSTS")
    if let url = URL(string: "https://kp-medicals.com/api/test/select") {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, res, er in
            guard let data = data else {
                completionHandler(false)
                return
            }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                print("err http request failed")
                completionHandler(false)
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(TestResponse<DataItem>.self, from: data) {
                print("유효성 검사 응답 값 " + json.success)
                if json.success == "success"{
                    completionHandler(true)
                }else{
                    completionHandler(false)
                }
            } else {
                completionHandler(false)
            }
        }.resume()
    } else {
        completionHandler(false) // URL 생성에 실패한 경우
    }
}
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
//            guard let json = try? JSONDecoder().decode(KPApiStructFrom<MobileResponse>.self, from: data) else{
//                print("JSON error")
//                return
//            }
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
func requsetTest(){
    print("GetSTSTS")
    if let url = URL(string: "https://kp-medicals.com/api/test/select"){
        var request = URLRequest.init(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request){ (data, res, er) in
            guard let data = data else { return }
            guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else
            { print("err http request failed")
                return
            }
            let decoder = JSONDecoder()
            if let json = try? decoder.decode(TestResponse<DataItem>.self, from: data) {
                print(json.success)
                
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
func requestLogin(account: String,password: String, uid: String, completionHandrler: @escaping (Bool, String) -> Void) {
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
                print("er http request failed")
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
                completionHandrler(true,decoder.data.access_token)
                
            }
        }.resume()
    }
}
func requestGet(url: String, completionHandler: @escaping (Bool, Any) -> Void) {
    print("Call Get")
    guard let url = URL(string: url) else {
        print("Error: cannot create URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    print("request \(url)")
    URLSession.shared.dataTask(with: request) { data, response, error in
        print("Create URL Session")
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        guard let output = try? JSONDecoder().decode(TestResponse<DataItem>.self, from: data) else {
            print("Error: GET JSON Data Parsing failed")
            return
        }
        print("Create out Session")
//        let responseString = String(data: data, encoding: .utf8)
//        completionHandler(true, responseString!)
        completionHandler(true, output.success)
    }.resume()
}

func requestPost(url: String, method: String, param: [String: Any], completionHandler: @escaping (Bool, Any) -> Void) {
    let sendData = try! JSONSerialization.data(withJSONObject: param, options: [])
    
    guard let url = URL(string: url) else {
        print("Error: cannot create URL")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = sendData
    
    URLSession.shared.dataTask(with: request) { (data, response, error) in
        guard error == nil else {
            print("Error: error calling GET")
            print(error!)
            return
        }
        guard let data = data else {
            print("Error: Did not receive data")
            return
        }
        guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
            print("Error: HTTP request failed")
            return
        }
        guard let output = try? JSONDecoder().decode(Response.self, from: data) else {
            print("Error: JSON Data Parsing failed")
            return
        }
        
        completionHandler(true, output.result)
    }.resume()
}

func request(_ url: String, _ method: String, _ param: [String: Any]? = nil, completionHandler: @escaping (Bool, Any) -> Void) {
    if method == "GET" {
        requestGet(url: url) { (success, data) in
            completionHandler(success, data)
        }
    }
    else {
        requestPost(url: url, method: method, param: param!) { (success, data) in
            completionHandler(success, data)
        }
    }
}
