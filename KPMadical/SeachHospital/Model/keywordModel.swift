//
//  keywordModel.swift
//  KPMadical
//
//  Created by Junsung Park on 3/22/24.
//

import Foundation
import Combine

class keywordModel: ObservableObject {
    let requestList = HospitalHTTPRequest()
    @Published var hospitals: [HospitalDataManager.Hospitals] = []
    @Published var isSearching = false
    @Published var showList = false
    private var cancellables: Set<AnyCancellable> = []
    let searchTextPublisher = PassthroughSubject<String, Never>()
    
    init() {
        searchTextPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] completedText in
                // 여기에 HTTP 요청을 배치합니다.
                // 예시입니다, 실제로는 당신의 네트워크 요청으로 대체하세요.
                self?.fetchHospitals(keyword: completedText)
            }
            .store(in: &cancellables)
    }
    
    func fetchHospitals(keyword: String) {
        self.isSearching = true
        // 여기에서 hospitals 리스트를 업데이트하는 네트워크 요청을 수행합니다.
        // 요청이 성공하면 `@Published var hospitals`를 업데이트합니다.
        print(keyword)
        requestList.CallHospitalList(orderBy: "name", x: "", y: "", keyword: keyword, department_id: "") { result in
            switch result {
            case .success(let hospitals):
                DispatchQueue.main.async {
                    self.isSearching = false
                    self.showList = true
                    if !hospitals.isEmpty{
                        self.hospitals = hospitals
                        print(self.hospitals[0].department_id)
                    }
                }
            case .failure(let error):
                print("Failed Received Hospital: \(error)")
            }
            
        }
    }
}
