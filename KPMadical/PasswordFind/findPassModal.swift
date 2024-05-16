//
//  findPassModal.swift
//  KPMadical
//
//  Created by Junsung Park on 5/16/24.
//

import Foundation

struct FindPassModel{
    func decode(jwtToken jwt: String) -> [String: Any]? {
        let segments = jwt.split(separator: ".")
        guard segments.count == 3 else { return nil }

        return decodeJWTPart(String(segments[1]))
    }

    func decodeJWTPart(_ value: String) -> [String: Any]? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let length = Double(base64.lengthOfBytes(using: .utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0 {
            base64 += String(repeating: "=", count: Int(paddingLength))
        }

        guard let data = Data(base64Encoded: base64, options: .ignoreUnknownCharacters) else {
            return nil
        }

        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        print(json ?? "")
        return json as? [String: Any]
    }
}
