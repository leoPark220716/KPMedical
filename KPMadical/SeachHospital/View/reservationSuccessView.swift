//
//  reservationSuccessView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/28/24.
//

import SwiftUI

struct reservationSuccessView: View {
    @Binding var path: NavigationPath
    @ObservedObject var userInfo: UserObservaleObject
    @ObservedObject var HospitalInfo: HospitalDataHandler
    @Binding var info: reservationInfo
    @EnvironmentObject var router: GlobalViewRouter
    let pading = 23
    var body: some View {
        VStack{
            HStack{
                Text("예약이 완료되었습니다.")
                    .font(.title)
                    .bold()
                    .padding(.leading)
                Spacer()
            }
            HStack{
                VStack(alignment: .leading){
                    Text("10분 전까지 도착해 주세요!")
                        .bold()
                        .padding(.horizontal,30)
                        .padding([.vertical])
                    Text("예약 시간에 늦으면 예약이 취소되며")
                        .padding(.horizontal,30)
                        .font(.system(size: 14))
                    Text("다음예약에 불이익이 있을 수 있습니다.")
                        .font(.system(size: 14))
                        .padding(.horizontal,30)
                        .padding(.bottom)
                    
                }
                Image(systemName: "clock.fill")
                    .foregroundColor(Color("ConceptColor"))
                    .font(.system(size: 30))
                    .imageScale(.large)
                    .padding()
            }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.bottom)
            .padding(.top)
            
            HStack{
                Text("병원")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                    .bold()
                    .padding(.leading,23)
                Spacer()
                Text(info.hospital_name)
                    .font(.system(size: 15))
                    .bold()
                    .padding(.trailing,23)
            }
            .padding(.bottom,10)
            HStack{
                Text("일정")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                    .bold()
                    .padding(.leading,23)
                Spacer()
                Text("\(info.date)-\(info.time)")
                    .font(.system(size: 15))
                    .bold()
                    .padding(.trailing,23)
            }
            .padding(.bottom,10)
            HStack{
                Text("의사명")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                    .bold()
                    .padding(.leading,23)
                Spacer()
                Text(info.doc_name)
                    .font(.system(size: 15))
                    .bold()
                    .padding(.trailing,23)
            }
            .padding(.bottom,10)
            HStack{
                Text("환자명")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                    .bold()
                    .padding(.leading,23)
                Spacer()
                Text(userInfo.name)
                    .font(.system(size: 15))
                    .bold()
                    .padding(.trailing,23)
            }
            .padding(.bottom,10)
            HStack{
                Text("방문목적")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.gray)
                    .bold()
                    .padding(.leading,23)
                Spacer()
                Text(info.purpose)
                    .font(.system(size: 15))
                    .bold()
                    .padding(.trailing,23)
            }
            .padding(.bottom,10)
        }
        .navigationBarBackButtonHidden(true)
        Spacer()
        Button(action: buttonAction) {
            Text("확인")
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("ConceptColor"))
                .cornerRadius(10)
        }
    }
    func buttonAction(){
        path.removeLast(path.count)
        router.currentView = .tab
    }
}


