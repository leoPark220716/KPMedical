//
//  HospitalDetailIntroView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI
import NMapsMap

struct HospitalDetailIntroView: View{
    
    @Binding var coord: NMGLatLng
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
    @EnvironmentObject var router: GlobalViewRouter
//    router.hospital_data.
    var body: some View{
        Text("진료시간")
            .bold()
            .padding(.leading,30)
            .padding(.top,8)
        HospitalScheduleView(HospitalSchedules: $HospitalSchedules)
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
            .cornerRadius(10)
            .padding()
        Text("전화번호")
            .bold()
            .padding(.leading,30)
            .padding(.top,8)
        HStack{
            let numerString = formatKoreanPhoneNumber(router.hospital_data!.HospitalDetailData.hospital.phone)
            Text(numerString)
                .padding(.leading,30)
            Spacer()
            Text("전화하기")
                .font(.system(size: 13))
                .bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                .cornerRadius(10)
                .foregroundColor(Color("ConceptColor"))
                .onTapGesture {
                    let telephone = "tel://"
                    let formattedString = telephone + numerString
                    guard let url = URL(string: formattedString) else { return }
                    UIApplication.shared.open(url)
                }
                .padding(.trailing,30)
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
            .cornerRadius(10)
            .padding()
        Text("위치")
            .bold()
            .padding(.leading,30)
            .padding(.top,8)
        Text(router.hospital_data!.HospitalDetailData.hospital.location)
            .font(.system(size: 13))
            .padding(.leading,30)
            .padding(.top,8)
        
        HStack {
            Spacer() // 좌측에 공간 추가
            NMFMapViewRepresentable(coord: $coord)
                .frame(width: 350, height: 160) // 원하는 크기 설정
                .cornerRadius(20)
            Spacer() // 우측에 공간 추가
        }
    }
}
