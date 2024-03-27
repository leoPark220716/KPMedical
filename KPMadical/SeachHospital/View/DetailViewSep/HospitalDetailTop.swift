//
//  HospitalDetailTop.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct HospitalDetailTop: View{
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


