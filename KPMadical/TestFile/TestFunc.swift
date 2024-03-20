//
//  TestFunc.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation

// Define the root structure of the JSON data
struct HospitalData: Codable {
    var data: [Hospitals]
}

// Define the structure for each hospital
struct Hospitals: Codable, Identifiable {
    var id = UUID() // SwiftUI List에서 사용하기 위한 유니크 아이덴티파이어
    var hospital_name: String
    var hospital_image: String
    var hospital_skill: [String]
    var hospital_id: String
    var address: String
    var longitude: String
    var latitude: String
    enum CodingKeys: String, CodingKey {
        case hospital_name, hospital_image, hospital_skill, hospital_id, address, longitude, latitude
    }
}
