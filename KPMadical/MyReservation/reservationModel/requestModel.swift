//
//  requestModel.swift
//  KPMadical
//
//  Created by Junsung Park on 3/29/24.
//

import Foundation

class ReservationHttpRequest{
    func CallReservationList(token:String, http: @escaping ([reservationDataHandler.reservationAr])->Void){
        let urlString = "https://kp-medicals.com/api/medical-wallet/hospitals/reservations/list?access_token=\(token)&uid=\(getDeviceUUID())"
        print(urlString)
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            URLSession.shared.dataTask(with: request){ data, res, er in
                if let er = er {
                    print("err : \(er) ")
                    return
                }
                guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                    print("res err \(String(describing: res))")
                    return
                }
                guard let data = data else{
                    let dataError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data"])
                    print("\(dataError)")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(KPApiStructFrom<reservationDataHandler.reservation>.self, from: data)
                    http(json.data.reservations)
                }catch {
                    print("JsonErr \(error)")
                }
            }.resume()
        }else{
            let urlError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            print("ErrUrl\(urlError)")
        }
    }
    
    func cancelReservationById(token:String, id: Int, HttpHandler: @escaping (Bool) -> Void){
        if let url = URL(string: "https://kp-medicals.com/api/medical-wallet/hospitals/reservations/back"){
            let PostData: reservationDataHandler.cancelReservation = .init(access_token: token, uid: getDeviceUUID(), reservation_id: id)
            var request = URLRequest.init(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            if let requestData = try? JSONEncoder().encode(PostData){
                request.httpBody = requestData
                if let JsonString = String(data: requestData, encoding: .utf8){
                    print(JsonString)
                }
            }
            URLSession.shared.dataTask(with: request) {data, res, er in
                if let er = er {
                    print("err :\(er)")
                    return
                }
                guard let res = res as? HTTPURLResponse, (200 ..< 300) ~= res.statusCode else {
                    print("er http request failed\(String(describing: res))")
                    HttpHandler(false)
                    return
                }
                guard let data = data else{
                    print("er http request failed\(String(describing: res))")
                    HttpHandler(false)
                    return
                }
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(KPApiStructFrom<HospitalDataManager.reservationResponse>.self, from: data){
                    if json.success == "success"{
                        print(json.data)
                        HttpHandler(true)
                    }else{
                        print(json.data)
                        HttpHandler(false)
                    }
                }
            }.resume()
        }
    }
}
 

