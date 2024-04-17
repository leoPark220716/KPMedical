//
//  ChatSocketViewHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 4/17/24.
//

import Foundation

class ChatSocketRequest: WebSocket{
    //    메시지 및 파일 메타 데이터 전송
    func sendMessage(from: String, to: String, content_type: String, message:String? = nil, file_cnt: Int? = nil, file_ext: [String]? = nil) async -> Bool{
        let content = SendChatDataModel.MessageContent(
            message: message,
            file_cnt: file_cnt,
            file_ext: file_ext
        )
        let ChatMessage = SendChatDataModel.ChatMessageContent(
            msg_type: 3,
            from: from,
            to: to,
            content_type: content_type,
            content: content)
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
