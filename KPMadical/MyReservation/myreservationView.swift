//
//  myreservationView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import SwiftUI

struct myreservationView: View {
    @State var path = NavigationPath()
    let request = ReservationHttpRequest()
    @ObservedObject var userInfo: UserObservaleObject
    @EnvironmentObject var router: GlobalViewRouter
    @State private var reservationItems: [reservationDataHandler.reservationAr] = []
    var body: some View {
        NavigationStack(path: $path){
            VStack{
                List(reservationItems.indices, id:\.self){ index in
                    reservationItemView(item: $reservationItems[index])
                        .onTapGesture {
                            path.append(index)
                        }
                }
                .navigationDestination(for: Int.self) {index in
                    ReservationDetailView(path: $path, userInfo: userInfo, item: $reservationItems[index], HospitalId: reservationItems[index].hospital_id, reservation_id: reservationItems[index].reservation_id)
                }
            }.onAppear{
                print("CallOnAppear")
                reservationItems = []
                request.CallReservationList(token: userInfo.token){ data in
                    reservationItems = data
                }
            }
            .navigationTitle("예약 내역")
                .toolbar{
                    ToolbarItem(placement: .navigation){
                        Button(action:{
                            router.currentView = .tab
                        }){
                            Image(systemName: "chevron.left")
                        }
                    }
                }
        }
    }
}

//#Preview {
//    myreservationView()
//}
