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
    // 최상위 응답 구조체
    //data  안 필드가 배열이 아닐때
    //KPApiStructFrom
    //data  안 필드가 배열일 때
    // 'data' 필드의 구조체
    struct HospitalDetailsData: Codable {
        var hospital: HospitalDetail
        var doctors: [DoctorDetail]
        var error_code: Int
        var error_stack: String
    }

    // 병원에 대한 구조체
    struct HospitalDetail: Codable {
        var hospital_id: Int
        var hospital_name: String
        var location: String
        var x: Double
        var y: Double
        var department_id: [String]
        var img_url: [String]
    }

    // 의사에 대한 구조체
    struct DoctorDetail: Codable {
        var staff_id: Int
        var name: String
        var icon: String
        var department_id: [String]
        var main_schedules: [ScheduleDetail]
        var sub_schedules: [ScheduleDetail]
    }

    // 일정에 대한 구조체
    struct ScheduleDetail: Codable {
        var schedule_id: Int
        var hospital_id: Int
        var staff_id: Int
        var start_date: String?
        var end_date: String?
        var start_time1: String
        var end_time1: String
        var start_time2: String?
        var end_time2: String?
        var date: String?
        var time_slot: String
        var max_reservation: Int
        var dayoff: String
        var name: String
    }

    struct Hospital_Data: Codable {
        let hospitals: [Hospitals]
    }
    struct Response_Data: Codable {
        let status: Int
        let success: String
        let message: String
        let data: HospitalData
    }

    
    struct HospitalData: Codable {
        let hospital: Hospital
        let doctors: [Doctor]
        let error_code: Int
        let error_stack: String
        
    }

    struct Hospital: Codable {
        let hospital_id: Int
        let hospital_name: String
        let location: String
        let x: Double
        let y: Double
        let department_id: [String]
        let img_url: [String]
    }

    struct Doctor: Codable {
        let staff_id: Int
        let name: String
        let icon: String
        let department_id: [String]
        let main_schedules: [Schedule]
        let sub_schedules: [Schedule]
    }

    struct Schedule: Codable {
        let schedule_id: Int
        let hospital_id: Int
        let staff_id: Int
        let start_date: String?
        let end_date: String?
        let start_time1: String
        let end_time1: String
        let start_time2: String?
        let end_time2: String?
        let date: String?
        let time_slot: String
        let max_reservation: Int
        let dayoff: String
        let name: String
    }
}
class HospitalDataManagerClass {
    var hospitalData: HospitalDataManager.HospitalData?

    func updateHospitalData(with data: HospitalDataManager.HospitalData) {
        self.hospitalData = data
    }

    func clearHospitalData() {
        self.hospitalData = nil
    }
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
    func HospitalDetailHTTPRequest(hospitalId:String, httpHandler: @escaping (HospitalDataManager.HospitalData )-> Void) {
        print("Call Hospital Detail")
        print("https://kp-medicals.com/api/medical-wallet/hospitals/detail?hospital_id=\(hospitalId)")
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/hospitals/detail?hospital_id=\(hospitalId)") {
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
                    let json = try decoder.decode(HospitalDataManager.Response_Data.self, from: data)
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
}


class TabViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
}
