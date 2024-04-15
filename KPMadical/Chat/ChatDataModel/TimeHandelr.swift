//
//  TimeHandelr.swift
//  KPMadical
//
//  Created by Junsung Park on 4/16/24.
//

import Foundation

class TimeHandler {
    func timeChangeToChatTime (time: String) -> (success: Bool, chatTime: String){

        // ISO 8601 형식을 파싱하기 위한 DateFormatter 설정
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        // 문자열을 Date 객체로 변환
        if let date = isoFormatter.date(from: time) {
            // 변환된 Date 객체를 원하는 형식으로 다시 포맷
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "a hh:mm" // "오후 05:31" 형식
            outputFormatter.amSymbol = "오전"
            outputFormatter.pmSymbol = "오후"
            // 최종 결과 문자열 출력
            let formattedDateStr = outputFormatter.string(from: date)
            print(formattedDateStr) // 예: "오후 05:31"
            return (true,formattedDateStr)
        } else {
            print("날짜 변환 실패")
            return (false,"")
        }
    }
    
    
    func returnyyyy_MM_dd (time: String) -> (success: Bool, chatTime: String){

        // ISO 8601 형식을 파싱하기 위한 DateFormatter 설정
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        // 문자열을 Date 객체로 변환
        if let date = isoFormatter.date(from: time) {
            // 변환된 Date 객체를 원하는 형식으로 다시 포맷
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            // 최종 결과 문자열 출력
            let formattedDateStr = outputFormatter.string(from: date)
            print(formattedDateStr)
            return (true,formattedDateStr)
        } else {
            print("날짜 변환 실패")
            return (false,"")
        }
    }
    
    
}
