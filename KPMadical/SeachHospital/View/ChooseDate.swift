//
//  ChooseDate.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI


struct ChooseDate: View {
    
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @State var CheckFirst: Bool = false
    @State private var selectedDate: Date? = nil
    @State private var SelectDateString: String = ""
    @State var disalbeWeek: Set<Int> = []
    @State var HospitalSchedules: [HospitalDataManager.Schedule] = []
    @State var HospitalSubSchedules: [HospitalDataManager.Schedule] = []
    @State var doctors: [HospitalDataManager.Doctor] = []
    @State var closeDate: [String] = []
    @State var mandi: [String] = []
    let today = Date()
    @State private var isReadyToShowCalendar = false
    @State var isTap = false
    var body: some View {
        VStack{
            Spacer()
            if isReadyToShowCalendar{
                CustomCalendarView(dateStrings: closeDate,selectedDate: $selectedDate, disabledDaysOfWeek: $disalbeWeek, mandatoryDateStrings: mandi, isTap: $isTap)
            }
            Spacer()
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                .cornerRadius(10)
                .padding(.bottom,10)
            HStack{
                Text(SelectDateString)
                    .font(.system(size: 14))
                    .padding(.leading)
                Spacer()
                HStack{
                    Text(selectedDate != nil ? formatDate(selectedDate!) : "")
                        .font(.system(size: 14))
                        .padding(.leading)
                    Spacer()
                    Text("선택완료")
                        .bold()
                        .padding()
                        .font(.system(size: 20))
                        .frame(width: 150)
                        .foregroundColor(Color.white)
                        .background(isTap ? Color.blue.opacity(0.5) : Color.gray.opacity(0.5))
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isTap ? Color.blue.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.trailing)
                        .onTapGesture {
                            if isTap {
                                router.HospitalReservationData!.setDate(date:formatDate(selectedDate!))
                                if router.HospitalReservationData!.staff_id != 0{
                                    router.tabPush(to: Route.item(item: ViewPathAddress(name: "ChooseTime", page: 6, id: 6)))
//                                    path.append(HospitalDataHandler.ChooseTimeOrDoctor.Doctor)
                                }else{
                                    router.tabPush(to: Route.item(item: ViewPathAddress(name: "ChooesDocor", page: 4, id: 4)))
                                    
//                                    path.append(HospitalDataHandler.ChooseTimeOrDoctor.Time)
                                }
                            }
//                            print("info.date : \(info.date)")
//                            print("info.hospital_id :\(info.hospital_id)")
//                            print("info.staff_id : \(info.staff_id)")
//                            print("info.department_id \(info.department_id)")
                        }
                }
            }
//            .navigationDestination(for: HospitalDataHandler.ChooseTimeOrDoctor.self){ value in
//                switch value{
//                case .Doctor:
//                    ChooseDorcor(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
//                case .Time:
//                    ChooseTime(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
//                }
//            }
        }
        .onAppear{
            router.HospitalReservationData?.date = ""
            if router.HospitalReservationData!.staff_id == 0{
                HospitalSchedules = router.hospital_data!.GetMainSchdules(departId: router.HospitalReservationData!.department_id)
                HospitalSubSchedules = router.hospital_data!.GetSubSchedules(departId: router.HospitalReservationData!.department_id)
                doctors = router.hospital_data!.GetDoctors()
                // 메인 스케줄 기반 휴일
                for index in 0..<7 {
                    let isDayOffForAll = HospitalSchedules.allSatisfy { schedule in
                        let dayOffIndex = schedule.dayoff.index(schedule.dayoff.startIndex, offsetBy: index)
                        return schedule.dayoff[dayOffIndex] == "1"
                    }
                    if isDayOffForAll {
                        // 토요일(6)인 경우 1(일요일)로 설정, 그 외는 index + 2
                        // 여기서 % 7을 사용하여 주간의 순환을 처리
                        disalbeWeek.insert((index + 1) % 7 + 1)
                    }
                }
                //                무족건 문 여는날
                for index in 0..<HospitalSubSchedules.count {
                    if HospitalSubSchedules[index].dayoff == "0"{
                        guard let date = HospitalSubSchedules[index].date else{
                            continue
                        }
                        mandi.append(date)
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                // 모든 의사의 sub_schedules를 조사하여 병원이 문을 닫아야 하는 날짜를 파악합니다.
                var datesWhenAllDoctorsOff = [String: Int]() // 의사들이 휴무인 날짜와 그 날 휴무인 의사 수를 저장합니다.
                var datesWhenAnyDoctorWorks = Set<String>() // 적어도 한 명의 의사가 출근하는 날짜를 저장합니다.
                
                for doctor in doctors {
                    for schedule in doctor.sub_schedules {
                        guard let date = schedule.date else { continue }
                        if schedule.dayoff == "1" {
                            // 의사가 휴식을 취하는 날
                            datesWhenAllDoctorsOff[date, default: 0] += 1
                        } else {
                            // 의사가 출근하는 날
                            datesWhenAnyDoctorWorks.insert(date)
                        }
                    }
                }
                // 모든 의사가 휴무인 날짜만을 추출합니다.
                for (date, count) in datesWhenAllDoctorsOff {
                    if count == doctors.count && !datesWhenAnyDoctorWorks.contains(date) {
                        // 모든 의사가 휴무이고, 아무도 출근하지 않는 날짜를 closeDate에 추가합니다.
                        closeDate.append(date)
                    }
                }
            }
            else{
                HospitalSchedules = router.hospital_data!.GetDoctorMainSchedules(staff_id: router.HospitalReservationData!.staff_id)
                HospitalSubSchedules = router.hospital_data!.GetDoctorSubSchedules(staff_id: router.HospitalReservationData!.staff_id)
                for index in 0..<7 {
                    let isDayOffForAll = HospitalSchedules.allSatisfy { schedule in
                        let dayOffIndex = schedule.dayoff.index(schedule.dayoff.startIndex, offsetBy: index)
                        return schedule.dayoff[dayOffIndex] == "1"
                    }
                    if isDayOffForAll {
                        // 토요일(6)인 경우 1(일요일)로 설정, 그 외는 index + 2
                        // 여기서 % 7을 사용하여 주간의 순환을 처리
                        if index == 6 {
                            disalbeWeek.insert(1)
                        }else{
                            disalbeWeek.insert(index+2)
                        }
                    }
                }
                //                무족건 문 여는날
                for index in 0..<HospitalSubSchedules.count {
                    if HospitalSubSchedules[index].dayoff == "0"{
                        guard let date = HospitalSubSchedules[index].date else{
                            continue
                        }
                        mandi.append(date)
                        print("무족건 문 여는날 \(date)")
                    }
                }
                //                무족건 문 닫는 날
                for index in 0..<HospitalSubSchedules.count {
                    if HospitalSubSchedules[index].dayoff == "1"{
                        guard let date = HospitalSubSchedules[index].date else{
                            continue
                        }
                        closeDate.append(date)
                        print("무족건 문 닫는날 \(date)")
                    }
                }
            }
            isReadyToShowCalendar = true
        }
    }
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

