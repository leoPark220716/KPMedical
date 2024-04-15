//
//  extensions.swift
//  KPMadical
//
//  Created by Junsung Park on 4/15/24.
//

import Foundation

extension Data {
    func isPNG() -> Bool {
        let pngSignatureBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
        var header = [UInt8](repeating: 0, count: 8)
        self.copyBytes(to: &header, count: 8)
        return header == pngSignatureBytes
    }
}
