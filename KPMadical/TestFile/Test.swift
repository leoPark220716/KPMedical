import SwiftUI

struct TimeChoseScroll: View {
    // 시간 슬롯 및 예약된 시간들의 데이터
    @Binding var timeSlot: Int
    @Binding var reservedTimes: [String]
    @Binding var startTime1: String
    @Binding var endTime1: String
    @Binding var startTime2: String
    @Binding var endTime2: String
    @Binding var selectedTime: String
    var body: some View {
        VStack{
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    // 오전 시간대
                    timeSlotsView(start: startTime1, end: endTime1, slot: timeSlot, reserved: reservedTimes,selectedTime: $selectedTime)
                    // 오후 시간대
                    timeSlotsView(start: startTime2, end: endTime2, slot: timeSlot, reserved: reservedTimes,selectedTime: $selectedTime)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }
    
    func timeSlotsView(start: String, end: String, slot: Int, reserved: [String],selectedTime: Binding<String>) -> some View {
        let timeSlots = generateTimeSlots(start: start, end: end, slot: slot)
        return ForEach(0..<timeSlots.count, id: \.self) { index in
            let hourSlot = timeSlots[index]
            VStack(alignment: .leading) {
                Text(hourSlot.hourLabel)
                    .font(.system(size: 20))
                    .bold()
                WrapHStack(items: hourSlot.times, reserved: reserved, selectedTime: selectedTime)
                    .padding(.bottom,30)
            }
        }
    }
    
    func generateTimeSlots(start: String, end: String, slot: Int) -> [HourTimeSlot] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        var slots = [HourTimeSlot]()
        var currentTime = dateFormatter.date(from: start)!
        let endTimeDate = dateFormatter.date(from: end)!
        
        var currentHourSlots = [String]()
        var currentHourLabel = ""
        
        while currentTime < endTimeDate {
            let timeString = dateFormatter.string(from: currentTime)
            let hourLabel = timeLabel(from: currentTime)
            
            if currentHourLabel != hourLabel {
                if !currentHourSlots.isEmpty {
                    slots.append(HourTimeSlot(hourLabel: currentHourLabel, times: currentHourSlots))
                }
                currentHourLabel = hourLabel
                currentHourSlots = [timeString]
            } else {
                currentHourSlots.append(timeString)
            }
            
            currentTime = Calendar.current.date(byAdding: .minute, value: slot, to: currentTime)!
        }
        
        // Add last hour slots if any
        if !currentHourSlots.isEmpty {
            slots.append(HourTimeSlot(hourLabel: currentHourLabel, times: currentHourSlots))
        }
        return slots
    }
    
    func timeLabel(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date)
        let hourInt = Int(hour)!
        return hourInt <= 12 ? "오전 \(hourInt)시" : "오후 \(hourInt-12)시"
    }
}
struct HourTimeSlot {
    let hourLabel: String
    let times: [String]
}

struct WrapHStack: View {
    var items: [String]
    var reserved: [String]
    @Binding var selectedTime: String
    var body: some View {
        HStack { // HStack을 추가하여 중앙 정렬
            Spacer()
            let columns = [GridItem(.adaptive(minimum: 70))]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(items, id: \.self) { time in
                    if !reserved.contains(time) {
                        Text(time)
                            .bold()
                            .font(.system(size: 29))
                            .padding()
                            .frame(width: 75, height: 30)
                            .background(Color.white)
                            .foregroundColor(selectedTime == time ? Color.blue : Color.black)
                            .cornerRadius(10)
                            .minimumScaleFactor(0.5) // 텍스트 크기가 잘리지 않도록 조정
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedTime == time ? Color.blue : Color.black, lineWidth: 1)
                            )
                            .onTapGesture {
                                self.selectedTime = time // 사용자가 탭할 때 selectedTime을 업데이트합니다.
                            }
                    }
                }
            }
            Spacer()
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        Content_View()
//    }
//}
