//
//  FindHosptialItem.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import SwiftUI

struct FindHosptialItem: View{
    @Binding var hospital: Hospitals
    @State var WorkingState: Bool?
    var body: some View{
        VStack(alignment: .leading) {
            Text(hospital.hospital_name)
                .font(.headline)
            Text(hospital.location)
                .font(.subheadline)
                HStack{
                    Image(systemName: "stopwatch")
                        .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
                        .font(.subheadline)
                    Text(WorkingState ?? false ? "진료중" : "진료종료")
                        .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
                        .font(.subheadline)
                    Text(WorkingState ?? false ? "\(hospital.start_time)~\(hospital.end_time)" : "")
                        .font(.subheadline)
                }
                .padding(.top, 2)
            HStack {
                ForEach(hospital.department_id.prefix(4), id: \.self) { id in
                    if let department = Department(rawValue: id) {
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
        .padding(.vertical,5)
        .onAppear(){
            WorkingState = checkTimeIn(startTime: hospital.start_time, endTime: hospital.end_time)
        }
    }
}

