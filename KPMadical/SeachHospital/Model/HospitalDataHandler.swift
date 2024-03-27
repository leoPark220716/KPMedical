//
//  HospitalDataHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import Foundation

class HospitalDataHandler: ObservableObject {
    @Published var CheckLoadingState = false
    var HospitalDetailData = HospitalDataManager.HospitalDataClass()
    
    func GetDoctorArray() -> [HospitalDataManager.Doctor] {
        return HospitalDetailData.doctors
    }
    func GetDepartHaveDoctor(id: String) -> [HospitalDataManager.Doctor]{
        return HospitalDetailData.doctors.filter{
            $0.department_id.contains(id)
        }
    }
    func GetMainSchdules() -> [HospitalDataManager.Schedule] {
        return HospitalDetailData.doctors.flatMap
        {
            $0.main_schedules
        }
    }
    
    func GetSubSchedules() -> [HospitalDataManager.Schedule]{
        return HospitalDetailData.doctors.flatMap
        {
            $0.sub_schedules
        }
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
    //
    enum ChooseTimeOrDoctor: Hashable {
        case Doctor
        case Time
    }
}
