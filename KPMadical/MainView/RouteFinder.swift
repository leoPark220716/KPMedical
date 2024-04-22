//
//  RouteFinder.swift
//  KPMadical
//
//  Created by Junsung Park on 4/21/24.
//

import Foundation
enum DeepLinkURLs: String{
    case chat
}
struct RouteFinder {
    func find(from url: URL) -> (route : Route?, page: String){
        guard let host = url.host() else{return (nil,"")}
        switch DeepLinkURLs(rawValue: host){
        case .chat:
            print("DeepLInkURLS Chat")
            let queryParameters = url.queryParameters
            guard let descQueryVal = queryParameters?["desc"] as? String,
                  let chatIdVal = queryParameters?["id"] as? String,
                  let hospitalIdVal = queryParameters?["hos_id"] as? String
            else{
                print("false")
                return (nil,"")
            }
            let URLData = parseParam(id: Int(chatIdVal)!, name: descQueryVal, hospital_id: Int(hospitalIdVal)!)
            return (Route.chat(data:URLData),"chat")
        default:
            return (nil,"")
        }
    }
}
extension URL{
    public var queryParameters: [String:String]?{
        guard
            let components = URLComponents(url:self,resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems else{ return nil }
        return queryItems.reduce(into: [String:String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
