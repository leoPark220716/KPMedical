//
//  SocketConnection.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import Foundation

class WebSocket: ObservableObject {
    private var token:String = ""
    var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    @Published var ChatData: [ChatMessegeItem] = []
//    init(token: String) {
//        self.token = token
//        Connect()
//        PingBy10Sec()
//    }
    func SetToken(token: String){
        self.token = token
    }
    func Connect(){
        guard let url = URL(string: "wss://kp-medicals.com/ws?access_token=\(token)&uid=\(getDeviceUUID())&service_id=\(1)&fcm_token=\("fcmToken")&hospital_id=\(47)") else{
            print("소켓 URL 생성 실패")
            return
        }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        print("연결 \(url)")
        receiveMessage()
    }
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.UpdateChatList(ReciveText: text)
                    print("Received string: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    print("Unknown message type")
                }
                // 연결이 활성화되어 있으므로 계속해서 메시지 수신 대기
                self?.receiveMessage()
            }
        }
    }
//    전달 받은 텍스트 제이슨으로 파싱
    func UpdateChatList(ReciveText: String){
        guard let jsonData = ReciveText.data(using: .utf8) else{
            print("Error to jsonInvalid")
            return
        }
        do {
            let decodedData = try JSONDecoder().decode(OpenChatRoomDataModel.ChatMessage.self, from: jsonData)
            if decodedData.msg_type != 1{
                guard let FirstArray = decodedData.hospital_data?.all_status else{
                    print("초기 데이터 없음")
                    return
                }
                for arr in FirstArray{
                    let type = arr.value.content_type
                    let HospitalName = "진해병원"
                    let amI = arr.value.msg_type == "3"
                    if type == "text"{
                        ChatData.append(ChatMessegeItem(type: 1, HospitalName: HospitalName, messege: arr.value.message, ReadCount: false, time: arr.value.timestamp , amI: amI))
                    }
                }
                return
            }
            print("decode Success \(decodedData.msg_type)")
        }
        catch{
            print("decode Error : \(error)")
        }
    }
    func GetUserAccountString(token: String) -> (status: Bool,account:String){
        let sections = token.components(separatedBy: ".")
        if sections.count > 2 {
            if let payloadData = Data(base64Encoded: sections[1], options: .ignoreUnknownCharacters),
               let payloadJSON = try? JSONSerialization.jsonObject(with: payloadData, options: []) as? [String: Any],
               let userId = payloadJSON["user_id"] as? String {
                // user_id 값 출력
                return (true,userId)
            } else {
                print("Payload decoding or JSON parsing failed")
                return (false,"")
            }
        } else {
            print("Invalid JWT Token")
            return (false,"")
        }
    }
    func sendMessage(from: String, to: String, content_type: String, message:String? = nil, file_cnt: Int? = nil, file_ext: [String]? = nil) {
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
            return
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else{
            print("StringErr")
            return
        }
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(message, completionHandler: { Error in
            if let err = Error {
                print("Message Sending Err \(err.localizedDescription)")
            }else{
                print("SendSuccess")
            }
        })
    }
    func sendPingMessage() {
        if webSocketTask?.state == .running {
            webSocketTask?.sendPing(pongReceiveHandler: { error in
                if let error = error {
//                    print("PingError \(error)")
                } else {
//                    print("Ping successfully sent")
                }
            })
        } else {
//            print("WebSocket is not connected.")
        }
    }
    func PingBy10Sec(){
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.sendPingMessage()
//            print("SendPing")
        }
    }
    func disconnect() {
        webSocketTask?.cancel()
        timer?.invalidate()
        print("WebSocket connection closed and timer invalidated.")
    }
    deinit{
        timer?.invalidate()
        webSocketTask?.cancel()
        print("Ping deinit")
    }
}
