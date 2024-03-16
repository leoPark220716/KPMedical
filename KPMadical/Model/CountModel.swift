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

class TextLimiter: ObservableObject {
    private let limit: Int
    init(limit: Int) {
        self.limit = limit
    }
    @Published var value = "" {
        didSet {
                if value.count > self.limit {
                    value = String(value.prefix(self.limit))
                    self.hasReachedLimit = true
                } else {
                    self.hasReachedLimit = false
                }
            }
    }
    @Published var hasReachedLimit = false
}


