//
//  HospitalDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI
import NMapsMap

struct HospitalDetailView: View {
    @Binding var path: NavigationPath
    @ObservedObject var userInfo: UserObservaleObject
    @State var StartTime: String
    @State var EndTime: String
    @State var HospitalId: Int
    @State var MainImage: String
    let requestData = HospitalHTTPRequest()
    @State private var mapCoord = NMGLatLng(lat: 0.0, lng: 0.0)
//    데이터 헨들러 디텔뷰에서 들어갈 때 해당 객체로 데이터 다 다룰듯
    @ObservedObject var hospitalDataHandler = HospitalDataHandler() // 변경됨
    //    의사 스케줄 반영에 따른 시간표 출력 배열
    @State var HospitalSchedules: [HospitalDataManager.Schedule] = []
    //    의사 프로필 데이터
    @State var DoctorProfile: [HospitalDataManager.Doctor] = []
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    VStack{
                        if hospitalDataHandler.CheckLoadingState{
                            HospitalDetail_Top(HospitalDetailData: $hospitalDataHandler.HospitalDetailData,StartTime: $StartTime,EndTime: $EndTime,MainImage: $MainImage)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            
                            PikerView_Selection(HospitalDetailData: $hospitalDataHandler.HospitalDetailData, coord: $mapCoord, HospitalSchedules: $HospitalSchedules,DoctorProfile: $DoctorProfile)
                        }
                    }
                }.navigationTitle(hospitalDataHandler.CheckLoadingState ? hospitalDataHandler.HospitalDetailData.hospital.hospital_name : "")
                HStack{
                    Spacer()
        //            NavigationLink(destination: Chat()) {
                        Text("상담하기")
                            .padding()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.blue.opacity(0.5))
                            .background(Color.white)
                            .cornerRadius(5)
                            .bold()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                            )
                            .onTapGesture {
                                path = .init()
                            }
        //            }
                    NavigationLink(destination: ChooseDepartment(userInfo: userInfo, HospitalInfo: hospitalDataHandler)){
                        Text("예약하기")
                            .padding()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background(Color.blue.opacity(0.5))
                            .cornerRadius(5)
                            .bold()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
            if !hospitalDataHandler.CheckLoadingState {
                    ProgressView("Loading...")
                        .scaleEffect(2) // 크기를 조정하려면 scaleEffect 사용
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5)) // 반투명 배경
                        .foregroundColor(.white)
                }
        }
        .onAppear{
            requestData.HospitalDetailHTTPRequest(hospitalId: HospitalId, token: userInfo.token, uuid: getDeviceUUID()){ data in
                self.hospitalDataHandler.HospitalDetailData = data
                mapCoord = NMGLatLng(lat: hospitalDataHandler.HospitalDetailData.hospital.y, lng: hospitalDataHandler.HospitalDetailData.hospital.x)
                self.HospitalSchedules = hospitalDataHandler.HospitalDetailData.doctors.flatMap { $0.main_schedules }
                self.DoctorProfile = hospitalDataHandler.HospitalDetailData.doctors
                hospitalDataHandler.LoadingCheck()
            }
        }
        .onDisappear{
            path = .init()
        }
    }
}
struct HospitalDetail_Top: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @Binding var StartTime: String
    @Binding var EndTime: String
    @Binding var MainImage: String
    @State var WorkingState: Bool?
    let timeManager = TimeManager()
    var body: some View{
        VStack(alignment: .leading){
            ZStack {
                AsyncImage(url: URL(string: MainImage)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    ProgressView() // 이미지 로딩 중 표시할 뷰
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Text(HospitalDetailData.hospital.hospital_name)
                .font(.system(size: 20))
                .padding([.top,.leading])
                .bold()
            HStack{
                Image(systemName: "stopwatch")
                    .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
                    .font(.system(size: 15))
                    .bold()
                Text(WorkingState ?? false ? "진료중" : "진료종료")
                    .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
                    .font(.system(size: 15))
                    .bold()
                Text(WorkingState ?? false ? "\(StartTime)~\(EndTime)" : "")
                    .font(.system(size: 15))
            }
            .padding(.leading)
            .padding(.vertical,4)
            HStack{
                ForEach(HospitalDetailData.hospital.department_id.prefix(4), id: \.self) { id in
                    let intid = Int(id)
                    if let department = Department(rawValue: intid ?? 0) {
                        Text(department.name)
                            .font(.system(size: 13))
                            .bold()
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color("ConceptColor"))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
                if HospitalDetailData.hospital.department_id.count > 4 {
                    Text("전체보기")
                        .font(.system(size: 13))
                        .padding(.trailing, 10)
                        .padding(.top, 7)
                        .foregroundColor(.blue)
                }
            }
            .padding(.leading)
            .padding(.bottom,2)
        }
        .padding(.top)
        .background(Color.white)
        .onAppear{
            WorkingState = timeManager.checkTimeIn(startTime: StartTime, endTime: EndTime)
        }
    }
}
struct PikerView_Selection: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @State private var selection = Selection.Intro
    @Binding var coord: NMGLatLng
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
    @Binding var DoctorProfile: [HospitalDataManager.Doctor]
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                VStack{
                    Text("병원소개")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity,alignment: .center) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .Intro ? .black : .gray)
                        .padding(.vertical,4)
                    Rectangle()
                        .frame(height: 2) // 전체 너비의 40%로 설정
                        .foregroundColor(selection == .Intro ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .Intro
                }
                VStack{
                    Text("의료진")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity,alignment: .center) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .doc ? .black : .gray)
                        .padding(.vertical,4)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selection == .doc ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .doc
                }
            }
            switch selection {
            case .Intro:
                IntroView(HospitalDetailData: $HospitalDetailData,coord: $coord, HospitalSchedules: $HospitalSchedules)
            case .doc:
                DoctorListView(DoctorProfile: $DoctorProfile)
            }
        }
    }
    enum Selection {
        case Intro, doc
    }
}
struct IntroView: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @Binding var coord: NMGLatLng
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
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
            let numerString = formatKoreanPhoneNumber(HospitalDetailData.hospital.phone)
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
        Text(HospitalDetailData.hospital.location)
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
struct DoctorListView: View{
    @Binding var DoctorProfile: [HospitalDataManager.Doctor]
    var body: some View{
        ForEach(DoctorProfile.indices, id: \.self) { item in
            DoctorItemView(DoctorProfile: $DoctorProfile[item])
                .padding(.leading)
        }
    }
}
//    전화번호 파싱
func formatKoreanPhoneNumber(_ numberString: String) -> String {
    let cleanPhoneNumber = numberString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    
    // 지역번호가 있는 경우
    if cleanPhoneNumber.count == 9 { // 지역번호 + 7자리 번호
        let index = cleanPhoneNumber.index(cleanPhoneNumber.startIndex, offsetBy: 2)
        return "\(cleanPhoneNumber.prefix(2))-\(cleanPhoneNumber[index...].prefix(3))-\(cleanPhoneNumber.suffix(4))"
    } else if cleanPhoneNumber.count == 10 { // 02 지역번호 또는 휴대폰 번호
        if cleanPhoneNumber.hasPrefix("02") { // 서울 지역번호
            let index = cleanPhoneNumber.index(cleanPhoneNumber.startIndex, offsetBy: 2)
            return "\(cleanPhoneNumber.prefix(2))-\(cleanPhoneNumber[index...].prefix(4))-\(cleanPhoneNumber.suffix(4))"
        } else { // 다른 지역번호 또는 휴대폰 번호
            let index = cleanPhoneNumber.index(cleanPhoneNumber.startIndex, offsetBy: 3)
            return "\(cleanPhoneNumber.prefix(3))-\(cleanPhoneNumber[index...].prefix(3))-\(cleanPhoneNumber.suffix(4))"
        }
    } else if cleanPhoneNumber.count == 11 { // 휴대폰 번호
        let index = cleanPhoneNumber.index(cleanPhoneNumber.startIndex, offsetBy: 3)
        return "\(cleanPhoneNumber.prefix(3))-\(cleanPhoneNumber[index...].prefix(4))-\(cleanPhoneNumber.suffix(4))"
    } else { // 다른 형식의 번호
        return numberString // 원본 번호를 그대로 반환
    }
}
func currentWeekday() -> Int {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul")! // 한국 시간대 설정
    let weekDay = calendar.component(.weekday, from: Date())
    // Swift에서의 weekDay는 일요일을 1로 시작합니다. 월요일을 1로 조정합니다.
    return weekDay == 1 ? 7 : weekDay - 1 // 일요일을 7로, 나머지는 1 (월요일)부터 6 (토요일)로 조정
}