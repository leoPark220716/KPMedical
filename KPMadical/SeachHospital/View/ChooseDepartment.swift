//
//  ChooseDepartment.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct ChooseDepartment: View {
    @ObservedObject var userInfo: UserObservaleObject
    @ObservedObject var HospitalInfo: HospitalDataHandler
    @State private var selectedId: Int? = nil
    var body: some View {
        ScrollView{
            VStack(alignment:.center){
                ForEach(HospitalInfo.HospitalDetailData.hospital.department_id, id: \.self){ id in
                    let intid = Int(id)
                    if let department = Department(rawValue: intid ?? 0){
                        DepartmentView(name: department.name, isSelected: selectedId == Int(id))
                            .onTapGesture {
                                self.selectedId = Int(id)
                            }
                    }
                }
            }
            .padding(.top)
            .navigationTitle("진료과를 선택해주세요")
        }
        HStack{
            Spacer()
            Text("의료진")
                .padding(13)
                .font(.system(size: 20))
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .background(Color("ConceptColor"))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                )
            Text("진료일")
                .padding(13)
                .font(.system(size: 20))
                .bold()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.white)
                .background(Color("ConceptColor"))
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 1)
                )
            Spacer()
        }
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
