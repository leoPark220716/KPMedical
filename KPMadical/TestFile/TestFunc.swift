//
//  TestFunc.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

// Define the root structure of the JSON data
struct HospitalData: Codable {
    var data: [Hospitals]
}

// Define the structure for each hospital
// Codable : 구조체를 Josn decode encode 를 원할하게 해주는 형태로 만들어줌
// Indetifiable 각각의 고유 id 가 필요한 Swift 프로토콜
// Equatable : 해당 구조체로 만들어진 객체가 같은지 비교할 수 있게 하는 기능을 달아줌
struct Hospitals: Codable, Identifiable, Equatable {
    var id = UUID() // SwiftUI List에서 사용하기 위한 유니크 아이덴티파이어
    var hospital_name: String
    var hospital_image: String
    var startTime: String
    var endTime: String
    var hospital_skill: [String]
    var hospital_id: String
    var address: String
    var longitude: String
    var latitude: String
//    CodingKey 열거형은 Json 의 키와 모델의 프로퍼티 이름이 다를 때 사용된다.
    enum CodingKeys: String, CodingKey {
        case hospital_name, hospital_image,startTime,endTime, hospital_skill, hospital_id, address, longitude, latitude
    }
}
//현재 기준 한국시간 가져오기
func getTime() -> String {
    let date = DateFormatter()
    date.timeZone = TimeZone(identifier: "Asia/Seoul")
    date.dateFormat = "HH:mm"
    return date.string(from: Date())
}
// 현재 시간이 Start Time 과 end Time 안에 포함되는지 결과 bool 반환
func checkTimeIn(startTime: String, endTime: String) -> Bool{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    guard let start = dateFormatter.date(from: startTime),
          let end = dateFormatter.date(from: endTime),
          let current = dateFormatter.date(from: dateFormatter.string(from: Date()))
    else {
        return false
    }
    return current >= start && current <= end
}
