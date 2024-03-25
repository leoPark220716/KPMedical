//
//  FindHospitalView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//
import SwiftUI
import CoreLocation
struct FindHospitalView: View {
//    유저 관리
    @ObservedObject var userInfo: UserObservaleObject
    //    병원 배열
    @State var hospitals: [HospitalDataManager.Hospitals] = []
    @State private var departSheetShow = false
    @StateObject private var viewModel = TabViewModel()
    let requestList = HospitalHTTPRequest()
    @State var selectedDepartment: Department?
    @EnvironmentObject var router: GlobalViewRouter
    @State var long = ""
    @State var late = ""
    @State var department_id = ""
    @State var keyword = ""
    @State var order = "name"
    //    좌표 찾기 객체, 해당 객체 안에서 Naver API 사용하여 좌표를 주소로 반환
    @StateObject private var locationService = LocationService()
    @State private var selectedNumber = 0
    @State private var userLocation: CLLocationCoordinate2D?
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
                NavigationLink(destination: KeywordSearch(userInfo: userInfo)){
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text("찾고있는 병원을 검색하세요.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.trailing,120)
                    }
                    .padding(.horizontal, 10)
                    .frame(height: 40)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                VStack{
                    HStack{
                        HStack{
                            Image(systemName: "mappin.and.ellipse")
                                .padding(.leading,20)
                                .foregroundColor(.pink)
                            if let addres = locationService.address_Naver{
                                Text("\(addres)")
                                    .font(.system(size: 14))
                            }else{
                                Text("주소를 찾을수 없습니다.")
                                    .font(.system(size: 14))
                            }
//                            Text("수정")
//                                .font(.system(size: 12))
//                                .foregroundColor(.blue)
                        }
                        .padding(.top,10)
                        Spacer()
                    }
                    HStack{
                        Picker("Tabs",selection: $viewModel.selectedTab){
                            Text("전체").tag(0)
                            Text("거리순").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.leading)
                        .frame(width: 150)
                        Spacer()
                        HStack{
                            Text(selectedDepartment?.name ?? "진료과")
                                .font(.system(size: 13))
                                .padding(.leading,10)
                                .padding(.vertical, 4)
                                .foregroundColor(.blue)
                            Image(systemName: "control")
                                .rotationEffect(.degrees(180))
                                .font(.system(size: 10))
                                .padding(.trailing,7)
                        }
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.trailing)
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 10, y: 10)
                        .onTapGesture {
                            departSheetShow.toggle()
                        }
                        .sheet(isPresented: $departSheetShow){
                            departmentsChooseSheetView(selectedDepartment: $selectedDepartment, onDepartmentSelect: { department in
                                self.selectedDepartment = department
                                viewModel.selectedTab = viewModel.selectedTab
                                department_id = String(selectedDepartment!.rawValue)
                                print("id = \(selectedDepartment?.rawValue ?? -1)")
                            })
                            .presentationDetents([.height(400),.medium,.large])
                            .presentationDragIndicator(.automatic)
                        }
                    }
                }
                //                리스트뷰 병원 나열
                List(hospitals.indices, id: \.self) {index in
                    FindHosptialItem(hospital: $hospitals[index])
                    //                            패이징 처리 여기서 하면됨
                    //                    HospitalDetailView 맨 하단에 코드있음
                        .background(
                            NavigationLink("",destination : HospitalDetailView(userInfo:userInfo,StartTime:$hospitals[index].start_time,EndTime:$hospitals[index].end_time, HospitalId: $hospitals[index].hospital_id, MainImage: $hospitals[index].icon))
                                .opacity(0)
                        )
                }
                .listStyle(InsetListStyle())
                .padding(.top, 10)
            }
            .onAppear{
                locationService.requestLocation()
                requestList.CallHospitalList(orderBy: "name", x: "", y: "", keyword: keyword, department_id: department_id){ result in
                    print("isChange?")
                    switch result {
                    case .success(let hospitals):
                        self.hospitals = hospitals
                    case .failure(let error):
                        print("Failed Recevied Hospital: \(error)")
                    }
                }
            }
            .onReceive(viewModel.$selectedTab){ newSelectedTab in
                print("selctedTeb Check : \(newSelectedTab)")
                self.hospitals = []
                if newSelectedTab == 0{
                    order = "name"
                }else if newSelectedTab == 1{
                    order = "distance"
                }
                if order == "name"{
                    requestList.CallHospitalList(orderBy: order, x: "", y: "", keyword: keyword, department_id: department_id){ result in
                        print("isChange?")
                        switch result {
                        case .success(let hospitals):
                            self.hospitals = hospitals
                        case .failure(let error):
                            print("Failed Recevied Hospital: \(error)")
                        }
                    }
                }else{
                    requestList.CallHospitalList(orderBy: order, x: locationService.longitude ?? "123.123", y: locationService.latitude ?? "123.123", keyword: keyword, department_id: department_id){ result in
                        print("isChange?")
                        switch result {
                        case .success(let hospitals):
                            self.hospitals = hospitals
                        case .failure(let error):
                            print("Failed Recevied Hospital: \(error)")
                        }
                    }
                }
            }
            .background(Color("backColor"))
            .navigationTitle("어떤 병원을 찾고 있으세요?")
            .navigationBarTitleDisplayMode(.inline)
            //            뒤로가기
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button(action:{
                        router.currentView = .tab
                    }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
            //            여기까지
        }
    }
    
}
//#Preview {
//    FindHospitalView()
//}
enum Tab_findHospital {
    case all
    case location
}
