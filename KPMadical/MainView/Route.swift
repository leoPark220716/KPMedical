//
//  Route.swift
//  KPMadical
//
//  Created by Junsung Park on 4/20/24.
//

import Foundation

struct parseParam{
    let id: String
    let des: String
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
            return lhsData.id == rhsData.id && lhsData.des == rhsData.des
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }
}

struct ViewPathAddress: PathAddress {
    var name: String
    var page: Int
    var id: Int
}
