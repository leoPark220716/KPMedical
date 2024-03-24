//
//  HospitalDetailView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI
import NMapsMap

struct HospitalDetailView: View {
    
    @State var DetailData = HospitalDataManagerClass()
    let requestData = HospitalHTTPRequest()
    @State private var coord = NMGLatLng(lat: 37.5665, lng: 126.9780)
    var colors = ["red", "green"]
    let testImage = "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_imgs/default_hospital.png"
    var body: some View {
        ScrollView{
            VStack{
                HospitalDetail_Top()
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                    .cornerRadius(10)
                PikerView_Selection()
            }
        }
        .navigationTitle("xx병원")
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
struct HospitalDetail_Top: View{
    let testImage = "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_imgs/default_hospital.png"
    @State var WorkingState: Bool?
    var body: some View{
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
                .font(.system(size: 20))
                .padding([.top,.leading])
                .bold()
            HStack{
                ForEach(["1", "2", "3", "4", "5", "6", "7"].prefix(4), id: \.self) { id in
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
                if ["1", "2", "3", "4", "5", "6", "7"].count > 4 {
                    //                    Text("전체보기")
                    //                        .font(.system(size: 13))
                    //                        .padding(.trailing, 10)
                    //                        .padding(.top, 7)
                    //                        .foregroundColor(.blue)
                }
            }
            .padding(.leading)
            .padding(.bottom,2)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                .cornerRadius(10)
            HStack{
                Image(systemName: "stopwatch")
                    .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
                    .font(.system(size: 15))
                    .bold()
                Text(WorkingState ?? false ? "진료중" : "진료종료")
                    .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
                    .font(.system(size: 15))
                    .bold()
                Text(WorkingState ?? false ? "\("10:00")~\("21:00")" : "")
                    .font(.system(size: 15))
            }
            .padding(.leading)
            .padding(.vertical,4)
        }
        .padding(.top)
        .background(Color.white)
        .onAppear{
            WorkingState = checkTimeIn(startTime: "10:00", endTime: "21:00")
        }
    }
}
struct PikerView_Selection: View{
    @State private var selection = Selection.Intro
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                VStack{
                    Text("병원소개")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .Intro ? .black : .gray)
                    Rectangle()
                        .frame(height: 2) // 전체 너비의 40%로 설정
                        .foregroundColor(selection == .Intro ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.leading,4)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .Intro
                }
                VStack{
                    Text("의료진")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .doc ? .black : .gray)

                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selection == .doc ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.trailing,4)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .doc
                }
            }
            switch selection {
            case .Intro:
                IntroView()
            case .doc:
                DoctorListView()
            }
        }
        .background(Color.white)
    }
    enum Selection {
        case Intro, doc
    }
}
struct IntroView: View{
    var body: some View{
        Text("진료시간")
            .bold()
            .padding(.leading)
        
    }
}
struct DoctorListView: View{
    var body: some View{
        Text("2")
    }
}
