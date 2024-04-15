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
    let timeHandler = TimeHandler()
    func SetToken(token: String){
        self.token = token
    }
    //    소켓 연결 URLSessionWebSocketTask 객체 생성 후 리시브 실행
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
    //    소켓 데이터 Recive
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
            switch decodedData.msg_type{
            case 1:
                SetFirstData(decodedData: decodedData)
            case 3:
                SetMsg(decodedData: decodedData)
            default:
                print("msg_type 범위 벗어남 : \(decodedData.msg_type)")
                return
            }
            if decodedData.msg_type == 1{
                
            }
            print("decode Success \(decodedData.msg_type)")
        }
        catch{
            print("decode Error : \(error)")
        }
    }
    //    메시지 전달 받은 데이터 파싱
    func SetMsg(decodedData: OpenChatRoomDataModel.ChatMessage){
        let amI = decodedData.msg_type == 3
        guard let msg = decodedData.content?.message else{
            print("메시지 없음")
            return
        }
        if decodedData.content_type == "text"{
            let time = timeHandler.timeChangeToChatTime(time: decodedData.timestamp!)
            let timeDate = timeHandler.returnyyyy_MM_dd(time: decodedData.timestamp!)
            if time.success && timeDate.success{
                DispatchQueue.main.async {
                    self.ChatData.append(ChatMessegeItem(type: 1, messege: msg,  ReadCount: false, time: time.chatTime, amI: amI,chatDate: timeDate.chatTime,isPadding: false))
                }
            }
            return
        }else{
            
        }
    }
    //    초기 데이터 파싱 (리팩토링 필수)
    func SetFirstData(decodedData: OpenChatRoomDataModel.ChatMessage){
        var ChatPreData: [ChatMessegeItem] = []
        guard let firstDict = decodedData.hospital_data?.all_status else{
            print("초기 데이터 파싱 실패")
            return
        }
        let sortedDetails = firstDict.values.sorted { $0.chat_index < $1.chat_index }
        var isFirst = true
        var isFirst2 = true
        for arr in sortedDetails{
            print(arr.message)
            let type = arr.content_type
            let HospitalName = "진해병원"
            let amI = arr.msg_type == "3"
            if type == "text"{
                let time = timeHandler.timeChangeToChatTime(time: arr.timestamp)
                let timeDate = timeHandler.returnyyyy_MM_dd(time: arr.timestamp)
                if isFirst{
                    ChatPreData.append(ChatMessegeItem(type: 4, messege: timeDate.chatTime, ReadCount: false, time: "" , amI: false ,chatDate: timeDate.chatTime,isPadding: false))
                 isFirst = false
                }else{
                    if ChatPreData.last?.chatDate != timeDate.chatTime{
                        ChatPreData.append(ChatMessegeItem(type: 4, messege: timeDate.chatTime, ReadCount: false, time: "" , amI: false ,chatDate: timeDate.chatTime,isPadding: false))
                    }
                }
                
                if !isFirst2 && ChatPreData.last?.type != 4 && ChatPreData.last?.amI == amI{
                    if ChatPreData.last?.time == time.chatTime {
                        if var lastItem = ChatPreData.last {
                                lastItem.isPadding = false
                                ChatPreData[ChatPreData.count - 1] = lastItem  // 배열의 마지막 위치에 수정된 요소 다시 할당
                            }
                        ChatPreData.append(ChatMessegeItem(type: 1, HospitalName: HospitalName, messege: arr.message, ReadCount: false, time: time.chatTime , amI: amI,chatDate: timeDate.chatTime,isPadding: true))
                    }else{
                        ChatPreData.append(ChatMessegeItem(type: 1, HospitalName: HospitalName, messege: arr.message, ReadCount: false, time: time.chatTime , amI: amI,chatDate: timeDate.chatTime,isPadding: true))
                    }
                    isFirst2 = false
                }else{
                    ChatPreData.append(ChatMessegeItem(type: 1, HospitalName: HospitalName, messege: arr.message, ReadCount: false, time: time.chatTime , amI: amI,chatDate: timeDate.chatTime,isPadding: true))
                    isFirst2 = false
                }
                
            }else{
                if let keytype = arr.key{
                    switch keytype {
                    case .string(let keyString):
                        print("파일아님\(keyString)")
                        let imageArr = returnStringToArray(jsonString: keyString)
                        print(imageArr.arr[0])
                    case .array(let keyArray):
                        print("사진 key값사진 key값사진 key값사진 key값사진 key값사진 key값 \(keyArray[0])")
                    }
                
                }
            }
        }
        DispatchQueue.main.async {
            print("Call")
            self.ChatData = ChatPreData
        }
    }
    
    
//     초기데이터 스트링 배열로 변환
    func returnStringToArray(jsonString: String) -> (success: Bool,arr: [String]){
        guard let jsonData = jsonString.data(using: .utf8) else{
            return (false,[])
        }
        do{
            let decoder = JSONDecoder()
            let stringArray = try decoder.decode([String].self, from: jsonData)
            return (true,stringArray)
        }catch{
            print("초기 이미지 스트링 변환 실패 \(error)")
            return (false,[])
        }
    }
    //    유저 ID 추출
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

////    핑 전송
//func sendPingMessage() {
//    if webSocketTask?.state == .running {
//        webSocketTask?.sendPing(pongReceiveHandler: { error in
//            if let error = error {
//                print("PingError \(error)")
//            }
//        })
//    } else {
//        print("WebSocket is not connected.")
//    }
//}
////    핑 10초 주기
//func PingBy10Sec(){
//    timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
//        self?.sendPingMessage()
//        //            print("SendPing")
//    }
//}


//function getS3URL(bucket, region, key){
//    const s3FileURL = `https://${bucket}.s3.${region}.amazonaws.com`+'/'+key;
//    return s3FileURL; // https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_icon/default_hospital.png
//}
