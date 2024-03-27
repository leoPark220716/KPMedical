//
//  HospitalScheduleView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI


struct HospitalScheduleView: View{
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
    let days = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    @State var storeHours: [(day: String, open: String, close: String, holiday: Bool)] = []
    let timeManager = TimeManager()
    var body: some View{
        if !HospitalSchedules.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(storeHours, id: \.day) { schedule in
                    HStack {
                        Spacer()
                        Text(schedule.day)
                            .font(.system(size: 13))
                            .foregroundColor(schedule.day == "일요일" ? .red : .black)
                            .frame(width: 50, alignment: .leading)
                            .fontWeight(schedule.day == timeManager.String_currentWeekday() ? .bold : .regular)
                        Spacer()
                        Text(schedule.holiday ? "휴무" : "\(schedule.open)~\(schedule.close)")
                            .font(.system(size: 13))
                            .foregroundColor(schedule.day == "일요일" ? .red : .black)
                            .frame(width: 110, alignment: .center)
                            .fontWeight(schedule.day == timeManager.String_currentWeekday() ? .bold : .regular)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onAppear {
                storeHours = [] // 배열을 초기화
                for index in 0..<7 {
                    let isDayOffForAll = HospitalSchedules.allSatisfy { schedule in
                        let dayOffIndex = schedule.dayoff.index(schedule.dayoff.startIndex, offsetBy: index)
                        return schedule.dayoff[dayOffIndex] == "1"
                    }
                    if isDayOffForAll {
                        storeHours.append((days[index], "", "", true))
                    } else {
                        let workingSchedules = HospitalSchedules.filter { schedule in
                            let dayOffIndex = schedule.dayoff.index(schedule.dayoff.startIndex, offsetBy: index)
                            return schedule.dayoff[dayOffIndex] == "0"
                        }
                        let latestStart = workingSchedules.map { $0.startTime1 }.min() ?? "24:00"
                        let earliestEnd = workingSchedules.map { $0.endTime2 }.max() ?? "00:00"
                        storeHours.append((days[index], latestStart, earliestEnd, false))
                    }
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
            .padding(.horizontal)
        }
        else{
            VStack(alignment: .leading, spacing: 10) {
                ForEach(storeHours, id: \.day) { schedule in
                    HStack {
                        Spacer()
                        Text(schedule.day)
                            .font(.system(size: 13))
                            .foregroundColor(schedule.day == "일요일" ? .red : .black)
                            .frame(width: 50, alignment: .leading)
                        Spacer()
                        Text(schedule.holiday ? "휴무" : "\(schedule.open)~\(schedule.close)")
                            .font(.system(size: 13))
                            .foregroundColor(schedule.day == "일요일" ? .red : .black)
                            .frame(width: 110, alignment: .center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .onAppear {
                storeHours = [] // 배열을 초기화
                for index in 0..<7 {
                    storeHours.append((days[index], "11:00", "11:00", false))
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
            .padding(.horizontal)
        }
    }
}
