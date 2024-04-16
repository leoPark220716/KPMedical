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
                    self.ChatData.append(ChatMessegeItem(type: .text, messege: msg,  ReadCount: false, time: time.chatTime, amI: .user,chatDate: timeDate.chatTime,showETC: false))
                }
            }
            return
        }else{
            
        }
    }
    //    날짜 뷰 추가
    private func chatDateViewItem(ChatPreData: [ChatMessegeItem],date: String)->(error:Bool, Item: ChatMessegeItem?) {
        if ChatPreData.isEmpty{
            let item = ChatMessegeItem(type: .text, ReadCount: false, time: "", amI: .sepDate, chatDate: date, showETC: false)
            return (false, item)
        }else{
            if ChatPreData.last?.chatDate != date {
                let item = ChatMessegeItem(type: .text, ReadCount: false, time: "", amI: .sepDate, chatDate: date, showETC: false)
                return (false, item)
            }else{
                return (true, nil)
            }
        }
    }
    //    배열 재정렬
    private func sortedFristArray(array: [OpenChatRoomDataModel.ChatDetail])->(error:Bool, arr: [OpenChatRoomDataModel.ChatDetail]) {
        let item = array.sorted {
            guard let index1 = Int($0.chat_index), let index2 = Int($1.chat_index) else {
                return true }
            return index1 < index2
        }
        return (false, item)
    }
//    시간 뷰 세팅
    private func chatMessegeViewItem(ChatPreData: [ChatMessegeItem], preItem: OpenChatRoomDataModel.ChatDetail, time: String, date: String)->(updateLast:Bool, Item: ChatMessegeItem?) {
        guard let lastItem = ChatPreData.last else {
            return (false, nil)
        }
        //    마지막 채팅의 발신자가 누구인지
        let LastUser = lastItem.amI
        //    시간이 이전 것과 같은 지
        let isSameTime = lastItem.time == time
        //  메시지보낸사람이 나인지
        let isUserMessage = preItem.msg_type == "3"
        // type 할당
        let amI: ChatMessegeItem.AmI = isUserMessage ? .user : .other
        //    이전 체팅과 amI 가 같은지
        let isSame = isSameTime ? amI == LastUser : false
        let newItem = ChatMessegeItem(
            type: .text,
            HospitalName: "진해병원",
            messege: preItem.message,
            ReadCount: false,
            time: time,
            amI: amI,
            chatDate: date,
            showETC: true)
        return (isSame, newItem)
        
    }
    //    초기 데이터 파싱 (리팩토링 필수)
    func SetFirstData(decodedData: OpenChatRoomDataModel.ChatMessage){
        var ChatPreData: [ChatMessegeItem] = []
        guard let firstDict = decodedData.hospital_data?.all_status else{
            print("초기 데이터 파싱 실패")
            return
        }
        let sortedDetails = sortedFristArray(array: Array(firstDict.values))
        if sortedDetails.error{
            print("초기 데이터 정렬 실패")
            return
        }
        for arr in sortedDetails.arr{
            print(arr.message)
            let type = arr.content_type
            let time = timeHandler.timeChangeToChatTime(time: arr.timestamp)
            if type == "text"{
                //                날짜 비교 후 날짜 뷰 출력
                let dateChatSet = chatDateViewItem(ChatPreData: ChatPreData, date: time.chatDate)
                if !dateChatSet.error{
                    ChatPreData.append(dateChatSet.Item!)
                }
                //                채팅 시간.
                let appendDataAndUpdate = chatMessegeViewItem(ChatPreData: ChatPreData, preItem: arr, time: time.chatTime, date: time.chatDate)
                if appendDataAndUpdate.updateLast, !ChatPreData.isEmpty {
                    // 배열의 마지막 요소의 인덱스를 찾아 값을 수정합니다.
                    let lastIndex = ChatPreData.count - 1
                    ChatPreData[lastIndex].showETC = false
                }
                ChatPreData.append(appendDataAndUpdate.Item!)
            }else if type == "file"{
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


//function getS3URL(bucket, key){
//    const s3FileURL = `https://${bucket}.s3.ap-northeast-2.amazonaws.com`+'/'+key;
//    return s3FileURL; // https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/hospital_icon/default_hospital.png
//}
