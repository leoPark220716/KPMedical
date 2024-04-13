//
//  SocketConnection.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import Foundation

class WebSocket: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var timer: Timer?
    init() {
        PingBy10Sec()
    }
    private func Connect(){
        guard let url = URL(string: "wss://kp-medicals.com/ws") else{
            print("소켓 URL 생성 실패")
            return
        }
        let request = URLRequest(url: url)
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()
        
    }
    private func receiveMessage(){
        webSocketTask?.receive{ result in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let message):
                print(message.self)
            }
        }
    }
    private func PingBy10Sec(){
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { time in
            print("ping Test")
        })
    }
    deinit{
        timer?.invalidate()
        print("Ping deinit")
    }
}
