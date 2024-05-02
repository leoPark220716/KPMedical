//
//  reservationItemView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import SwiftUI

struct reservationItemView: View {
    var item: reservationDataHandler.reservationAr
    let dateString = "2024-03-12"
    let timeString = "15:30"
    @State var TimeCarculate: String = ""
    var body: some View {
        VStack {
            HStack{
                VStack(alignment: .leading){
                    HStack{
                        Text(item.hospital_name)
                            .font(.headline)
                            .bold()
                        Spacer()
                        Text(TimeCarculate)
                            .bold()
                            .font(.system(size: 13))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("ConceptColor"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .padding(.bottom,4)
                    HStack{
                        Text("환자명 |")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .bold()
                        Text(item.patient_name)
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom,2)
                    HStack{
                        Text("예약시간 |")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .bold()
                        Text("\(item.date) \(item.time)")
                            .font(.subheadline)
                            .bold()
                    }
                    .padding(.bottom,2)
                    HStack{
                        Text("의사 |")
                            .foregroundStyle(Color.gray)
                            .font(.subheadline)
                            .bold()
                        Text(item.staff_name)
                            .font(.subheadline)
                            .bold()
                        Spacer()
                    }
                    HStack {
                        ForEach(item.department_id.prefix(4), id: \.self) { id in
                            let intid = Int(id)
                            if let department = Department(rawValue: intid ?? 0) {
                                Text(department.name)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.blue)
                            }
                        }
                        if item.department_id.count > 4 {
                            Text("...")
                        }
                    }
                }
            }
        }
        .background(Color.white)
        .padding(.vertical,5)
        .onAppear{
            let timezone = TimeZone(identifier: "Asia/Seoul")!
            var calendar = Calendar.current
            calendar.timeZone = timezone

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            dateFormatter.timeZone = timezone

            // 주어진 날짜와 시간으로 Date 객체 생성
            if let visitDate = dateFormatter.date(from: "\(item.date) \(item.time)"){
                // 현재 날짜와 시간
                let currentDate = Date()
                // 방문 시간까지 남은 시간 (초 단위)
                let timeInterval = visitDate.timeIntervalSince(currentDate)
                if timeInterval < 0 {
                    // 이미 지난 시간
                    TimeCarculate = "종료"
                } else {
                    // 남은 시간을 시간과 일로 변환
                    let hours = timeInterval / 3600
                    let days = hours / 24
                    if hours < 24 {
                        TimeCarculate = "\(Int(hours)) 시간 후 방문"
                    } else {
                        TimeCarculate = "\(Int(days)) 일 후 방문"
                    }
                }
            } else {
                print("날짜 형식이 올바르지 않습니다.")
            }
        }
    }
}

//#Preview {
//    reservationItemView()
//}
