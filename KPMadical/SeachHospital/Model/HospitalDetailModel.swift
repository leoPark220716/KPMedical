//
//  HospitalDetailModel.swift
//  KPMadical
//
//  Created by Junsung Park on 3/25/24.
//

import Foundation
import NMapsMap
import UIKit

struct HospitalDetailInfo {
    var startTime: String
    var endTime: String
    var hospitalId: Int
    var mainImage: String
}

class TimeManager{
    func Int_currentWeekday() -> Int {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "Asia/Seoul")! // 한국 시간대 설정
        let weekDay = calendar.component(.weekday, from: Date())
        // Swift에서의 weekDay는 일요일을 1로 시작합니다. 월요일을 1로 조정합니다.
        return weekDay == 1 ? 7 : weekDay - 1 // 일요일을 7로, 나머지는 1 (월요일)부터 6 (토요일)로 조정
    }
    func String_currentWeekday() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 설정
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국어 설정
            dateFormatter.dateFormat = "EEEE" // 요일을 전체 이름으로 표시
            let currentDateString = dateFormatter.string(from: Date())
            return currentDateString
        }
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
    func getTime() -> String {
        let date = DateFormatter()
        date.timeZone = TimeZone(identifier: "Asia/Seoul")
        date.dateFormat = "HHmm"
        return date.string(from: Date())
    }
}
