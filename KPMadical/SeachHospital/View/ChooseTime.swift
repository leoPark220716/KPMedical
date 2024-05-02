//
//  ChooseTime.swift
//  KPMadical
//
//  Created by Junsung Park on 3/27/24.
//

import SwiftUI

struct ChooseTime: View {
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @State var reservation: [HospitalDataManager.Reservation] = []
    let requestData = HospitalHTTPRequest()
    @State var timeSlot: Int = 0
    @State var reservedTimes: [String] = []
    @State var startTime1: String = ""
    @State var endTime1: String = ""
    @State var startTime2: String = ""
    @State var endTime2 : String = ""
    @State var selectedTime: String = ""
    @State var isTap = false
    @State var isApper = false
    var body: some View {
        VStack{
            HStack{
                Text("시간 선택")
                    .font(.system(size: 23))
                    .bold()
                Spacer()
            }
            .padding()
            ScrollView{
                if isApper{
                    TimeChoseScroll(timeSlot: $timeSlot, reservedTimes: $reservedTimes, startTime1: $startTime1, endTime1: $endTime1, startTime2: $startTime2, endTime2: $endTime2,selectedTime: $selectedTime)
                }
            }
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                .cornerRadius(10)
                .padding(.bottom,10)
            HStack{
                VStack{
                    Text(router.HospitalReservationData!.date)
                        .font(.system(size: 14))
                        .padding(.leading)
                    Text("\(selectedTime)")
                        .font(.system(size: 14))
                        .padding(.leading)
                }
                .padding(.leading)
                Spacer()
                Text("확인")
                    .bold()
                    .padding()
                    .font(.system(size: 20))
                    .frame(width: 100,height: 40)
                    .foregroundColor(Color.white)
                    .background(selectedTime != "" ? Color.blue.opacity(0.5) : Color.gray.opacity(0.5))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(selectedTime != "" ? Color.blue.opacity(0.5) : Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.trailing,40)
                    .onTapGesture {
                        router.HospitalReservationData!.time = selectedTime
                        if selectedTime != ""{
                            router.tabPush(to: Route.item(item: ViewPathAddress(name: "symptomEditor", page: 7, id: 7)))
//                            path.append(HospitalDataHandler.GotoLast.textfiledView)
                        }
                    }
            }
            .navigationTitle("예약 시간을 선택해주세요")
        }
//        .navigationDestination(for: HospitalDataHandler.GotoLast.self){ value in
//            switch value{
//            case .textfiledView:
//                symptomTextFiledView()
//            }
//        }
        .background(Color.gray.opacity(0.09))
        .onAppear{
            requestData.GetReservations(token: userInfo.token, uid: getDeviceUUID(), date: router.HospitalReservationData!.date, staff_id: String(router.HospitalReservationData!.staff_id)){
                value in
                DispatchQueue.main.async{
                    reservation = value
                    self.reservedTimes = value.map { $0.time }
                    self.timeSlot = Int(router.HospitalReservationData!.time_slot) ?? 10
                    self.startTime1 = router.hospital_data!.GetStartTime1(staff_id: router.HospitalReservationData!.staff_id , date: router.HospitalReservationData!.date)
                    self.endTime1 = router.hospital_data!.GetEndTime1(staff_id: router.HospitalReservationData!.staff_id , date:  router.HospitalReservationData!.date)
                    self.startTime2 = router.hospital_data!.GetStartTime2(staff_id: router.HospitalReservationData!.staff_id , date: router.HospitalReservationData!.date)
                    self.endTime2 = router.hospital_data!.GetEndTime2(staff_id: router.HospitalReservationData!.staff_id , date: router.HospitalReservationData!.date)
                    isApper = true
                }
            }
        }
        
    }
}

//#Preview {
//    ChooseTime()
//}
