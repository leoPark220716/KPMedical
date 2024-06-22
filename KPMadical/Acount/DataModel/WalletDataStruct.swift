//
//  WalletDataStruct.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import Foundation

struct WalletDataStruct{
    
    struct AccessItem{
        var HospitalName: String
        var Purpose: String
        var State: Bool
        var Date: String
        var blockHash: String
        var unixTime: Int
    }
}
