//
//  myreservationView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import SwiftUI

struct myreservationView: View {
    @EnvironmentObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    let request = ReservationHttpRequest()
    @State private var reservationItems: [reservationDataHandler.reservationAr] = []
    var body: some View {
            VStack{
                List(reservationItems.indices, id:\.self){ index in
                    reservationItemView(item: reservationItems[index])
                        .onTapGesture {
                            router.tabPush(to: Route.reservation(item: ReservationParseParam(item: reservationItems[index], HospitalId: reservationItems[index].hospital_id, reservation_id: reservationItems[index].reservation_id)))
                        }
                }
//                .navigationDestination(for: Int.self) {index in
//                    ReservationDetailView(item: $reservationItems[index],
//                                          HospitalId: reservationItems[index].hospital_id, 
//                                          reservation_id: reservationItems[index].reservation_id)
//                }
            }
            .onAppear{
                print("myreservationView CallOnAppear")
                reservationItems = []
                request.CallReservationList(token: userInfo.token){ data in
                    reservationItems = data
                }
            }
            .navigationTitle("예약 내역")
    }
}

//#Preview {
//    myreservationView()
//}
