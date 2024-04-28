//
//  ChatSocketViewHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 4/17/24.
//

import Foundation

class ChatSocketRequest: WebSocket{
    //    메시지 및 파일 메타 데이터 전송
    func sendMessage(msg_type : Int, from: String, to: Int, content_type: String, message:String? = nil, file_cnt: Int? = nil, file_ext: [String]? = nil) async -> Bool{
        let content = SendChatDataModel.MessageContent(
            message: message,
            file_cnt: file_cnt,
            file_ext: file_ext
        )
        var ChatMessage: SendChatDataModel.ChatMessageContent
        if msg_type == 2{
            ChatMessage = SendChatDataModel.ChatMessageContent(
                msg_type: 2,
                from: from,
                to: String(to))
        }else{
            ChatMessage = SendChatDataModel.ChatMessageContent(
                msg_type: 3,
                from: from,
                to: String(to),
                content_type: content_type,
                content: content)

        }
        guard let jsonData = try? JSONEncoder().encode(ChatMessage) else{
            print("JsonData 파싱 실패")
            return false
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else{
            print("StringErr")
            return false
        }
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        return await withCheckedContinuation { continuation in
            webSocketTask?.send(message, completionHandler: { Error in
                if let err = Error {
                    print("Message Sending Err \(err.localizedDescription)")
                    continuation.resume(returning: false)
                }else{
                    print("SendSuccess")
                    continuation.resume(returning: true)
                }
            })
        }
    }
    
    func SendFileData(data: Data){
        let message = URLSessionWebSocketTask.Message.data(data)
            webSocketTask?.send(message, completionHandler: { Error in
                if let err = Error {
                    print("Message Sending Err \(err.localizedDescription)")
        
                }else{
                    print("SendSuccess")
                }
            })
    }
}
func HttpRequest<RequestType: Codable, ReturnType: Codable>(HttpStructs: http<RequestType?, ReturnType>) async -> (success: Bool, data: ReturnType?){
    let query = HttpStructs.urlParse
    if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
        let StringURL = "https://kp-medicals.com/api/common/\(encodedQuery)"
        print(StringURL)
        if let url = URL(string: StringURL){
            print("SendURL \(url)")
            do{
                var request = URLRequest(url: url)
                print("request URL  \(String(describing: request.url))")
                request.httpMethod = HttpStructs.method
                request.setValue("Bearer \(HttpStructs.token)", forHTTPHeaderField: "Authorization")
                request.setValue(HttpStructs.UUID, forHTTPHeaderField: "X-Device-UUID")
                if HttpStructs.method != "GET"{
                    let postData = try JSONEncoder().encode(HttpStructs.requestVal)
                    request.httpBody = postData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                let (data,response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpResponse.statusCode else{
                    let bodyString = String(data: data, encoding: .utf8)
                    print("Response body: \(bodyString ?? "Null")")
                    print("Request HTTP response Error \(String(describing: response))")
                    return (false,nil)
                }
                let bodyString = String(data: data, encoding: .utf8)
                print("👮🏼‍♂️Response body \(StringURL)")
                print("👮🏼‍♂️Response body: \(bodyString ?? "Null")")
                do {
                    let jsonData = try JSONDecoder().decode(ReturnType.self, from: data)
                    return (true, jsonData)
                } catch let decodeError {
                    print("👮🏼‍♂️Josn DecodingError \(StringURL)")
                    print("JSON Decoding Error: \(decodeError)")
                    return (false, nil)
                }
            }catch{
                print("Request Error \(error)")
                return (false,nil)
            }
        }
        else{
            return (false,nil)
        }
    }
    else{
        return (false,nil)
    }
}
func KPWalletApi<RequestType: Codable, ReturnType: Codable>(HttpStructs: http<RequestType?, ReturnType>) async -> (success: Bool, data: ReturnType?){
    let query = HttpStructs.urlParse
    if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
//    https://kp-medicals.com/api/medical-wallet/
        let StringURL = "https://kp-medicals.com/api/medical-wallet/\(encodedQuery)"
        print(StringURL)
        if let url = URL(string: StringURL){
            print("SendURL \(url)")
            do{
                var request = URLRequest(url: url)
                print("request URL  \(String(describing: request.url))")
                request.httpMethod = HttpStructs.method
                request.setValue("Bearer \(HttpStructs.token)", forHTTPHeaderField: "Authorization")
                request.setValue(HttpStructs.UUID, forHTTPHeaderField: "X-Device-UUID")
                if HttpStructs.method != "GET"{
                    let postData = try JSONEncoder().encode(HttpStructs.requestVal)
                    request.httpBody = postData
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                let (data,response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpResponse.statusCode else{
                    let bodyString = String(data: data, encoding: .utf8)
                    print("Response body: \(bodyString ?? "Null")")
                    print("Request HTTP response Error \(String(describing: response))")
                    return (false,nil)
                }
                let bodyString = String(data: data, encoding: .utf8)
                print("👀 Response body (\(HttpStructs.method)): \(bodyString ?? "Null")")
                do {
                    let jsonData = try JSONDecoder().decode(ReturnType.self, from: data)
                    return (true, jsonData)
                } catch let decodeError {
                    print("JSON Decoding Error: \(decodeError)")
                    return (false, nil)
                }
            }catch{
                print("Request Error \(error)")
                return (false,nil)
            }
        }
        else{
            return (false,nil)
        }
    }
    else{
        return (false,nil)
    }
}
func KPWalletApiCloser<RequestType: Codable, ReturnType: Codable>(HttpStructs: http<RequestType?, ReturnType> ,completionHandrler: @escaping (Bool, ReturnType?) -> Void){
    let query = HttpStructs.urlParse
    if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
        let StringURL = "https://kp-medicals.com/api/medical-wallet/\(encodedQuery)"
        print(StringURL)
        if let url = URL(string: StringURL){
            print("SendURL \(url)")
            Task{
                do{
                    var request = URLRequest(url: url)
                    print("request URL  \(String(describing: request.url))")
                    request.httpMethod = HttpStructs.method
                    request.setValue("Bearer \(HttpStructs.token)", forHTTPHeaderField: "Authorization")
                    request.setValue(HttpStructs.UUID, forHTTPHeaderField: "X-Device-UUID")
                    if HttpStructs.method == "POST"{
                        let postData = try JSONEncoder().encode(HttpStructs.requestVal)
                        request.httpBody = postData
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                    let (data,response) = try await URLSession.shared.data(for: request)
                    guard let httpResponse = response as? HTTPURLResponse, (200 ..< 300) ~= httpResponse.statusCode else{
                        let bodyString = String(data: data, encoding: .utf8)
                        print("Response body: \(bodyString ?? "Null")")
                        print("Request HTTP response Error \(String(describing: response))")
                        completionHandrler (false,nil)
                        return
                    }
                    do {
                        let jsonData = try JSONDecoder().decode(ReturnType.self, from: data)
                        completionHandrler (true, jsonData)
                    } catch let decodeError {
                        print("JSON Decoding Error: \(decodeError)")
                        completionHandrler (false, nil)
                    }
                }catch{
                    print("WTF is Err Request Error \(error)")
                    completionHandrler (false,nil)
                }
                
            }
            
        }
    }
    else{
        completionHandrler (false,nil)
    }
}


