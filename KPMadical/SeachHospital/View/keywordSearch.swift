//
//  keywordShearch.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import SwiftUI

struct KeywordSearch: View {
    @EnvironmentObject var userInfo: UserInformation
    @State private var searchText = ""
    @ObservedObject private var viewModel = keywordModel()
    @EnvironmentObject var router: GlobalViewRouter
    // 태그 배열
    var body: some View {
        VStack(alignment: .leading) {
            // 검색 바
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("찾고있는 병원을 검색하세요.", text: $searchText)
                    .font(.subheadline)
                    .onChange(of: searchText) {
                        viewModel.hospitals = []
                        viewModel.showList = false
                        if searchText != ""{
                            viewModel.searchTextPublisher.send(searchText)
                        }
                    }
            }
            .padding(.horizontal, 10)
            .frame(height: 40)
            .background(Color(.systemGray5)) // 연한 회색 배경
            .cornerRadius(10)
            .padding()
            if viewModel.hospitals.isEmpty{
                // 추천 키워드
                Text("추천 키워드")
                    .font(.headline)
                    .padding(.horizontal)
                // 태그들
                HStack(spacing: 10) {
                    ForEach(["외과", "진해병원", "안과"], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("ConceptColor"), lineWidth: 2) // 파란색 태두리
                            )
                            .foregroundColor(Color("ConceptColor"))
                            .onTapGesture {
                                searchText = tag
                            }
                    }
                }
                .padding(.horizontal)
            }
            if viewModel.isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle()) // 또는 .progressViewStyle(.circular) for iOS 15+
                    .padding()
            }else{
                if viewModel.hospitals.isEmpty && !searchText.isEmpty && viewModel.showList{
                    HStack {
                        Spacer() // 왼쪽 공간을 추가하여 중앙 정렬
                        Text("'\(searchText)'에 대한 검색결과가 존재하지 않습니다.")
                            .foregroundColor(.gray) // 필요에 따라 색상 조정
                        Spacer() // 오른쪽 공간을 추가하여 중앙 정렬
                    }
                    .padding() // 추가적인 패딩을 제공하여 더 좋은 UI를 제공
                }else if !viewModel.hospitals.isEmpty && !searchText.isEmpty && viewModel.showList{
                    List(viewModel.hospitals.indices, id: \.self) {index in
                        FindHosptialItem(hospital: $viewModel.hospitals[index])
                            
                                .onTapGesture {
                                    router.ReservationInit()
                                    router.tabPush(to: Route.hospital(item: hospitalParseParam(id: viewModel.hospitals[index].hospital_id, name: "hospitalDitailView", hospital_id:viewModel.hospitals[index].hospital_id , startTiome: viewModel.hospitals[index].start_time, EndTime: viewModel.hospitals[index].end_time, MainImage: viewModel.hospitals[index].icon)))
                                }
//                                NavigationLink("",destination : HospitalDetailView(path: $path, userInfo:userInfo,StartTime: viewModel.hospitals[index].start_time,EndTime: viewModel.hospitals[index].end_time,HospitalId: viewModel.hospitals[index].hospital_id, MainImage: viewModel.hospitals[index].icon))
//                                    .opacity(0)
                            
                    }
                    .listStyle(InsetListStyle())
                    .padding(.top, 10)
                }
            }
            Spacer()
        }
        .navigationBarTitle("검색", displayMode: .inline)
        .background(Color.white) // 전체 배경색
        
    }
}

