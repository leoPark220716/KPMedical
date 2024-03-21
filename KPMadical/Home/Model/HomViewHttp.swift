//
//  HomViewHttp.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import Foundation

class HomviewHttp {
    func requestHomViewItems(token: String, completionHandler: @escaping (String, String, String) -> Void) {
        let defaultImage = "https://example.com/default-image.png"  // 기본 이미지 URL
        let urlString = "https://kp-medicals.com/api/medical-wallet/recommend?access_token=\(token)&uid=\(getDeviceUUID())"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error during URLSession: \(error)")
                completionHandler(defaultImage, defaultImage, defaultImage)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completionHandler(defaultImage, defaultImage, defaultImage)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let jsonResponse = try decoder.decode(HomViewResponse.self, from: data)
                
                let icons = jsonResponse.data.recommendHospitals.map { $0.icon }
                let iconUrls = icons + Array(repeating: defaultImage, count: max(0, 3 - icons.count))  // 항상 3개의 URL을 유지
                print("Succecsed")
                completionHandler(iconUrls[0], iconUrls[1], iconUrls[2])
            } catch {
                print("Failed to decode JSON: \(error)")
                completionHandler(defaultImage, defaultImage, defaultImage)
            }
        }.resume()
    }

}

struct HomViewDataParse: Codable{
    var access_token: String
    var hadConsultation: Bool
    var recommendHospitals: [Hospital_Icon]
    enum CodingKeys: String, CodingKey {
           case access_token, hadConsultation, recommendHospitals
       }
}
struct Hospital_Icon: Codable {
    var hospital_id: Int
    var icon: String
}
// 최상위 응답 구조체
struct HomViewResponse: Codable {
    var status: Int
    var success: String
    var message: String
    var data: HomView_Data
}

// 'data' 필드의 구조체
struct HomView_Data: Codable {
    var access_token: String
    var hadConsultation: Bool
    var recommendHospitals: [RecommendedHospital]
    enum CodingKeys: String, CodingKey {
           case access_token, hadConsultation, recommendHospitals
       }
}

// 추천 병원에 대한 구조체
struct RecommendedHospital: Codable {
    var hospital_id: Int
    var icon: String
}
