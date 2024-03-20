//
//  FindHospitalView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import SwiftUI

struct FindHospitalView: View {
//    병원 배열
    @State var hospitals: [Hospitals] = []
    @State private var departSheetShow = false
    let requestList = HospitalHTTPRequest()
    @State var selectedDepartment: Department?
    @State private var selectedTab = 0
    var body: some View {
        NavigationStack {
            VStack(spacing: 0){
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
                VStack{
                    HStack{
                        HStack{
                            Image(systemName: "mappin.and.ellipse")
                                .padding(.leading,20)
                                .foregroundColor(.pink)
                            Text("xxx시 xx구 xx동")
                                .font(.system(size: 14))
                            Text("수정")
                                .font(.system(size: 12))
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                        .padding(.top,10)
                        Spacer()
                    }
                    HStack{
                        Picker("Tabs",selection: $selectedTab){
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
//                        테스트까지 주석 여기부터
                        .sheet(isPresented: $departSheetShow){
                            departmentsChooseSheetView(selectedDepartment: $selectedDepartment, onDepartmentSelect: { department in
                                self.selectedDepartment = department
                                print("id = \(selectedDepartment?.rawValue ?? -1)")
                            })
                            .presentationDetents([.height(400),.medium,.large])
                            .presentationDragIndicator(.automatic)
                        }
//                        여기까지
                    }
                }
                //                리스트뷰
                List(hospitals.indices, id: \.self) {index in
                    FindHosptialItem(hospital: $hospitals[index])
                    //                    맨 하단 이벤트
                        .onAppear {
                            //                            패이징 처리 여기서 하면됨
                            //                            if hospitals[index] == hospitals.last {
                            //                                self.hospitals2 = load_HospitalData(jsonString: jsonString) ?? []
                            //                                print(hospitals.last ?? "default value")
                            //                                print("isBottom")
                            //                                hospitals.append(contentsOf: hospitals2)
                            //                            }
                        }
                        .background(
                            NavigationLink("",destination : Chat())
                                .opacity(0)
                        )
                }
                .onAppear {
                    requestList.CallHospitalList{ result in
                        switch result {
                        case .success(let hospitals):
                            self.hospitals = hospitals
                        case .failure(let error):
                            print("Failed Recevied Hospital: \(error)")
                        }
                    }
                    //                    self.hospitals = load_HospitalData(jsonString: jsonString) ?? []
                }
                .listStyle(InsetListStyle())
                .padding(.top, 10)
            }
            .background(Color("backColor"))
            .navigationTitle("어떤 병원을 찾고 있으세요?")
        }
    }
    
    func load_HospitalData(jsonString: String) -> [Hospitals]?{
        guard let jsonData = jsonString.data(using: .utf8) else{
            return nil
        }
        do{
            let hospitalList = try JSONDecoder().decode(HospitalData.self, from: jsonData)
            return hospitalList.data
        } catch {
            print("Err \(error)")
            return nil
        }
    }
}
#Preview {
    FindHospitalView()
}
enum Tab_findHospital {
    case all
    case location
}
