//
//  CustomCalender.swift
//  KPMadical
//
//  Created by Junsung Park on 3/27/24.
//

import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date?  // 선택된 날짜
    @State private var currentMonth: Date = Date() // 현재 보고 있는 달을 나타내는 상태
    private var year: Int { Calendar.current.component(.year, from: currentMonth) }
    private var month: Int { Calendar.current.component(.month, from: currentMonth) }
    private var daysInMonth: Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: dateComponents)!
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return range.count
    }
    private var firstDayWeekday: Int {
        let dateComponents = DateComponents(year: year, month: month)
        let date = Calendar.current.date(from: dateComponents)!
        return Calendar.current.component(.weekday, from: date)
    }
    private let daysOfWeek = ["일", "월", "화", "수", "목", "금", "토"]
    @Binding var disabledDaysOfWeek: Set<Int>  // 일요일과 토요일 비활성화
    private var allDays: [(id: Int, day: Int)] {
        var days: [(id: Int, day: Int)] = []
        // 첫 번째 날 이전의 빈 날짜를 추가합니다.
        for i in 0..<(firstDayWeekday - 1) {
            days.append((id: -i, day: 0)) // 여기서 고유한 ID를 부여합니다.
        }
        // 실제 날짜를 추가합니다.
        for day in 1...daysInMonth {
            days.append((id: day, day: day)) // 실제 날짜에 대해 ID를 사용합니다.
        }
        return days
    }
    private var specificDates: [Date]
    private var mandatoryDates: [Date]
    @Binding var isTap: Bool
    init(dateStrings: [String], selectedDate: Binding<Date?>, disabledDaysOfWeek: Binding<Set<Int>>, mandatoryDateStrings: [String],isTap: Binding<Bool>) {
            self._selectedDate = selectedDate
            self._disabledDaysOfWeek = disabledDaysOfWeek
            self._isTap = isTap
            self.specificDates = dateStrings.compactMap { dateString in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.date(from: dateString)
            }
            self.mandatoryDates = mandatoryDateStrings.compactMap { dateString in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.date(from: dateString)
            }
        }
    var body: some View {
        VStack {
            // 년도와 월 표시
            HStack {
                Button(action: {
                    // 이전 달로 이동
                    changeMonth(by: -1)
                }) {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(String(format: "%d년 %d월", year, month))
                    .font(.system(size: 25))
                Spacer()
                Button(action: {
                    // 다음 달로 이동
                    changeMonth(by: 1)
                }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding([.horizontal,.bottom])
            
            // 요일 헤더
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "일" ? .red : (day == "토" ? .blue : .black))
                }
            }
            // 날짜 표시
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7)) {
                ForEach(allDays, id: \.id) { item in // 여기서 .id를 사용합니다.
                    if item.day > 0 {
                        let date = getDateFor(day: item.day) // 실제 날짜를 생성합니다.
                        DayView(date: date, selectedDate: $selectedDate, today: Date(),currentMonth: $currentMonth, isTap: $isTap ,disabledDaysOfWeek: disabledDaysOfWeek, specificDates: specificDates,mandatoryDates: mandatoryDates)
                    } else {
                        Text("") // 빈 날짜를 표시합니다.
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .id(currentMonth) // 이 부분이 중요
        }
        .padding()
    }
    private func getDateFor(day: Int) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
    private func changeMonth(by amount: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: amount, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

struct DayView: View {
    var date: Date
    @Binding var selectedDate: Date?
    var today: Date
    @Binding var currentMonth: Date
    @Binding var isTap: Bool
    var disabledDaysOfWeek: Set<Int>
    var specificDates: [Date] //무족건 비활성화. 휴가
    var mandatoryDates: [Date] // 무족건 활성화 오늘 이후라면
    var body: some View {
        let dayComponent = Calendar.current.component(.day, from: date)
        let isCurrentMonth = Calendar.current.isDate(date, equalTo: currentMonth, toGranularity: .month)
        let weekday = Calendar.current.component(.weekday, from: date)
        let isWeekend = disabledDaysOfWeek.contains(weekday)
        let isSpecificDate = specificDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        let isMandatoryDate = mandatoryDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        let isDisabled = !isCurrentMonth || date < today || (!isMandatoryDate && (isSpecificDate || isWeekend))
        
        
        Text("\(dayComponent)")
            .frame(width: 30, height: 30)
            .background(
                Group {
                    if isCurrentMonth && date == selectedDate {
                        Circle().fill(Color.blue) // 선택된 날짜이고 현재 월인 경우 파란색 원
                    } else {
                        Circle().stroke(Color.clear) // 그 외 경우 투명한 원
                    }
                }
            )
            .foregroundColor(isDisabled ? .gray : (isCurrentMonth && date == selectedDate ? .white : .black))
            .onTapGesture {
                if !isDisabled {
                    isTap = true
                    selectedDate = date
                }
            }
    }
}

//struct CustomCalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        
//        CustomCalendarView(dateStrings: dateStrings)
//    }
//}
