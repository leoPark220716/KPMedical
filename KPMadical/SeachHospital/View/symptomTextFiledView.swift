//
//  symptomTextFiledView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/28/24.
//

import SwiftUI
import Combine

struct symptomTextFiledView: View {
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @State private var feedbackText: String = ""
    let maxCharacters = 100
    @State private var isTap: Bool = false
    let requestData = HospitalHTTPRequest()
    var body: some View {
        VStack {
            ZStack{
                TextEditor(text: $feedbackText)
                    .font(.custom("Helvetica Nenu", size: 15))
                    .frame(height: 200)
                    .background(Color.white) // 배경 색 설정
                    .padding()
                    .clipShape(RoundedRectangle(cornerRadius: 20)) // 여기서 모서리를 둥글게 만듭니다.
                    .overlay(
                        RoundedRectangle(cornerRadius: 20) // 모서리가 둥근 사각형 오버레이를 추가하여 테두리 적용
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top,30)
                    .onReceive(Just(feedbackText)){
                        feedbackText = String($0.prefix(100))
                    }
                    .onTapGesture {
                        isTap = true
                    }
                if !isTap{
                    Text("증상을 입력해주세요.")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            HStack {
                Spacer()
                Text("(\(feedbackText.count)/\(maxCharacters))")
                    .font(.custom("Helvetica Nenu", size: 15))
                    .foregroundColor(maxCharacters == feedbackText.count ? .red : .blue)
                    .padding(.trailing,30)
            }
            Spacer()
            Button(action: sendFeedback) {
                Text("예약 확정")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("ConceptColor"))
                    .cornerRadius(10)
            }
//            reservationSuccessView()
//            .navigationDestination(for:HospitalDataHandler.GotoEnd.self){ value in
//                switch value{
//                case .ending:
//                    reservationSuccessView(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo, info: $info)
//                }
//            }
                
            
            .padding()
            .disabled(feedbackText.isEmpty)
        }
        .background(Color.gray.opacity(0.09))
        .navigationTitle("증상 작성")
    }
    
    func sendFeedback() {
        print("Token: \(userInfo.token)")
        print("Device UUID: \(getDeviceUUID())")
        print("Hospital ID: \(router.HospitalReservationData!.hospital_id)")
        print("Staff ID: \(router.HospitalReservationData!.staff_id)")
        print("Date: \(router.HospitalReservationData!.date)")
        print("Time: \(router.HospitalReservationData!.time)")
        print("Purpose: \(feedbackText)")
        print("Time Slot: \(router.HospitalReservationData!.time_slot)")
        router.HospitalReservationData!.purpose = feedbackText
        requestData.SaveReservation(token: userInfo.token,
                                    uid: getDeviceUUID(),
                                    hospital_id: router.HospitalReservationData!.hospital_id,
                                    staff_id: router.HospitalReservationData!.staff_id,
                                    date: router.HospitalReservationData!.date,
                                    time: router.HospitalReservationData!.time,
                                    purpose: feedbackText,
                                    time_slot: router.HospitalReservationData!.time_slot)
        { Bool in
            if Bool{
//                path.append(HospitalDataHandler.GotoEnd.ending)
                DispatchQueue.main.async{
                    router.tabPush(to: .item(item: ViewPathAddress(name: "reservationSuccessView", page: 8, id: 8)))
                }
                print("ok")
            }else{
                print("false")
            }
        }
        print("Feedback sent: \(feedbackText)")
    }
}
//#Preview {
//    symptomTextFiledView()
//}
