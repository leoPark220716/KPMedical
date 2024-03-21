//
//  TabViewManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import Foundation

enum NoTabViews{
    case findHospital, tab
}
// 전역 상태를 관리하는 클래스 정의
class GlobalViewRouter: ObservableObject {
    @Published var currentView: NoTabViews = .tab
}
