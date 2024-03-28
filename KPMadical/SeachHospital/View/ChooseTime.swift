//
//  ChooseTime.swift
//  KPMadical
//
//  Created by Junsung Park on 3/27/24.
//

import SwiftUI

struct ChooseTime: View {
    @Binding var path: NavigationPath
    @ObservedObject var userInfo: UserObservaleObject
    @ObservedObject var HospitalInfo: HospitalDataHandler
    @Binding var info: reservationInfo
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
                    Text(info.date)
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
                        info.time = selectedTime
                        if selectedTime != ""{
                            path.append(HospitalDataHandler.GotoLast.textfiledView)
                        }
                    }
            }
            .navigationTitle("예약 시간을 선택해주세요")
        }
        .navigationDestination(for: HospitalDataHandler.GotoLast.self){ value in
            switch value{
            case .textfiledView:
                symptomTextFiledView(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
            }
        }
        .background(Color.gray.opacity(0.09))
        .onAppear{
            requestData.GetReservations(token: userInfo.token, uid: getDeviceUUID(), date: info.date, staff_id: String(info.staff_id)){
                value in
                DispatchQueue.main.async{
                    reservation = value
                    self.reservedTimes = value.map { $0.time }
                    self.timeSlot = Int(info.time_slot) ?? 10
                    self.startTime1 = HospitalInfo.GetStartTime1(staff_id: info.staff_id , date: info.date)
                    self.endTime1 = HospitalInfo.GetEndTime1(staff_id: info.staff_id , date: info.date)
                    self.startTime2 = HospitalInfo.GetStartTime2(staff_id: info.staff_id , date: info.date)
                    self.endTime2 = HospitalInfo.GetEndTime2(staff_id: info.staff_id , date: info.date)
                    isApper = true
                }
            }
        }
        
    }
}

//#Preview {
//    ChooseTime()
//}
