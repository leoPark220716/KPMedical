//
//  myHospital.swift
//  KPMadical
//
//  Created by Junsung Park on 5/9/24.
//

import SwiftUI

struct myHospital: View {
    
    @EnvironmentObject var router: GlobalViewRouter
    @EnvironmentObject var authViewModel: UserInformation
    @ObservedObject var myHospitalRequest = MyHospitalRequest()
    var body: some View {
        VStack{
            List(myHospitalRequest.hospitals.indices, id: \.self) {index in
                FindHosptialItem(hospital: $myHospitalRequest.hospitals[index])
                    .onTapGesture {
                        router.ReservationInit()
                        router.tabPush(to: Route.hospital(item: hospitalParseParam(id: myHospitalRequest.hospitals[index].hospital_id, name: "hospitalDitailView", hospital_id:myHospitalRequest.hospitals[index].hospital_id , startTiome: myHospitalRequest.hospitals[index].start_time, EndTime: myHospitalRequest.hospitals[index].end_time, MainImage: myHospitalRequest.hospitals[index].icon)))
                    }
            }
        }
        .onAppear{
            myHospitalRequest.getMyHospitalList(token: authViewModel.token)
        }
    }
}
