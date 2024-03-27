//
//  PikerViewSelection.swift
//  KPMadical
//
//  Created by Junsung Park on 3/26/24.
//

import SwiftUI
import NMapsMap
struct PikerViewSelection: View{
    @Binding var HospitalDetailData: HospitalDataManager.HospitalDataClass
    @State private var selection = Selection.Intro
    @Binding var coord: NMGLatLng
    @Binding var HospitalSchedules: [HospitalDataManager.Schedule]
    @Binding var DoctorProfile: [HospitalDataManager.Doctor]
    var body: some View{
        VStack(alignment:.leading){
            HStack{
                VStack{
                    Text("병원소개")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity,alignment: .center) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .Intro ? .black : .gray)
                        .padding(.vertical,4)
                    Rectangle()
                        .frame(height: 2) // 전체 너비의 40%로 설정
                        .foregroundColor(selection == .Intro ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .Intro
                }
                VStack{
                    Text("의료진")
                        .font(.system(size: 15))
                        .frame(maxWidth: .infinity,alignment: .center) // 가능한 모든 가로 공간을 차지하도록 설정
                        .foregroundColor(selection == .doc ? .black : .gray)
                        .padding(.vertical,4)
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selection == .doc ? Color("ConceptColor") : .clear)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .background(Color.white)
                .onTapGesture {
                    selection = .doc
                }
            }
            switch selection {
            case .Intro:
                HospitalDetailIntroView(HospitalDetailData: $HospitalDetailData,coord: $coord, HospitalSchedules: $HospitalSchedules)
            case .doc:
                DoctorListView(DoctorProfile: $DoctorProfile)
            }
        }
    }
    enum Selection {
        case Intro, doc
    }
}


