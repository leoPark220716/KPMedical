//
//  Route.swift
//  KPMadical
//
//  Created by Junsung Park on 4/20/24.
//

import Foundation

struct parseParam{
    let id: Int
    let name: String
    let hospital_id: Int
}

protocol PathAddress: Hashable {
    var name: String { get }
    var page: Int { get }
    var id: Int { get }
}
enum Route{
    case item(item: any PathAddress)
    case chat(data: parseParam)
}
extension Route: Hashable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.item(let lhsItem), .item(let rhsItem)):
            return lhsItem.name == rhsItem.name && lhsItem.page == rhsItem.page && lhsItem.id == rhsItem.id
        case (.chat(let lhsData), .chat(let rhsData)):
            return lhsData.id == rhsData.id && lhsData.name == rhsData.name && lhsData.hospital_id == rhsData.hospital_id
        default:
            return false
        }
    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .item(let item):
            hasher.combine(item.id)  // 예시로 id 사용
            hasher.combine(item.name)
            hasher.combine(item.page)
        case .chat(let data):
            hasher.combine(data.id)
            hasher.combine(data.name)
            hasher.combine(data.hospital_id)
        }
    }

}

struct ViewPathAddress: PathAddress {
    var name: String
    var page: Int
    var id: Int
}
