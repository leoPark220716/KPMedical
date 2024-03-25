import UIKit
import Foundation
//// 요일 배열
let daysOfWeek = ["월", "화", "수", "목", "금", "토", "일"]
//// 주어진 배열
//let schedules = ["0000011", "1000001", "1000001", "0100011", "0000101"]
//
//// 모든 요일에 대해 공통적으로 쉬는 날과 영업일을 등록할 배열
//var commonDaysOff: [String] = []
//var commonWorkingDays: [String] = []
//
//// 각 요일별로 확인
//for index in 0..<7 { // 0부터 6까지 (월요일부터 일요일까지)
////    allStatisfy 메서드는 배열의 모든 요소의 값을 검사하는 것임.조건은 클로저에 의해서 정의됨 Bool 값을 반환함.
//    let isDayOffForAll = schedules.allSatisfy { schedule in
////        characterIndex 는 schedules 배열의 어느 인덱스를 전체적으로 검사할 것인지를 말함. 저기서 startIndex 에서부터 index 까지를 의미함.
////        더 쉽게 말하면 schedule.startIndex 가 0 이면 offsetBy 의 숫자까지 간 인덱스를 검사하겠다 는 말임. 인덱스의 범위가 아니고 인덱스 하나를 지정하는거임
//        let characterIndex = schedule.index(schedule.startIndex, offsetBy: index)
////        그리고 그게 만약 "1" 과 같은 문자 열이라면 true 를 반환하고 아니라면 false 를 반환함.
//        return schedule[characterIndex] == "1"
//    }
////    그래서 만약 모두가 "1" 의 배열을 가지고 있다면 commonDaysOff 에 해당 인덱스에 포함되는 요일을 추가하고
////    아니라면 영업일 요일을 추가하는거임
//    if isDayOffForAll {
//        commonDaysOff.append(daysOfWeek[index])
//    }else{
//        commonWorkingDays.append(daysOfWeek[index])
//    }
//
//}
//
//// 결과 출력
//print("모두가 쉬는 요일: \(commonDaysOff)")
//print("영업일: \(commonWorkingDays)")
//let daysOfWeek = ["월", "화", "수", "목", "금", "토", "일"]
//let schedules = [
//    ["start_time": "09:00", "end_time": "17:00", "dayoff": "0010010"],
//    ["start_time": "07:00", "end_time": "18:00", "dayoff": "1010001"],
//    ["start_time": "05:00", "end_time": "17:00", "dayoff": "1010001"],
//    ["start_time": "06:00", "end_time": "16:00", "dayoff": "0110011"],
//    ["start_time": "09:00", "end_time": "19:00", "dayoff": "0010101"]
//]
//
//var commonDaysOff: [String] = []
//var storeHours: [(day: String, open: String, close: String, holyday : Bool)] = []
//
//for index in 0..<7 {
//    let isDayOffForAll = schedules.allSatisfy { schedule in
//        let dayOffString = schedule["dayoff"]!
//        let dayOffIndex = dayOffString.index(dayOffString.startIndex, offsetBy: index)
//        return dayOffString[dayOffIndex] == "1"
//    }
//
//    if isDayOffForAll {
//        storeHours.append((daysOfWeek[index], "", "",true))
//    } else {
//        // 해당 요일에 근무하는 스케줄만 필터링
//        let workingSchedules = schedules.filter { schedule in
//            let dayOffString = schedule["dayoff"]!
//            let dayOffIndex = dayOffString.index(dayOffString.startIndex, offsetBy: index)
//            return dayOffString[dayOffIndex] == "0"
//        }
//        // 필터링된 스케줄에서 개점 시간과 폐점 시간을 계산
//        let latestStart = workingSchedules.compactMap { $0["start_time"] }.min() ?? "24:00"
//        let earliestEnd = workingSchedules.compactMap { $0["end_time"] }.max() ?? "00:00"
//
//        storeHours.append((daysOfWeek[index], latestStart, earliestEnd,false))
//    }
//}
//
//
//// 결과 출력
//print("모두가 쉬는 요일: \(commonDaysOff)")
//storeHours.forEach { day, open, close, holyday in
//    print("\(day)일: 개점시간 \(open), 폐점시간 \(close) 휴무 \(holyday)")
//}

let testSchedules = [
    ["schedule_id": 2,
     "hospital_id": 7,
     "staff_id": 5,
     "start_date": "2024-03-22",
     "end_date": "2024-12-31",
     "start_time1": "10:00",
     "end_time1": "13:00",
     "start_time2": "14:00",
     "end_time2": "15:00",
     "time_slot": "30",
     "max_reservation": 1,
     "dayoff": "0000011",
     "name": "김성훈"],
    ["schedule_id": 2,
     "hospital_id": 7,
     "staff_id": 5,
     "date": "2024-03-23",
     "start_time1": "10:00",
     "end_time1": "13:00",
     "start_time2": "14:00",
     "end_time2": "18:00",
     "time_slot": "10",
     "max_reservation": 1,
     "dayoff": "0010001",
     "name": "김성훈"],
    ["schedule_id": 4,
     "hospital_id": 7,
     "staff_id": 5,
     "date": "2024-03-28",
     "start_time1": "10:00",
     "end_time1": "13:00",
     "start_time2": "14:00",
     "end_time2": "18:00",
     "time_slot": "30",
     "max_reservation": 1,
     "dayoff": "0010001",
     "name": "김성훈"]
    ]
var commonDaysOffTest: [String] = []
var storeHoursTest: [(day: String, open: String, close: String, holyday : Bool)] = []

for index in 0..<7 {
    let isDayOffForAll = testSchedules.allSatisfy { schedule in
        guard let dayOffString = schedule["dayoff"] as? String else { return false }
        let dayOffIndex = dayOffString.index(dayOffString.startIndex, offsetBy: index)
        return dayOffString[dayOffIndex] == "1"
    }

    if isDayOffForAll {
        storeHoursTest.append((daysOfWeek[index], "", "", true))
    } else {
        let workingSchedules = testSchedules.filter { schedule in
            guard let dayOffString = schedule["dayoff"] as? String else { return false }
            let dayOffIndex = dayOffString.index(dayOffString.startIndex, offsetBy: index)
            return dayOffString[dayOffIndex] == "0"
        }
        let latestStart = workingSchedules.compactMap { $0["start_time1"] as? String }.min() ?? "24:00"
        let earliestEnd = workingSchedules.compactMap { $0["end_time2"] as? String }.max() ?? "00:00"

        storeHoursTest.append((daysOfWeek[index], latestStart, earliestEnd, false))
    }
}

print("모두가 쉬는 요일: \(commonDaysOffTest)")
storeHoursTest.forEach { day, open, close, holyday in
    print("\(day)일: 개점시간 \(open), 폐점시간 \(close) 휴무 \(holyday)")
}
