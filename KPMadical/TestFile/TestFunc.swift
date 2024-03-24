//
//  TestFunc.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

// Define the root structure of the JSON data
struct HospitalData: Codable {
    var data: [HospitalDataManager.Hospitals]
}
//현재 기준 한국시간 가져오기
func getTime() -> String {
    let date = DateFormatter()
    date.timeZone = TimeZone(identifier: "Asia/Seoul")
    date.dateFormat = "HHmm"
    return date.string(from: Date())
}
// 현재 시간이 Start Time 과 end Time 안에 포함되는지 결과 bool 반환
//func checkTimeIn(startTime: String, endTime: String) -> Bool{
//    let date = DateFormatter()
//    date.timeZone = TimeZone(identifier: "Asia/Seoul")
//    date.dateFormat = "HHmm"
//    var now = Int(date.string(from: Date()))
//    var st = Int(startTime.trimmingCharacters(in: [":"]))
//    var en = Int(endTime.trimmingCharacters(in: [":"]))
//    return now! >= st! && now! <= en!
//}

//func checkTimeIn(startTime: String, endTime: String) -> Bool{
//    let date = DateFormatter()
//    date.timeZone = TimeZone(identifier: "Asia/Seoul")
//    date.dateFormat = "HHmm"
//    var now = Int(date.string(from: Date()))
//    var st = Int(startTime.trimmingCharacters(in: [":"]))
//    var en = Int(endTime.trimmingCharacters(in: [":"]))
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "HH:mm"
//    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
//    guard let start = dateFormatter.date(from: startTime),
//          let end = dateFormatter.date(from: endTime),
//          let current = dateFormatter.date(from: dateFormatter.string(from: Date()))
//    else {
//        return false
//    }
//    print("current : \(now)")
//    print("start  \(st)")
//    print("end \(en)")
//    print("end \(now)")
//    return current >= start && current <= end
//}
func checkTimeIn(startTime: String, endTime: String) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    dateFormatter.dateFormat = "HHmm"
    guard let now = Int(dateFormatter.string(from: Date())),
          let st = Int(startTime.replacingOccurrences(of: ":", with: "")),
          let en = Int(endTime.replacingOccurrences(of: ":", with: "")) else {
        // 날짜 변환이 실패했을 경우
        return false
    }

    return now >= st && now <= en
}
