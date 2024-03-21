//
//  NaverGeocoder.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import Foundation

class NaverGeocoder {
    func callNaverAddress(longitude: Double, latitude: Double, completion: @escaping (String) -> Void) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-reversegeocode/v2/gc?request=coordsToaddr&coords=\(longitude),\(latitude)&sourcecrs=epsg:4326&output=json&orders=addr,admcode"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("3h4eai9tfh", forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue("HolseKd4ZB361ghHjSMQjoZ0LukWsMQ9RnmKr5vx", forHTTPHeaderField: "X-NCP-APIGW-API-KEY")

        let task = URLSession.shared.dataTask(with: request) { data, res, error in
            guard let data = data, error == nil else {
                print("NaverGeo Error", error ?? "unknown error")
                return
            }
            do {
                if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let results = jsonData["results"] as? [[String: Any]],
                   let region = results.first?["region"] as? [String: Any] {
                    let area1Name = (region["area1"] as? [String: Any])?["name"] as? String ?? "Unknown"
                    let area2Name = (region["area2"] as? [String: Any])?["name"] as? String ?? "Unknown"
                    let area3Name = (region["area3"] as? [String: Any])?["name"] as? String ?? "Unknown"
                    completion("\(area1Name) \(area2Name) \(area3Name)")
                    
                }
            } catch {
                print("Failed to decode JSON: ", error)
            }
        }
        task.resume()
    }
}

