//
//  HospitalDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI

struct HospitalDetailView: View {
    @State var DetailData = HospitalDataManagerClass()
    let requestData = HospitalHTTPRequest()
    @State private var selectedTab = 0
    @State private var selection = 0
    @State var selectedColor = "color"
    var colors = ["red", "green"]
    let testImage = "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_imgs/default_hospital.png"
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                AsyncImage(url: URL(string: testImage)) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    ProgressView() // 이미지 로딩 중 표시할 뷰
                }
                Text("XX 병원")
                    .font(.title)
                    .padding([.top,.leading])
                    .bold()
                HStack{
                    ForEach(["1", "2", "3", "4", "5", "6", "7"].prefix(5), id: \.self) { id in
                        let intid = Int(id)
                        if let department = Department(rawValue: intid ?? 0) {
                            Text(department.name)
                                .font(.system(size: 13))
                                .bold()
                                .padding(.horizontal, 3)
                                .padding(.vertical, 4)
                                .frame(width: 50, height: 25)
                                .background(Color("ConceptColor"))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    if ["1", "2", "3", "4", "5", "6", "7"].count > 5 {
                        Text("...")
                    }
                }
                .padding(.leading)
                Picker("Tabs",selection: $selectedTab){
                    Text("병원소개").tag(0)
                    Text("의료진").tag(1)
                }
                .pickerStyle(.segmented)
                .cornerRadius(2)
                if selectedTab == 0{
                    Text("0")
                }else{
                    Text("1")
                }
                HStack{
                    Spacer()
                    NMFMapViewRepresentable()
                        .frame(width: 300, height: 400)
                        .cornerRadius(20)
                    Spacer()
                }
            }
        }
        
    }
}



//    .onAppear{
//        requestData.HospitalDetailHTTPRequest(hospitalId: "3"){ data in
//            DetailData.hospitalData = data
//            for state in DetailData.hospitalData!.doctors{
//                print(state.name)
//            }
//        }
//    }
#Preview {
    HospitalDetailView()
}



//                            if hospitals[index] == hospitals.last {
//                                self.hospitals2 = load_HospitalData(jsonString: jsonString) ?? []
//                                print(hospitals.last ?? "default value")
//                                print("isBottom")
//                                hospitals.append(contentsOf: hospitals2)
//                            }
