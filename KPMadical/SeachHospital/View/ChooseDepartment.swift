//
//  ChooseDepartment.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct ChooseDepartment: View {
    @Binding var path: NavigationPath
    @ObservedObject var userInfo: UserInformation
    @ObservedObject var HospitalInfo: HospitalDataHandler
    @State private var selectedId: Int? = nil
//    Toast 메시지
    @State private var toast: FancyToast? = nil
    @Binding var info: reservationInfo
    var body: some View {
        ScrollView{
            VStack(alignment:.center){
                ForEach(HospitalInfo.HospitalDetailData.hospital.department_id, id: \.self){ id in
                    let intid = Int(id)
                    if let department = Department(rawValue: intid ?? 0){
                        DepartmentView(name: department.name, isSelected: selectedId == Int(id))
                            .onTapGesture {
                                self.selectedId = Int(id)
                                info.department_id = id
                            }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("진료과를 선택해주세요")
        }
        .toastView(toast: $toast)
        HStack{
            Spacer()
            if selectedId != nil{
                NavigationLink(value: HospitalDataHandler.ChooseDateOrDoctor.doctor){
                    Text("의료진")
                        .modifier(ButtonStyleModifier(isEnabled: true))
                }
                NavigationLink(value: HospitalDataHandler.ChooseDateOrDoctor.date_day){
                    Text("진료일")
                        .modifier(ButtonStyleModifier(isEnabled: true))
                }
            }else{
                Text("의료진")
                    .modifier(ButtonStyleModifier(isEnabled: true))
                    .onTapGesture {
                        toast = FancyToast(type: .error, title: "진료과를 선택하지 않았습니다.", message: "진료과를 선택해주세요.")
                    }
                Text("진료일")
                    .modifier(ButtonStyleModifier(isEnabled: true))
                    .onTapGesture {
                        toast = FancyToast(type: .error, title: "진료과를 선택하지 않았습니다.", message: "진료과를 선택해주세요.")
                    }
            }
            Spacer()
        }
        .navigationDestination(for:HospitalDataHandler.ChooseDateOrDoctor.self){ value in
            switch value{
            case .date_day:
                ChooseDate(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo,CheckFirst: true,info: $info)
            case .doctor:
                ChooseDorcor(path: $path, userInfo: userInfo, HospitalInfo: HospitalInfo,CheckFirst: true,info: $info)
            }
        }
    }
}
struct ButtonStyleModifier: ViewModifier {
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .padding(13)
            .font(.system(size: 20))
            .bold()
            .frame(maxWidth: .infinity)
            .foregroundColor(isEnabled ? Color.white : Color.gray)
            .background(Color("ConceptColor"))
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isEnabled ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8), lineWidth: 1)
            )
    }
}
struct DepartmentView: View {
    let name: String
    var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(name)
                .bold()
                .padding(.leading)
                .padding(.vertical)
                .foregroundStyle(isSelected ? Color.blue : Color.black)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(isSelected ? Color.blue.opacity(0.8) : Color.gray.opacity(0.8), lineWidth: 1)
        )
        .background(Color.white)
        .padding(.vertical, 3)
        .padding(.horizontal)
    }
}
