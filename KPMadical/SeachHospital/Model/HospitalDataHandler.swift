//
//  HospitalDataHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import Foundation

class HospitalDataHandler: ObservableObject {
    @Published var CheckLoadingState = false
    @Published var DoctorProfile: [HospitalDataManager.Doctor] = []
    @Published var CheckFirst: Bool = false
    
    var HospitalDetailData = HospitalDataManager.HospitalDataClass()
    
    func GetDoctorArray() -> [HospitalDataManager.Doctor] {
        return HospitalDetailData.doctors
    }
    func GetDepartHaveDoctor(id: String) -> [HospitalDataManager.Doctor]{
        return HospitalDetailData.doctors.filter{
            $0.department_id.contains(id)
        }
    }
    func GetMainSchdules(departId: String) -> [HospitalDataManager.Schedule] {
        var doctors: [HospitalDataManager.Doctor] = []
        var Mainschdules: [HospitalDataManager.Schedule] = []
        for doc in HospitalDetailData.doctors{
            for depart in doc.department_id{
                if depart == departId{
                    doctors.append(doc)
                    break
                }
            }
        }
        for doctor in doctors {
            Mainschdules.append(contentsOf: doctor.main_schedules)
        }
        return Mainschdules
    }
    
    func GetSubSchedules(departId: String) -> [HospitalDataManager.Schedule]{
        var doctors: [HospitalDataManager.Doctor] = []
        var Mainschdules: [HospitalDataManager.Schedule] = []
        for doc in HospitalDetailData.doctors{
            for depart in doc.department_id{
                if depart == departId{
                    doctors.append(doc)
                    break
                }
            }
        }
        for doctor in doctors {
            Mainschdules.append(contentsOf: doctor.sub_schedules)
        }
        return Mainschdules
    }
    //    오전 시작 시간 출력
    func GetStartTime1(staff_id: Int, date: String) -> String {
        var startTime1 = "09:00"
        if let schedule = HospitalDetailData.doctors.first(where: {$0.staff_id == staff_id}){
            if let findSub = schedule.sub_schedules.first(where: {$0.date == date}){
                startTime1 = findSub.startTime1
            }else{
                startTime1 = schedule.main_schedules[0].startTime1
            }
        }
        return startTime1
    }
    //    오전 끝나는 시간 출력
    func GetEndTime1(staff_id: Int, date: String) -> String {
        var endTime1 = "12:00"
        if let schedule = HospitalDetailData.doctors.first(where: {$0.staff_id == staff_id}){
            if let findSub = schedule.sub_schedules.first(where: {$0.date == date}){
                endTime1 = findSub.endTime1
            }else{
                endTime1 = schedule.main_schedules[0].endTime1
            }
        }
        return endTime1
    }
    //    오후 시작 시간 출력
    func GetStartTime2(staff_id: Int, date: String) -> String {
        var startTime2 = "13:00"
        if let schedule = HospitalDetailData.doctors.first(where: {$0.staff_id == staff_id}){
            if let findSub = schedule.sub_schedules.first(where: {$0.date == date}){
                startTime2 = findSub.startTime2
            }else{
                startTime2 = schedule.main_schedules[0].startTime2
            }
        }
        return startTime2
    }
    //    오후 끝나는 시간 출력
    func GetEndTime2(staff_id: Int, date: String) -> String {
        var endTime2 = "21:00"
        if let schedule = HospitalDetailData.doctors.first(where: {$0.staff_id == staff_id}){
            if let findSub = schedule.sub_schedules.first(where: {$0.date == date}){
                endTime2 = findSub.endTime2
            }else{
                endTime2 = schedule.main_schedules[0].endTime2
            }
        }
        return endTime2
    }
    func GetDoctors() -> [HospitalDataManager.Doctor]{
        return HospitalDetailData.doctors
    }
    func LoadingCheck(){
        DispatchQueue.main.async{
            self.CheckLoadingState = true
        }
    }
    func GetDoctorMainSchedules(staff_id: Int) -> [HospitalDataManager.Schedule] {
        // doctors 배열에서 staff_id가 주어진 staff_id와 일치하는 의사를 찾습니다.
        if let doctor = HospitalDetailData.doctors.first(where: { $0.staff_id == staff_id }) {
            // 해당 의사의 main_schedules를 반환합니다.
            return doctor.main_schedules
        } else {
            // 일치하는 의사가 없는 경우, 빈 배열을 반환합니다.
            return []
        }
    }
    func GetDoctorSubSchedules(staff_id: Int) -> [HospitalDataManager.Schedule] {
        // doctors 배열에서 staff_id가 주어진 staff_id와 일치하는 의사를 찾습니다.
        if let doctor = HospitalDetailData.doctors.first(where: { $0.staff_id == staff_id }) {
            // 해당 의사의 main_schedules를 반환합니다.
            return doctor.sub_schedules
        } else {
            // 일치하는 의사가 없는 경우, 빈 배열을 반환합니다.
            return []
        }
    }
    func GetDoctorGetIDArry(staff_id: [Int]) -> [HospitalDataManager.Doctor] {
        var doc: [HospitalDataManager.Doctor] = []
        for item in staff_id{
            for doctorAr in HospitalDetailData.doctors{
                if item == doctorAr.staff_id{
                    doc.append(doctorAr)
                }
            }
        }
        return doc
    }
    //    특정 날짜 의사 출근 확인
    func findWorkingStaffIds(on date: String, from doctors: [HospitalDataManager.Doctor]) -> [Int] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let targetDate = dateFormatter.date(from: date) else {
            print("Invalid date format")
            return []
        }
        
        var workingStaffIds: [Int] = []
        
        for doctor in doctors {
            // sub_schedules에서 휴무 확인
            let isOffDayInSubSchedule = doctor.sub_schedules.contains { subSchedule in
                subSchedule.date == date && subSchedule.dayoff == "1"
            }
            let isOnDay = doctor.sub_schedules.contains { subSchedule in
                subSchedule.date == date && subSchedule.dayoff == "0"
            }
            if isOnDay{
                workingStaffIds.append(doctor.staff_id)
                continue
            }
            // sub_schedules에서 휴무로 명시된 경우 다음 의사 검사로 이동
            if isOffDayInSubSchedule {
                continue
            }
            
            // main_schedules에서 출근 여부 확인
            for mainSchedule in doctor.main_schedules {
                guard let startDate = dateFormatter.date(from: mainSchedule.startDate ?? ""),
                      let endDate = dateFormatter.date(from: mainSchedule.endDate ?? ""),
                      startDate...endDate ~= targetDate else {
                    continue
                }
                
                // 요일을 1부터 시작하는 인덱스로 변경 (월요일이 1, 일요일이 7)
                let dayOfWeek = Calendar.current.component(.weekday, from: targetDate)
                let adjustedDayOfWeek = dayOfWeek == 1 ? 6 : dayOfWeek - 2 // 월요일을 1로 조정합니다.
                
                if mainSchedule.dayoff.count > adjustedDayOfWeek {
                    let startIndex = mainSchedule.dayoff.index(mainSchedule.dayoff.startIndex, offsetBy: adjustedDayOfWeek)
                    let dayOffCharacter = mainSchedule.dayoff[startIndex]
                    
                    let isWorkDay = dayOffCharacter == "0" // "0"은 출근을 의미합니다.
                    // 출근일 경우 결과에 추가
                    if isWorkDay {
                        workingStaffIds.append(doctor.staff_id)
                        break // 다음 main_schedule 검사는 필요 없음
                    }
                }
            }
            
        }
        print("idCheck \(workingStaffIds)")
        return workingStaffIds
    }
    
    //    상담 또는 예약하기 선택 확장
    enum NavigationTarget: Hashable {
        case counsel
        case selectDepartment
    }
    //    의료진, 진료일 선택 확장
    enum ChooseDateOrDoctor: Hashable {
        case date_day
        case doctor
    }
    //    의사 선택 창에서 날짜로 갈건지 타이머로 갈건지
    enum ChooseTimeOrDate: Hashable {
        case Date
        case Time
    }
    // 날짜 선택 창에서 의사 선택인지 타임 선택인지
    enum ChooseTimeOrDoctor: Hashable {
        case Doctor
        case Time
    }
    enum GotoLast: Hashable {
        case textfiledView
    }
    enum GotoEnd: Hashable {
        case ending
    }
}
