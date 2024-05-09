//
//  HospitalDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI
import NMapsMap

struct HospitalDetailView: View {
    @EnvironmentObject var userInfo: UserInformation
    let data: hospitalParseParam
    let requestData = HospitalHTTPRequest()
    @State private var mapCoord = NMGLatLng(lat: 0.0, lng: 0.0)
    //    데이터 헨들러 디텔뷰에서 들어갈 때 해당 객체로 데이터 다 다룰듯
    //    의사 스케줄 반영에 따른 시간표 출력 배열
    @State var HospitalSchedules: [HospitalDataManager.Schedule] = []
    //    의사 프로필 데이터
    @State var DoctorProfile: [HospitalDataManager.Doctor] = []
    //    최종 저장할 때 사용할 구조체
    @EnvironmentObject var router: GlobalViewRouter
    @State var marked = false
    var body: some View {
        ZStack{
            VStack{
                ScrollView{
                    VStack{
                        if router.hospital_data!.CheckLoadingState {
                            HospitalDetailTop(
                                StartTime: data.startTiome,
                                EndTime: data.EndTime,
                                MainImage: data.MainImage)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            
                            PikerViewSelection(coord: $mapCoord,
                                               HospitalSchedules: $HospitalSchedules,
                                               DoctorProfile: $DoctorProfile)
                        }
                    }
                }.navigationTitle(router.hospital_data!.CheckLoadingState ? router.hospital_data!.HospitalDetailData.hospital.hospital_name : "")
                HStack{
                    Spacer()
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
                            router.push(baseView: .tab, to:Route.chat(data: chatParseParam(id: 0, name: router.hospital_data!.HospitalDetailData.hospital.hospital_name,hospital_id: data.hospital_id)))
                        }
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
                        .onTapGesture {
                            router.tabPush(to: Route.item(item: ViewPathAddress(name: "chooseDepartMent", page: 3, id: 3)))
                        }
                    Spacer()
                }
            }
            if !router.hospital_data!.CheckLoadingState {
                ProgressView("Loading...")
                    .scaleEffect(2) // 크기를 조정하려면 scaleEffect 사용
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5)) // 반투명 배경
                    .foregroundColor(.white)
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button(action:{
                    Task{
                        marked = await requestData.LikeHospital(token: userInfo.token, hospital_id: data.hospital_id)
                    }
                }){
                    Image(systemName: marked ? "heart.fill" : "heart")
                        .foregroundStyle(marked ? Color.red : Color.gray)
                }
            }
        }
        .onAppear{
            requestData.HospitalDetailHTTPRequest(hospitalId: data.hospital_id, token: userInfo.token, uuid: getDeviceUUID()){ data in
                router.hospital_data!.HospitalDetailData = data
                mapCoord = NMGLatLng(lat: router.hospital_data!.HospitalDetailData.hospital.y, lng: router.hospital_data!.HospitalDetailData.hospital.x)
                self.HospitalSchedules = router.hospital_data!.HospitalDetailData.doctors.flatMap { $0.main_schedules }
                self.DoctorProfile = router.hospital_data!.HospitalDetailData.doctors
                router.hospital_data!.LoadingCheck()
                DispatchQueue.main.async {
                    router.HospitalReservationData!.hospital_id = data.hospital.hospital_id
                    router.HospitalReservationData!.hospital_name = data.hospital.hospital_name
                    marked = data.hospital.marked == 1
                }
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
