//
//  reservationModel.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import Foundation

class reservationDataHandler {
    struct reservation: Codable{
        var access_token: String
        var reservations: [reservationAr]
        var error_code: Int
        var error_stack: String
    }
    struct reservationAr : Codable{
        var reservation_id: Int
        var hospital_id: Int
        var hospital_name: String
        var icon: String
        var staff_id: Int
        var staff_name: String
        var department_id: [String]
        var patient_name: String
        var date: String
        var time: String
    }
    struct cancelReservation: Codable{
        var access_token: String
        var uid: String
        var reservation_id: Int
    }
}
