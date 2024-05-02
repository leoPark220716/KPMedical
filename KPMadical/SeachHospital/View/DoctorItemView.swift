//
//  DoctorItemView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct DoctorItemView: View {
    var DoctorProfile: HospitalDataManager.Doctor
    var TimeHelper = TimeManager()
    @State var WorkingState: Bool?
    @State var CheckIsEmpty = true
    var body: some View{
        VStack {
            if !CheckIsEmpty{
                HStack{
                    VStack(alignment: .leading){
                        Text(DoctorProfile.name)
                            .font(.headline)
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
                            Text(WorkingState ?? false ? "\(DoctorProfile.main_schedules[0].startTime1)~\(DoctorProfile.main_schedules[0].endTime2)" : "")
                                .font(.subheadline)
                        }
                        .padding(.top, 2)
                        HStack {
                            ForEach(DoctorProfile.department_id.prefix(4), id: \.self) { id in
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
                            if DoctorProfile.department_id.count > 4 {
                                Text("...")
                            }
                        }
                    }
                    .padding()
                    Spacer()
                    AsyncImage(url: URL(string: DoctorProfile.icon)) { image in
                        image.resizable() // 이미지를 resizable로 만듭니다.
                            .aspectRatio(contentMode: .fill) // 이미지를 채우는 내용에 맞게 조정합니다. (원형에 맞추기 위해)
                    } placeholder: {
                        ProgressView() // 이미지 로딩 중 표시할 뷰
                    }
                    .frame(width: 100, height: 100) // 여기에서 이미지의 프레임 크기를 지정합니다. 동일한 너비와 높이를 주어 원형을 만듭니다.
                    .clipShape(Circle()) // 이미지를 원형으로 자릅니다.
                    .shadow(radius: 10, x: 5, y: 5) // 그림자 효과를 추가합니다.
                    .padding() // 주변에 패딩을 추가합니다.
                }
                .background(Color.white) // 여기에 배경색을 추가할 수 있습니다.
                .cornerRadius(10) // 모서리를 둥글게 처리합니다.
                .overlay(
                    RoundedRectangle(cornerRadius: 10) // 모서리의 둥근 정도를 지정합니다.
                        .stroke(Color.gray, lineWidth: 1) // 여기에서 태두리의 색상과 두께를 지정합니다.
                )
                .padding(.horizontal)
            }else{
                Spacer()
                HStack{
                    Spacer()
                    Text("등록된 의사가 없습니다.")
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear(){
            if !DoctorProfile.main_schedules.isEmpty{
                WorkingState = TimeHelper.checkTimeIn(startTime: DoctorProfile.main_schedules[0].startTime1, endTime: DoctorProfile.main_schedules[0].endTime2)
                CheckIsEmpty = false
            }
        }
    }
}

