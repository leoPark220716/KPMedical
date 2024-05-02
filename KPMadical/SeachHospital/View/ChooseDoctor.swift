//
//  ChooseDorcor.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct ChooseDorcor: View {
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    VStack{
                        if !router.hospital_data!.DoctorProfile.isEmpty{
                            ForEach(router.hospital_data!.DoctorProfile.indices, id: \.self) { index in
                                DoctorItemView(DoctorProfile: router.hospital_data!.DoctorProfile[index])
                                    .onTapGesture {
                                        router.HospitalReservationData!.staff_id = router.hospital_data!.DoctorProfile[index].staff_id
                                        
                                        router.HospitalReservationData!.time_slot = router.hospital_data!.DoctorProfile[index].main_schedules[0].timeSlot
                                        
                                        router.HospitalReservationData!.doc_name = router.hospital_data!.DoctorProfile[index].name
            
                                        if  router.HospitalReservationData!.date != ""{
                                            router.tabPush(to: Route.item(item: ViewPathAddress(name: "ChooseTime", page: 6, id: 6)))
//                                            print("info.date : \(info.date)")
//                                            print("info.hospital_id :\(info.hospital_id)")
//                                            print("info.staff_id : \(info.staff_id)")
//                                            print("info.department_id \(info.department_id)")
//                                            path.append(HospitalDataHandler.ChooseTimeOrDate.Date)
                                        }else{
                                            router.tabPush(to: Route.item(item: ViewPathAddress(name: "ChooseDate", page: 5, id: 5)))
//                                            print("info.date : \(info.date)")
//                                            print("info.hospital_id :\(info.hospital_id)")
//                                            print("info.staff_id : \(info.staff_id)")
//                                            print("info.department_id \(info.department_id)")
//                                            path.append(HospitalDataHandler.ChooseTimeOrDate.Time)
                                        }
                                    }
                                
                            }
                        }else{
                            Text("의사가 없습니다.")
                        }
                    }
                    .padding(.top)
//                    .navigationDestination(for: HospitalDataHandler.ChooseTimeOrDate.self){ value in
//                        switch value{
//                        case .Date:
//                            ChooseDate(HospitalInfo: HospitalInfo,CheckFirst: false,info: $info)
//                        case .Time:
//                            ChooseTime(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
//                        }
//                    }
                }
            }
            if router.hospital_data!.DoctorProfile.isEmpty {
                ProgressView("의료진 정보를 불러오고 있습니다...")
                    .font(.system(size: 10))
                    .scaleEffect(2) // 크기를 조정하려면 scaleEffect 사용
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5)) // 반투명 배경
                    .foregroundColor(.white)
            }
        }
        .onAppear{
            router.HospitalReservationData!.staff_id = 0
            if router.HospitalReservationData!.date == ""{
                router.hospital_data!.DoctorProfile = router.hospital_data!.GetDepartHaveDoctor(id: router.HospitalReservationData!.department_id)
            }else{
                var workingStaffIds: [Int] = []
                let docarr = router.hospital_data!.GetDepartHaveDoctor(id: router.HospitalReservationData!.department_id)
                workingStaffIds = router.hospital_data!.findWorkingStaffIds(on: router.HospitalReservationData!.date, from: docarr)
                router.hospital_data!.DoctorProfile = router.hospital_data!.GetDoctorGetIDArry(staff_id: workingStaffIds)
            }
        }
        .navigationTitle("예약할 의사 선생님을 선택해주세요")
    }
    func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
}

