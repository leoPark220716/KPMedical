//
//  TabViewManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import Foundation

enum NoTabViews{
    case findHospital, tab, MyReservation, myWallet, chat
}
// 전역 상태를 관리하는 클래스 정의
class GlobalViewRouter: ObservableObject {
    @Published var currentView: NoTabViews = .tab
    @Published var exportTapView: BottomTab = .home
    @Published var userId: String = ""
    func SetBeforeTab(BeforeTab: BottomTab){
        switch BeforeTab{
        case .account:
            self.exportTapView = .account
        case .home:
            self.exportTapView = .home
        case .chat:
            self.exportTapView = .chat
        case .hospital:
            self.exportTapView = .hospital
        }
    }
    func RetrunUserId(){
        let jwtToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiRUYwMEM2QzQ5NUVEQkZGMDFBQ0NDNzY1MEExQjUxMjgiLCJuYW1lIjoi6rmA7ISx7ZuIIiwic2VydmljZV9pZCI6MSwiaWF0IjoxNzEyMTU2MTM5LCJleHAiOjE3MTI0MTUzMzl9.NI0thMVyeF959egIzg0inpkx8k8mFVfHCGSjPld6zPk"

        // JWT를 '.'을 기준으로 나누기
        let sections = jwtToken.components(separatedBy: ".")

        // Header와 Payload를 디코딩
        if sections.count > 2 {
            let headerData = Data(base64Encoded: sections[0], options: .ignoreUnknownCharacters)!
            let payloadData = Data(base64Encoded: sections[1], options: .ignoreUnknownCharacters)!

            // Header와 Payload를 String으로 변환
            let header = String(data: headerData, encoding: .utf8)!
            let payload = String(data: payloadData, encoding: .utf8)!

            // 결과 출력
            print("Header: \(header)")
            print("Payload: \(payload)")
        } else {
            print("Invalid JWT Token")
        }
    }
}
