//
//  ReservationDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import SwiftUI
import NMapsMap
struct ReservationDetailView: View {
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @State var responseOk: Bool = false
    @State private var mapCoord = NMGLatLng(lat: 0.0, lng: 0.0)
    let requestData = HospitalHTTPRequest()
    @ObservedObject var hospitalDataHandler = HospitalDataHandler() // 변경됨
//    @Binding var item: reservationDataHandler.reservationAr
//    @State var HospitalId: Int
//    @State var reservation_id: Int
    let data: ReservationParseParam
    let request = ReservationHttpRequest()
    var body: some View {
        ZStack{
            if responseOk{
                VStack{
                    ScrollView{
                        VStack{
                            HStack{
                                Text("예약정보")
                                    .font(.title)
                                    .bold()
                                    .padding(.leading)
                                Spacer()
                            }
                            HStack{
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color .blue)
                                    .font(.system(size: 20))
                                    .bold()
                                    .padding(.leading)
                                Text("확정된 예약입니다.")
                                    .foregroundColor(Color .blue)
                                    .bold()
                                Spacer()
                            }
                            .padding(.top,5)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            HStack{
                                Text("병원")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.gray)
                                    .bold()
                                    .padding(.leading,23)
                                Spacer()
                                Text(data.item.hospital_name)
                                    .font(.system(size: 15))
                                    .bold()
                                    .padding(.trailing,23)
                            }
                            .padding(.top)
                            .padding(.bottom,10)
                            HStack{
                                Text("일정")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.gray)
                                    .bold()
                                    .padding(.leading,23)
                                Spacer()
                                Text("\(data.item.date) \(data.item.time)")
                                    .font(.system(size: 15))
                                    .bold()
                                    .padding(.trailing,23)
                            }
                            .padding(.bottom,10)
                            HStack{
                                Text("의사명")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.gray)
                                    .bold()
                                    .padding(.leading,23)
                                Spacer()
                                Text(data.item.staff_name)
                                    .font(.system(size: 15))
                                    .bold()
                                    .padding(.trailing,23)
                            }
                            .padding(.bottom,10)
                            HStack{
                                Text("환자명")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.gray)
                                    .bold()
                                    .padding(.leading,23)
                                Spacer()
                                Text(data.item.patient_name)
                                    .font(.system(size: 15))
                                    .bold()
                                    .padding(.trailing,23)
                            }
                            .padding(.bottom,10)
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                                .cornerRadius(10)
                                .padding(.horizontal)
                            HStack{
                                Text("위치")
                                    .bold()
                                    .padding(.leading,30)
                                    .padding(.top,8)
                                Spacer()
                            }
                            HStack{
                                Text(hospitalDataHandler.HospitalDetailData.hospital.location)
                                    .font(.system(size: 13))
                                    .padding(.leading,30)
                                    .padding(.top,8)
                                Spacer()
                            }
                            HStack {
                                Spacer() // 좌측에 공간 추가
                                NMFMapViewRepresentable(coord: $mapCoord)
                                    .frame(width: 350, height: 160) // 원하는 크기 설정
                                    .cornerRadius(20)
                                    .onAppear{
                                        DispatchQueue.main.async{
                                        mapCoord = NMGLatLng(lat: hospitalDataHandler.HospitalDetailData.hospital.y, lng: hospitalDataHandler.HospitalDetailData.hospital.x)
                                        }
                                    }
                                Spacer() // 우측에 공간 추가
                            }
                            HStack{
                                let numerString = formatKoreanPhoneNumber(hospitalDataHandler.HospitalDetailData.hospital.phone)
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
                        }
                    }
                    HStack{
                        Spacer()
                        Text("예약취소")
                            .padding()
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color.black)
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(5)
                            .bold()
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            ).onTapGesture {
                                responseOk = false
                                request.cancelReservationById(token: userInfo.token, id: data.reservation_id) { Bool in
                                    if Bool{
                                        DispatchQueue.main.async{
                                            router.goBack()
                                        }
                                    }
                                }
                            }
                        
                        Text("확인")
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
                                DispatchQueue.main.async{
                                    router.goBack()
                                }
                            }
                        Spacer()
                    }
                }.navigationTitle(hospitalDataHandler.HospitalDetailData.hospital.hospital_name)
                    .navigationBarTitleDisplayMode(.inline)
            }
            if !responseOk {
                ProgressView("Loading...")
                    .scaleEffect(2) // 크기를 조정하려면 scaleEffect 사용
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5)) // 반투명 배경
                    .foregroundColor(.white)
            }
        }
        .onAppear{
            requestData.HospitalDetailHTTPRequest(hospitalId: data.HospitalId, token: userInfo.token, uuid: getDeviceUUID()){ data in
                self.hospitalDataHandler.HospitalDetailData = data
                responseOk = true
            }
        }
    }
}

//#Preview {
//    ReservationDetailView()
//}
