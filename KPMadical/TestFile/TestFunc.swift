//
//  TestFunc.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

// Define the root structure of the JSON data

//현재 기준 한국시간 가져오기
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

