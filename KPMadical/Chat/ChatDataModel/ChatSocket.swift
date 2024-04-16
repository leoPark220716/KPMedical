//
//  ChatSocket.swift
//  KPMadical
//
//  Created by Junsung Park on 4/14/24.
//

import Foundation

// 메시지 전송 구조체 모음
struct SendChatDataModel{
    struct ChatMessageContent: Codable {
        var msg_type: Int
        var from: String
        var to: String
        var content_type: String
        var content: MessageContent
    }
    struct MessageContent: Codable{
        var message: String?
        var file_cnt: Int?
        var file_ext: [String]?
    }
}
// 메시지 수신 구조체 모음
struct ReceiveChatDataModel{
    struct ReceiveChatContent{
        var msg_type: Int
        var from: String
        var to: String
        var content_type: String
        var content: MessageContent
        var block_data: BlockData?
        var on: Bool
        var err_msg: String
        var timesetamp: String
        
    }
    struct MessageContent: Codable{
        var message: String?
        var file_cnt: Int?
        var file_ext: [String]?
        var bucket: [String]?
        var key: [String]?
    }
    struct BlockData: Codable{
        var hospital_id: Int?
        var unixtime: String?
        var index: Int?
        var pub_key: String?
    }
    struct hospital_data: Codable{
        var old_room_id: Int?
        var room_id: Int?
        var room_name: String?
        var patient_no: Int?
        var user_id: String?
        var contract: String?
        var patient_name: String?
        var dob: String?
        var sex_code: String?
        var all_status: [String: [String:String]]?
        var timestamp: String?
    }
}
// 소켓 처음 연결 됐을 때 받는 데이터 타입.
struct OpenChatRoomDataModel{
    struct ChatMessage: Codable {
        var msg_type: Int
        var from: String
        var to: String
        var content_type: String
        var content: MessageContent?
        var block_data: BlockData?
        var hospital_data: HospitalData?
        var on: Bool
        var err_msg: String?
        var timestamp: String?
    }
    
    struct MessageContent: Codable {
        var message: String
        var file_cnt: Int?
        var file_name: [String]?
        var file_ext: [String]?
        var file_size: [Int]?
        var bucket: [String]?
        var key: [String]?
    }
    
    struct BlockData: Codable {
        var hospital_id: Int
        var unixtime: String?
        var index: Int
        var pub_key: String?
        var hash: String?
    }
    
    struct HospitalData: Codable {
        var old_room_id: Int
        var room_id: Int
        var room_name: String?
        var patient_no: Int
        var user_id: String?
        var contract: String?
        var patient_name: String?
        var dob: String?
        var sex_code: String?
        var purpose: String?
        var all_status: [String: ChatDetail]?
        var timestamp: String?
    }
    
    struct ChatDetail: Codable {
        var bucket: KeyType?
        var chat_index: String
        var content_type: String
        var file_cnt: String
        var from: String
        var hospital_id: String
        var index: String
        var key: KeyType?
        var message: String
        var msg_type: String
        var pub_key: String?
        var timestamp: String
        var to: String
        var unixtime: String?
        var uuid: String
        var hash: String?
        
        enum KeyType: Codable {
                case string(String)
                case array([String])

                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let string = try? container.decode(String.self) {
                        self = .string(string)
                    } else if let array = try? container.decode([String].self) {
                        self = .array(array)
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected String or [String]")
                    }
                }

                func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .string(let string):
                        try container.encode(string)
                    case .array(let array):
                        try container.encode(array)
                    }
                }
            }
    }
}
struct ChatMessegeItem: Codable{
    var type: MessageTypes
    var HospitalName: String?
    var messege: String?
    var ReadCount: Bool
    var FileURI: String?
    var time: String
    var amI: AmI
    var chatDate: String
    var showETC: Bool
    enum AmI: Codable{
        case user, other, sepDate
    }
    enum MessageTypes: Codable{
        case text, photo, file
    }
}
