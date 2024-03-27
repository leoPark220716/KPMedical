import SwiftUI

struct test: View {
    
    @State var CheckFirst: Bool = false
    @State private var selectedDate: Date = Date()
    let today = Date()
    let disabledDates: Set<Date> = [
        Calendar.current.date(from: DateComponents(year: 2024, month: 3, day: 15))!,
        Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 20))!,
           Calendar.current.date(from: DateComponents(year: 2024, month: 5, day: 25))!
        ].reduce(into: Set<Date>()) { acc, curr in
            // 날짜만 비교하기 위해 DateComponents를 사용하여 시간을 제거
            if let dateOnly = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: curr )) {
                acc.insert(dateOnly)
            }
        }
    var body: some View {
        VStack{
            DatePicker("예약할 날짜를 선택해 주세요.", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .onChange(of: selectedDate){
                    
                    print(formatDate(selectedDate))
                }
                .frame(maxHeight: 400)
                .padding(.horizontal)
            Spacer()
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                .cornerRadius(10)
                .padding(.bottom,10)
            HStack{
                Text(formatDate(selectedDate))
                    .font(.system(size: 14))
                    .padding(.leading)
                Spacer()
                Text("선택완료")
                    .bold()
                    .padding()
                    .font(.system(size: 20))
                    .frame(width: 150)
                    .foregroundColor(Color.white)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.trailing)
            }
        }
    }
    func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
