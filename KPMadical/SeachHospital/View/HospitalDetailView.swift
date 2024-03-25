//
//  HospitalDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI
import NMapsMap

struct HospitalDetailView: View {
    @ObservedObject var userInfo: UserObservaleObject
    @Binding var StartTime: String
    @Binding var EndTime: String
    @Binding var HospitalId: Int
    @Binding var MainImage: String
    let requestData = HospitalHTTPRequest()
    @State private var mapCoord = NMGLatLng(lat: 0.0, lng: 0.0)
    @State var HospitalDetailData = HospitalDataManager.HospitalDataClass()
//    의사 스케줄 반영에 따른 시간표 출력 배열
    @State var HospitalSchedules: [HospitalDataManager.Schedule] = []
    var colors = ["red", "green"]
    let testImage = "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_imgs/default_hospital.png"
    var body: some View {
        ScrollView{
            VStack{
                HospitalDetail_Top(HospitalDetailData: $HospitalDetailData,StartTime: $StartTime,EndTime: $EndTime,MainImage: $MainImage)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                    .cornerRadius(10)
                    .padding(.horizontal)
                PikerView_Selection(HospitalDetailData: $HospitalDetailData,coord: $mapCoord, HospitalSchedules: $HospitalSchedules)
            }
            .onAppear{
                requestData.HospitalDetailHTTPRequest(hospitalId: HospitalId, token: userInfo.token, uuid: getDeviceUUID()){ data in
                    self.HospitalDetailData = data
                    mapCoord = NMGLatLng(lat: HospitalDetailData.hospital.y, lng: HospitalDetailData.hospital.x)
                    print(mapCoord.lat)
                    print(mapCoord.lng)
                }
            }
        }
        .navigationTitle(HospitalDetailData.hospital.hospital_name)
    }
}
struct HospitalDetail_Top: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @Binding var StartTime: String
    @Binding var EndTime: String
    @Binding var MainImage: String
    @State var WorkingState: Bool?
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
            WorkingState = checkTimeIn(startTime: StartTime, endTime: EndTime)
        }
    }
}
struct PikerView_Selection: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @State private var selection = Selection.Intro
    @Binding var coord: NMGLatLng
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
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
                DoctorListView()
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
    let days = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
    let hours = ["10:00 ~ 21:00", "10:00 ~ 21:00", "10:00 ~ 21:00", "10:00 ~ 21:00", "10:00 ~ 21:00", "10:00 ~ 21:00", "휴무"]
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
    var body: some View{
        Text("진료시간")
            .bold()
            .padding(.leading,30)
            .padding(.top,8)
        VStack(alignment: .leading, spacing: 10) {
            ForEach(0..<days.count, id: \.self) { index in
                HStack {
                    Spacer()
                    Text(days[index])
                        .font(.system(size: 13))
                        .foregroundColor(index == 6 ? .red : .black) // 일요일은 빨간색으로 표시
                        .frame(width: 50, alignment: .leading) // 요일 텍스트의 너비를 고정하고 왼쪽 정렬
                    Spacer()
                    Text(hours[index])
                        .font(.system(size: 13))
                        .foregroundColor(index == 6 ? .red : .black) // 일요일은 빨간색으로 표시
                        .frame(width: 110, alignment: .center) // 시간 텍스트의 너비를 고정하고 오른쪽 정렬
                    Spacer()
                }
                .frame(maxWidth: .infinity) // HStack을 최대 너비로 설정
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
        .padding(.horizontal)
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
struct DoctorListView: View{
    var body: some View{
        Text("2")
    }
}
