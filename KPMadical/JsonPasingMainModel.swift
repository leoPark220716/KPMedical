//
//  JsonPasingMainModel.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

struct KPApiStructFrom<T: Codable>: Codable {
    let status: Int
    let success: String
    let message: String
    let data: T
}
struct KPApiStructFromGetArray<T: Codable>: Codable {
    let status: Int
    let success: String
    let message: String
    let data: [T]
}
