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
    @ObservedObject var userInfo: UserInformation
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
    //    최종 저장할 때 사용할 구조체
    @State var info = reservationInfo()
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    VStack{
                        if hospitalDataHandler.CheckLoadingState{
                            HospitalDetailTop(HospitalDetailData: $hospitalDataHandler.HospitalDetailData,StartTime: $StartTime,EndTime: $EndTime,MainImage: $MainImage)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            
                            PikerViewSelection(HospitalDetailData: $hospitalDataHandler.HospitalDetailData, coord: $mapCoord, HospitalSchedules: $HospitalSchedules,DoctorProfile: $DoctorProfile)
                        }
                    }
                }.navigationTitle(hospitalDataHandler.CheckLoadingState ? hospitalDataHandler.HospitalDetailData.hospital.hospital_name : "")
                HStack{
                    Spacer()
                    //            NavigationLink(destination: Chat()) {
                    NavigationLink(value: HospitalDataHandler.NavigationTarget.counsel){
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
                                print("병원 아이디")
                                print( info.hospital_id)
                                router.push(baseView: .tab, to:Route.chat(data: parseParam(id: 0, name: hospitalDataHandler.HospitalDetailData.hospital.hospital_name,hospital_id: info.hospital_id)))
                                
                            
                            }
                    }
                    NavigationLink(value: HospitalDataHandler.NavigationTarget.selectDepartment){
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
                    .navigationDestination(for: HospitalDataHandler.NavigationTarget.self){ value in
                        switch value{
                        case .counsel:
                            EmptyView()
//                            print("asdf")
                        case .selectDepartment:
                            ChooseDepartment(path: $path, userInfo: userInfo, HospitalInfo: hospitalDataHandler, info: $info)
                        }
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
                info.hospital_id = HospitalId
                info.hospital_name = data.hospital.hospital_name
            }
        }
    }
}


//    전화번호 - 삽입
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
