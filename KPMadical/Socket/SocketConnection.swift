//
//  SocketConnection.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import Foundation

class WebSocket: ObservableObject {
    var webSocketTask: URLSessionWebSocketTask?
    var timer: Timer?
    @Published var ChatData: [ChatMessegeItem] = []
    let timeHandler = TimeHandler()
    //    배열 재정렬
    func sortedFristArray(array: [OpenChatRoomDataModel.ChatDetail])->(error:Bool, arr: [OpenChatRoomDataModel.ChatDetail]) {
        let item = array.sorted {
            guard let index1 = Int($0.chat_index), let index2 = Int($1.chat_index) else {
                return true }
            return index1 < index2
        }
        return (false, item)
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
    //    전달 받은 텍스트 제이슨으로 파싱
    func UpdateChatList(ReciveText: String) -> (err:Bool, jsonData:Data?){
        guard let jsonData = ReciveText.data(using: .utf8) else{
            print("Error to jsonInvalid")
            return (true,nil)
        }
        return (false,jsonData)
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
