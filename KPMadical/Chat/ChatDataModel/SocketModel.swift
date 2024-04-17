//
//  SocketModel.swift
//  KPMadical
//
//  Created by Junsung Park on 4/17/24.
//

import Foundation

class ChatSocketModel: ChatSocketDataHandler{
    private var token:String = ""
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
        webSocketTask?.resume()
        print("연결 \(url)")
        receiveMessage()
    }
    //    소켓 데이터 Recive
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error: \(error.localizedDescription)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let jsonData = self?.UpdateChatList(ReciveText: text)
                    guard let json = jsonData else{
                        print("json 파싱 실패")
                        return
                    }
                    if !json.err {
                        self?.MethodCall(jsonData: json.jsonData!)
                    }
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
    //    소켓 연결 끊기
    func disconnect() {
        webSocketTask?.cancel()
        timer?.invalidate()
        print("WebSocket connection closed and timer invalidated.")
    }
    //    객체 종료
    deinit{
        timer?.invalidate()
        webSocketTask?.cancel()
        print("Ping deinit")
    }
}
