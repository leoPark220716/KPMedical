//
//  FindHosptialItem.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import SwiftUI

struct FindHosptialItem: View{
    @Binding var hospital: HospitalDataManager.Hospitals
//    병원 관리 데이터 (예약 전체적인 정보 담겨있음)
    @State var WorkingState: Bool?
    var body: some View{
        VStack {
            HStack{
                VStack(alignment: .leading){
                    Text(hospital.hospital_name)
                        .font(.headline)
                        .bold()
                    Text(hospital.location)
                        .font(.subheadline)
                        .bold()
                        HStack{
                            Image(systemName: "stopwatch")
                                .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
                                .font(.subheadline)
                                .bold()
                            Text(WorkingState ?? false ? "진료중" : "진료종료")
                                .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
                                .font(.subheadline)
                                .bold()
                            Text(WorkingState ?? false ? "\(hospital.start_time)~\(hospital.end_time)" : "")
                                .font(.subheadline)
                        }
                        .padding(.top, 2)
                    HStack {
                        ForEach(hospital.department_id.prefix(4), id: \.self) { id in
                            let intid = Int(id)
                            if let department = Department(rawValue: intid ?? 0) {
                                Text(department.name)
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.blue)
                            }
                        }
                        if hospital.department_id.count > 4 {
                            Text("...")
                        }
                    }
                }
                Spacer()
                AsyncImage(url: URL(string: hospital.icon)) { image in
                    image.resizable() // 이미지를 resizable로 만듭니다.
                         .aspectRatio(contentMode: .fit) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
                } placeholder: {
                    ProgressView() // 이미지 로딩 중 표시할 뷰
                }
                .frame(width: 90, height: 90) // 여기에서 이미지의 프레임 크기를 지정합니다.
                .cornerRadius(25) // 이미지의 모서리를 둥글게 합니다.
                .padding() // 주변에 패딩을 추가합니다.
                .shadow(radius: 10, x: 5, y: 5) // 그림자 효과를 추가합니다.
            }
        }
        .padding(.vertical,5)
        .onAppear(){
            WorkingState = checkTimeIn(startTime: hospital.start_time, endTime: hospital.end_time)
        }
    }
}

