//
//  ChooseDorcor.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct ChooseDorcor: View {
    @Binding var path: NavigationPath
    @ObservedObject var userInfo: UserObservaleObject
    @ObservedObject var HospitalInfo: HospitalDataHandler
    @State var DoctorProfile: [HospitalDataManager.Doctor] = []
    @State var CheckFirst: Bool = false
    @Binding var info: reservationInfo
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    VStack{
                        if !DoctorProfile.isEmpty{
                            ForEach(DoctorProfile.indices, id: \.self) { index in
                                DoctorItemView(DoctorProfile: $DoctorProfile[index])
                                    .onTapGesture {
                                        info.staff_id = DoctorProfile[index].staff_id
                                        info.time_slot = DoctorProfile[index].main_schedules[0].timeSlot
                                        info.doc_name = DoctorProfile[index].name
                                        if CheckFirst{
                                            print("info.date : \(info.date)")
                                            print("info.hospital_id :\(info.hospital_id)")
                                            print("info.staff_id : \(info.staff_id)")
                                            print("info.department_id \(info.department_id)")
                                            path.append(HospitalDataHandler.ChooseTimeOrDate.Date)
                                        }else{
                                            print("info.date : \(info.date)")
                                            print("info.hospital_id :\(info.hospital_id)")
                                            print("info.staff_id : \(info.staff_id)")
                                            print("info.department_id \(info.department_id)")
                                            path.append(HospitalDataHandler.ChooseTimeOrDate.Time)
                                        }
                                    }
                                
                            }
                        }else{
                            Text("의사가 없습니다.")
                        }
                    }
                    .padding(.top)
                    .navigationDestination(for: HospitalDataHandler.ChooseTimeOrDate.self){ value in
                        switch value{
                        case .Date:
                            ChooseDate(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo,CheckFirst: false,info: $info)
                        case .Time:
                            ChooseTime(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
                        }
                    }
                }
            }
            if DoctorProfile.isEmpty {
                ProgressView("의료진 정보를 불러오고 있습니다...")
                    .font(.system(size: 10))
                    .scaleEffect(2) // 크기를 조정하려면 scaleEffect 사용
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5)) // 반투명 배경
                    .foregroundColor(.white)
            }
        }
        .onAppear{
            info.staff_id = 0
            if CheckFirst{
                DoctorProfile = HospitalInfo.GetDepartHaveDoctor(id: info.department_id)
            }else{
                var workingStaffIds: [Int] = []
                let docarr = HospitalInfo.GetDepartHaveDoctor(id: info.department_id)
                workingStaffIds = HospitalInfo.findWorkingStaffIds(on: info.date, from: docarr)
                DoctorProfile = HospitalInfo.GetDoctorGetIDArry(staff_id: workingStaffIds)
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

