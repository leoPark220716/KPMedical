//
//  MyHospitalRequest.swift
//  KPMadical
//
//  Created by Junsung Park on 5/9/24.
//

import Foundation

class MyHospitalRequest: ObservableObject{
    @Published var hospitals: [HospitalDataManager.Hospitals] = []
    func getMyHospitalList(token: String) {
        let httpStruct = http<Empty?, KPApiStructFrom<HospitalDataManager.Hospital_Data>>.init(
            method: "GET",
            urlParse: "v2/users/marks?start=0&limit=10",
            token: token,
            UUID: getDeviceUUID())
        Task{
            let success = await KPWalletApi(HttpStructs: httpStruct)
            if success.success{
                DispatchQueue.main.async{
                    self.hospitals = success.data!.data.hospitals
                }
            }
        }
    }
}
