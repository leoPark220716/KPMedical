//
//  Route.swift
//  KPMadical
//
//  Created by Junsung Park on 4/20/24.
//

import Foundation

struct chatParseParam{
    let id: Int
    let name: String
    let hospital_id: Int
}
struct hospitalParseParam{
    let id: Int
    let name: String
    let hospital_id: Int
    let startTiome: String
    let EndTime: String
    let MainImage: String
}
struct ReservationParseParam{
    let item: reservationDataHandler.reservationAr
    let HospitalId: Int
    let reservation_id: Int
}

protocol PathAddress: Hashable {
    var name: String { get }
    var page: Int { get }
    var id: Int { get }
}
enum Route{
    case item(item: any PathAddress)
    case chat(data: chatParseParam)
    case hospital(item: hospitalParseParam)
    case reservation(item: ReservationParseParam)
    case pass(item: PassViewPathAddress)
}
extension Route: Hashable {
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.item(let lhsItem), .item(let rhsItem)):
            return lhsItem.name == rhsItem.name && lhsItem.page == rhsItem.page && lhsItem.id == rhsItem.id
        case (.chat(let lhsData), .chat(let rhsData)):
            return lhsData.id == rhsData.id && lhsData.name == rhsData.name && lhsData.hospital_id == rhsData.hospital_id
        case (.hospital(let lhsData), .hospital(let rhsData)):
            return lhsData.id == rhsData.id && lhsData.name == rhsData.name && lhsData.hospital_id == rhsData.hospital_id && lhsData.startTiome == rhsData.startTiome && lhsData.EndTime == rhsData.EndTime && lhsData.MainImage == rhsData.MainImage
        case (.reservation(let lhsData), .reservation(let rhsData)):
            return lhsData.item == rhsData.item && lhsData.HospitalId == rhsData.HospitalId && lhsData.reservation_id == rhsData.reservation_id
        case (.pass(let lhsItem), .pass(let rhsItem)):
            return lhsItem.token == rhsItem.token && lhsItem.page == rhsItem.page && lhsItem.id == rhsItem.id
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
        case .hospital(item: let item):
            hasher.combine(item.id)
            hasher.combine(item.name)
            hasher.combine(item.hospital_id)
            hasher.combine(item.startTiome)
            hasher.combine(item.EndTime)
            hasher.combine(item.MainImage)
        case .reservation(let data):
            hasher.combine(data.item)
            hasher.combine(data.HospitalId)
            hasher.combine(data.reservation_id)
        case .pass(let item):
            hasher.combine(item.id)  // 예시로 id 사용
            hasher.combine(item.token)
            hasher.combine(item.page)
        
        }
    }

}
enum PassRoute{
    case item(item: PassViewPathAddress)
}
extension PassRoute: Hashable{
    static func == (lhs: PassRoute, rhs: PassRoute) -> Bool {
        switch (lhs, rhs) {
        case (.item(let lhsItem), .item(let rhsItem)):
            return lhsItem.token == rhsItem.token && lhsItem.page == rhsItem.page && lhsItem.id == rhsItem.id
        }
    }
    func hash(into hasher: inout Hasher) {
        switch self {
        case .item(let item):
            hasher.combine(item.id)  // 예시로 id 사용
            hasher.combine(item.token)
            hasher.combine(item.page)
        }
    }
}
struct ViewPathAddress: PathAddress {
    var name: String
    var page: Int
    var id: Int
}
struct PassViewPathAddress {
    var token: String
    var id: String
    var page: Int
    var type: Int
}


