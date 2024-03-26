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
    func GetMainSchdules() -> [HospitalDataManager.Schedule] {
        return HospitalDetailData.doctors.flatMap
        {
            $0.main_schedules
        }
    }
    func LoadingCheck(){
        DispatchQueue.main.async{
            self.CheckLoadingState = true
        }
    }
}
