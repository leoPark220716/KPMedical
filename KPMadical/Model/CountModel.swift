//
//  File.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import Foundation

class CountModel: ObservableObject{
    @Published var sentCount: Int
    
    init(sentCount: Int) {
        self.sentCount = sentCount
    }
}
