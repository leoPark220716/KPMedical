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
struct Hospitals: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var hospital_id: Int
    var hospital_name: String
    var icon: String  // JSON에서 "icon" 필드와 일치
    var location: String
    var department_id: [Int]
    var start_time: String  // "start_time"으로 수정
    var end_time: String  // "end_time"으로 수정

    // JSON의 키와 Swift 프로퍼티 이름 매핑
    enum CodingKeys: String, CodingKey {
        case hospital_id, hospital_name, icon, location, department_id, start_time, end_time
    }
}
class HospitalHTTPRequest {
    typealias HospitalListCompletion = (Result<[Hospitals], Error>) -> Void
    func CallHospitalList(completion: @escaping HospitalListCompletion) {
        print("Call Hospital List")
        if let url = URL (string: "https://kp-medicals.com/api/medical-wallet/hospitals"){
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
                    let json = try decoder.decode(KPApiStructFromGetArray<Hospitals>.self, from: data)
                    DispatchQueue.main.sync{
                        completion(.success(json.data))
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
}
