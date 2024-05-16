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
    @State var endTime2: String = ""
    @State var selectedTime: String = ""
    @State var isTap = false
    @State var isApper = false
    
    var body: some View {
        VStack {
            header
            ScrollView {
                if isApper {
                    TimeChoseScroll(
                        timeSlot: $timeSlot,
                        reservedTimes: $reservedTimes,
                        startTime1: $startTime1,
                        endTime1: $endTime1,
                        startTime2: $startTime2,
                        endTime2: $endTime2,
                        selectedTime: $selectedTime
                    )
                }
            }
            separator
            footer
        }
        .background(Color.gray.opacity(0.09))
        .onAppear {
            fetchReservations()
        }
        .navigationTitle("예약 시간을 선택해주세요")
    }
    
    private var header: some View {
        HStack {
            Text("시간 선택")
                .font(.system(size: 23))
                .bold()
            Spacer()
        }
        .padding()
    }
    
    private var separator: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
            .cornerRadius(10)
            .padding(.bottom, 10)
    }
    
    private var footer: some View {
        HStack {
            dateInfo
            Spacer()
            confirmButton
        }
    }
    
    private var dateInfo: some View {
        VStack {
            Text(router.HospitalReservationData!.date)
                .font(.system(size: 14))
                .padding(.leading)
            Text("\(selectedTime)")
                .font(.system(size: 14))
                .padding(.leading)
        }
        .padding(.leading)
    }
    
    private var confirmButton: some View {
        Text("확인")
            .bold()
            .padding()
            .font(.system(size: 20))
            .frame(width: 100, height: 40)
            .foregroundColor(Color.white)
            .background(selectedTime.isEmpty ? Color.gray.opacity(0.5) : Color.blue.opacity(0.5))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(selectedTime.isEmpty ? Color.gray.opacity(0.5) : Color.blue.opacity(0.5), lineWidth: 1)
            )
            .padding(.trailing, 40)
            .onTapGesture {
                if !selectedTime.isEmpty {
                    router.HospitalReservationData!.time = selectedTime
                    router.tabPush(to: Route.item(item: ViewPathAddress(name: "symptomEditor", page: 7, id: 7)))
                }
            }
    }
    
    private func fetchReservations() {
        requestData.GetReservations(
            token: userInfo.token,
            uid: getDeviceUUID(),
            date: router.HospitalReservationData!.date,
            staff_id: String(router.HospitalReservationData!.staff_id)
        ) { value in
            DispatchQueue.main.async {
                updateReservations(with: value)
            }
        }
    }
    
    private func updateReservations(with value: [HospitalDataManager.Reservation]) {
        reservation = value
        reservedTimes = value.map { $0.time }
        timeSlot = Int(router.HospitalReservationData!.time_slot) ?? 10
        startTime1 = getStartTime(for: .startTime1)
        endTime1 = getStartTime(for: .endTime1)
        startTime2 = getStartTime(for: .startTime2)
        endTime2 = getStartTime(for: .endTime2)
        isApper = true
    }
    
    private enum TimeType {
        case startTime1, endTime1, startTime2, endTime2
    }
    
    private func getStartTime(for type: TimeType) -> String {
        let staffId = router.HospitalReservationData!.staff_id
        let date = router.HospitalReservationData!.date
        
        switch type {
        case .startTime1:
            return router.hospital_data?.GetStartTime1(staff_id: staffId, date: date) ?? ""
        case .endTime1:
            return router.hospital_data?.GetEndTime1(staff_id: staffId, date: date) ?? ""
        case .startTime2:
            return router.hospital_data?.GetStartTime2(staff_id: staffId, date: date) ?? ""
        case .endTime2:
            return router.hospital_data?.GetEndTime2(staff_id: staffId, date: date) ?? ""
        }
    }
}
