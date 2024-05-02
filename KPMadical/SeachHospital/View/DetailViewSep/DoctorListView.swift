//
//  DoctorListView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI

struct DoctorListView: View{
    @Binding var DoctorProfile: [HospitalDataManager.Doctor]
    var body: some View{
        if !DoctorProfile.isEmpty{
            ForEach(DoctorProfile.indices, id: \.self) { item in
                DoctorItemView(DoctorProfile: DoctorProfile[item])
            }
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
}

