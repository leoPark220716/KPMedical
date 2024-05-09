//
//  HospitalRequest.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

// Define the structure for each hospital
// Codable : 구조체를 Josn decode encode 를 원할하게 해주는 형태로 만들어줌
// Indetifiable 각각의 고유 id 가 필요한 Swift 프로토콜
// Equatable : 해당 구조체로 만들어진 객체가 같은지 비교할 수 있게 하는 기능을 달아줌
struct HospitalDataManager{
    struct Hospitals: Codable, Identifiable, Equatable {
        var id: UUID = UUID()
        var hospital_id: Int
        var hospital_name: String
        var icon: String  // JSON에서 "icon" 필드와 일치
        var location: String
        var department_id: [String]
        var start_time: String  // "start_time"으로 수정
        var end_time: String  // "end_time"으로 수정
        
        // JSON의 키와 Swift 프로퍼티 이름 매핑
        enum CodingKeys: String, CodingKey {
            case hospital_id, hospital_name, icon, location, department_id, start_time, end_time
        }
    }
    
    struct Hospital_Data: Codable {
        let hospitals: [Hospitals]
    }
    
    struct HospitalDataClass: Codable {
        let hospital: Hospital_Detail
        let doctors: [Doctor]
        let error_code :Int
        let error_stack :String
        init() {
            self.hospital = Hospital_Detail() // 여기서 '...'은 Hospital_Detail의 기본값을 나타냄
            self.doctors = [] // 빈 배열 또는 기본 의사 목록
            self.error_code = 0 // 기본 오류 코드 값
            self.error_stack = "" // 기본 오류 스택 값
        }
    }
    struct Hospital_Detail: Codable {
        var hospital_id: Int
        var hospital_name: String
        var location: String
        var x: Double
        var y: Double
        var phone: String
        var department_id: [String]
        var marked: Int
        init(hospital_id: Int = 0,
             hospital_name: String = "",
             location: String = "",
             x: Double = 0.0,
             y: Double = 0.0,
             department_id: [String] = [],
             marked: Int = 0) {
            self.hospital_id = hospital_id
            self.hospital_name = hospital_name
            self.location = location
            self.x = x
            self.y = y
            self.phone = ""
            self.department_id = department_id
            self.marked = marked
        }
    }
    struct Doctor: Codable{
        var staff_id: Int
        var name: String
        var icon: String
        var department_id: [String]
        var main_schedules: [Schedule]
        var sub_schedules: [Schedule]
    }
    struct Schedule: Codable {
        let scheduleId: Int
        let hospitalId: Int
        let staffId: Int
        let startDate: String?
        let endDate: String?
        let date: String?
        let startTime1: String
        let endTime1: String
        let startTime2: String
        let endTime2: String
        let timeSlot: String
        let maxReservation: Int
        let dayoff: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case scheduleId = "schedule_id"
            case hospitalId = "hospital_id"
            case staffId = "staff_id"
            case startDate = "start_date"
            case endDate = "end_date"
            case date
            case startTime1 = "start_time1"
            case endTime1 = "end_time1"
            case startTime2 = "start_time2"
            case endTime2 = "end_time2"
            case timeSlot = "time_slot"
            case maxReservation = "max_reservation"
            case dayoff, name
        }
    }
    struct RequestReservations: Codable{
        var access_token: String
        var reservations: [Reservation]
        var error_code: Int
        var error_stack: String
    }
    struct Reservation: Codable {
        var reservation_id: Int
        var hospital_id: Int
        var staff_id: Int
        var date: String
        var time: String
    }
    struct reservationResponse: Codable{
        var access_token: String
        var reservation_id: Int
        var error_code: Int
        var error_stack: String
    }
    struct reservationRequest: Codable{
        var access_token: String
        var uid: String
        var hospital_id: Int
        var staff_id: Int
        var date: String
        var time: String
        var purpose: String
        var time_slot: String
    }
}
class HospitalDataManagerClass {
    //    var hospitalData: HospitalDataManager.HospitalData?
    //
    //    func updateHospitalData(with data: HospitalDataManager.HospitalData) {
    //        self.hospitalData = data
    //    }
    //
    //    func clearHospitalData() {
    //        self.hospitalData = nil
    //    }
}

class HospitalHTTPRequest {
    typealias HospitalListCompletion = (Result<[HospitalDataManager.Hospitals], Error>) -> Void
    func CallHospitalList(orderBy: String, x: String, y:String, keyword:String,department_id:String,completion: @escaping HospitalListCompletion) {
        var urlString = "https://kp-medicals.com/api/medical-wallet/hospitals"
        func appendParameter(key: String, value: String) {
            // URL에 '?'가 없으면 추가하고, 이미 있으면 '&'를 추가
            if !urlString.contains("?") {
                urlString.append("?")
            } else if !urlString.hasSuffix("&") && !urlString.hasSuffix("?") {
                urlString.append("&")
            }
            // 파라미터 추가
            urlString.append("\(key)=\(value)")
        }
        if orderBy != "" {
            appendParameter(key: "orderBy", value: orderBy)
        }
        if x != "" {
            appendParameter(key: "x", value: x)
            appendParameter(key: "y", value: y)
        }
        if keyword != "" {
            appendParameter(key: "keyword", value: keyword)
        }
        if department_id != "" {
            appendParameter(key: "department_id", value: department_id)
        }
        // 마지막 문자가 '&'라면 제거
        if urlString.hasSuffix("&") {
            urlString.removeLast()
        }
        print(urlString)
        print("Call Hospital List")
        if let url = URL (string: urlString){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request){ data, res , er in
                if let er = er {
                    print("Call HospitalList err : \(er)")
                    DispatchQueue.main.async{
                        completion(.failure(er))
                    }
                    return
                }
                guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else{
                    let responseError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                    DispatchQueue.main.async {
                        completion(.failure(responseError))
                    }
                    return
                }
                guard let data = data else{
                    let dataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    DispatchQueue.main.async {
                        completion(.failure(dataError))
                    }
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(KPApiStructFrom<HospitalDataManager.Hospital_Data>.self, from: data)
                    DispatchQueue.main.sync{
                        print("Call Hospital List")
                        completion(.success(json.data.hospitals))
                    }
                } catch {
                    print("JSON Error: \(error)")
                }
            }.resume()
        }else{
            let urlError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            DispatchQueue.main.async {
                completion(.failure(urlError))
            }
        }
    }
    func HospitalDetailHTTPRequest(hospitalId:Int,token:String,uuid:String, httpHandler: @escaping (HospitalDataManager.HospitalDataClass )-> Void) {
        print("Call Hospital Detail")
        let urlString = "https://kp-medicals.com/api/medical-wallet/hospitals/detail?access_token=\(token)&uid=\(uuid)&hospital_id=\(hospitalId)"
        print(urlString)
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request) { data, res, er in
                if let er = er {
                    print("err : \(er) ")
                    return
                }
                guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                    print("res err \(String(describing: res))")
                    return
                }
                guard let data = data else{
                    let dataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    print("\(dataError)")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(KPApiStructFrom<HospitalDataManager.HospitalDataClass>.self, from: data)
                    httpHandler(json.data)
                }catch{
                    print("Json Errro Hsdata \(error)")
                }
            }.resume()
        }else{
            let urlError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("ErrUrl\(urlError)")
        }
    }
    func appendParameter(urlString: String,key: String, value: String) -> String {
        var url = urlString
        // URL에 '?'가 없으면 추가하고, 이미 있으면 '&'를 추가
        if !url.contains("?") {
            url.append("?")
        } else if !url.hasSuffix("&") && !url.hasSuffix("?") {
            url.append("&")
        }
        // 파라미터 추가
        url.append("\(key)=\(value)")
        return url
    }
    func GetReservations(token: String, uid:String, date:String, staff_id: String, httpHandler: @escaping ([HospitalDataManager.Reservation]) -> Void){
        let urlString = "https://kp-medicals.com/api/medical-wallet/hospitals/reservations/list/doctor?access_token=\(token)&uid=\(uid)&date=\(date)&staff_id=\(staff_id)"
        print(urlString)
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request){ data, res, er in
                if let er = er {
                    print("err : \(er) ")
                    return
                }
                guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                    print("res err \(String(describing: res))")
                    return
                }
                guard let data = data else{
                    let dataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    print("\(dataError)")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(KPApiStructFrom<HospitalDataManager.RequestReservations>.self, from: data)
                    httpHandler(json.data.reservations)
                }catch {
                    print("JsonErr \(error)")
                }
            }.resume()
        }else{
            let urlError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("ErrUrl\(urlError)")
        }
    }
    
    func SaveReservation(token:String, uid:String, hospital_id: Int, staff_id:Int,date:String,time:String,purpose:String,time_slot:String, HttpHandler: @escaping (Bool) -> Void){
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/hospitals/reservations"){
            let PostData: HospitalDataManager.reservationRequest = .init(access_token: token, uid: uid, hospital_id: hospital_id, staff_id: staff_id, date: date, time: time, purpose: purpose, time_slot: time_slot)
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let requestData = try? JSONEncoder().encode(PostData){
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
                    HttpHandler(false)
                    return
                }
                guard let data = data else{
                    print("er http request failed\(String(describing: res))")
                    HttpHandler(false)
                    return
                }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(KPApiStructFrom<HospitalDataManager.reservationResponse>.self, from: data){
                    if json.success == "success"{
                        print(json.data)
                        HttpHandler(true)
                    }else{
                        print(json.data)
                        HttpHandler(false)
                    }
                }
            }.resume()
        }
    }
    func LikeHospital(token : String,hospital_id: Int) async -> Bool{
        let BodyData = PostBody.init(access_token: token, uid: getDeviceUUID(), hospital_id: hospital_id)
        let httpStruct = http<PostBody?, KPApiStructFrom<ResponseBody>>.init(
            method: "POST",
            urlParse: "users/marks",
            token: token ,
            UUID: getDeviceUUID(),
            requestVal: BodyData
        )
        
        let result = await KPWalletApi(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            let marked = (result.data?.data.mark_id ?? -1) != -1 ? true : false
            return marked
        }else{
            print(result.data?.message ?? "Option Null")
            return false
        }
        
        struct PostBody: Codable{
            var access_token: String
            var uid: String
            var hospital_id: Int
        }
        struct ResponseBody: Codable{
            var access_token: String
            var mark_id: Int
            var error_code: Int
            var error_stack: String
        }
    }
}


class TabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
}
