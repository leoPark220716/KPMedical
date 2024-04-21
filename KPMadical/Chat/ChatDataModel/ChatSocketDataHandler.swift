//
//  ChatSocketDataHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 4/17/24.
//

import Foundation

class ChatSocketDataHandler: ChatSocketRequest{
    //    날짜 뷰 추가
    func chatDateViewItem(ChatPreData: [ChatMessegeItem],date: String)->(error:Bool, Item: ChatMessegeItem?) {
        if ChatPreData.isEmpty{
            let item = ChatMessegeItem(type: .text, ReadCount: false, time: "", amI: .sepDate, chatDate: date, showETC: false, progress: false)
            return (false, item)
        }else{
            for index in ChatPreData.indices.reversed() {
                if ChatPreData[index].progress == false{
                    if ChatPreData[index].chatDate != date{
                        let item = ChatMessegeItem(type: .text, ReadCount: false, time: "", amI: .sepDate, chatDate: date, showETC: false, progress: false)
                        return (false, item)
                    }else{
                        return (true, nil)
                    }
                }
            }
            return (true, nil)
        }
    }
    func MethodCall(jsonData: Data){
        do {
            let decodedData = try JSONDecoder().decode(OpenChatRoomDataModel.ChatMessage.self, from: jsonData)
            switch decodedData.msg_type{
            case 1:
                SetFirstData(decodedData: decodedData)
            case 3:
                SetMsg(decodedData: decodedData)
            case 5:
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
    
    //    소켓 연결 중에 받은 메시지 데이터
    func SetMsg(decodedData: OpenChatRoomDataModel.ChatMessage){
        guard let msg = decodedData.content?.message else{
            print("메시지 없음")
            return
        }
        let time = timeHandler.timeChangeToChatTime(time: decodedData.timestamp!)
        if time.success{
            let dateView = chatDateViewItem(ChatPreData: ChatData, date: time.chatDate)
            
            let messages = MessegeTimeControl(ChatPreData: ChatData, msg_type: String(decodedData.msg_type), time: time.chatTime, date: time.chatDate)
            //                    날짜
            if !dateView.error{
                for index in self.ChatData.indices.reversed() {
                    if self.ChatData[index].progress == false{
                        DispatchQueue.main.async {
                            self.ChatData[index+1] = dateView.Item!
                        }
                        break
                    }
                }
            }
            //                    시간
            if messages.update,!self.ChatData.isEmpty{
                for index in ChatData.indices.reversed() {
                    if ChatData[index].progress == false && ChatData[index].amI == messages.amI{
                        DispatchQueue.main.async {
                            self.ChatData[index].showETC = false
                        }
                        break
                    }
                }
            }
            switch self.messageType(contentType: decodedData.content_type, fileArray: decodedData.content?.key as? OpenChatRoomDataModel.KeyType, bucket: decodedData.content?.bucket as? OpenChatRoomDataModel.KeyType,msg_type: decodedData.msg_type) {
            case .text:
                let textItem = self.textMessageItem(type: .text, messege: msg, time: time.chatTime, date: time.chatDate, amI: messages.amI!)
                
                if messages.amI == .user{
                    for index in self.ChatData.indices.reversed() {
                        if self.ChatData[index].progress == true{
                            DispatchQueue.main.async {
                                self.ChatData[index] = textItem
                            }
                            break
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.ChatData.append(textItem)
                    }
                }
                
            case .photo:
                guard let key = decodedData.content?.key , let bucket = decodedData.content?.bucket else{
                    print("버킷이 없다.")
                    return
                }
                let makeImageArray = determineFileType(from: key, bucket: bucket)
                let ImageArray = returnURIArray(image: makeImageArray.imageArray)
                let textItem = self.textMessageItem(type: .photo, time: time.chatTime, date: time.chatDate, amI: messages.amI!,imgAr: ImageArray.imgArray)
                if messages.amI == .user{
                    for index in self.ChatData.indices.reversed() {
                        if self.ChatData[index].progress == true{
                            DispatchQueue.main.async {
                                self.ChatData[index] = textItem
                            }
                            break
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        self.ChatData.append(textItem)
                    }
                }
                print("Pohto")
            case .file:
                print("file")
            case .notice:
                let textItem = self.textMessageItem(type: .notice,messege: msg, time: time.chatTime, date: time.chatDate, amI: messages.amI!)
                DispatchQueue.main.async {
                    self.ChatData.append(textItem)
                }
                print("notice")
            case .unowned:
                print("unowned")
            }
        }
    }
    //    시간 뷰 세팅
    func MessegeTimeControl(ChatPreData: [ChatMessegeItem], msg_type: String, time: String, date: String)->(update: Bool,amI: ChatMessegeItem.AmI?) {
        guard var lastItem = ChatPreData.last else {
            return (false,nil)
        }
        for index in ChatPreData.indices.reversed() {
            if ChatPreData[index].progress == false{
                lastItem = ChatPreData[index]
                break
            }
        }
        //    마지막 채팅의 발신자가 누구인지
        let LastUser = lastItem.amI
        //    시간이 이전 것과 같은 지
        let isSameTime = lastItem.time == time
        //  메시지보낸사람이 나인지
        let isUserMessage = msg_type == "3"
        // type 할당
        let amI: ChatMessegeItem.AmI = isUserMessage ? .user : .other
        //    이전 체팅과 amI 가 같은지
        let isSame = isSameTime ? amI == LastUser : false
        
        return (isSame,amI)
    }
    //    메시지 타입 반환
    func messageType(contentType: String, fileArray: OpenChatRoomDataModel.KeyType? = nil, bucket: OpenChatRoomDataModel.KeyType? = nil,msg_type: Any? = nil) -> ChatMessegeItem.MessageTypes {
        print("messageType \(contentType)")
        print("messageType\(String(describing: msg_type))")
        switch contentType {
        case "text":
            print(msg_type as Any)
            if msg_type == nil{
                return .text
            }
            return testMessgaeType(msg_type:msg_type).msg_type
        default:
            // fileType 함수 호출 전에 두 매개변수 모두 nil이 아닌지 확인
            if let keyType = fileArray, let bucketType = bucket {
                return determineFileType(from: keyType, bucket: bucketType).fileType
            } else {
                return .unowned  // 파일 유형 정보가 없는 경우 적절하게 처리
            }
        }
    }
    func testMessgaeType(msg_type: Any?) -> (success: Bool, msg_type: ChatMessegeItem.MessageTypes){
        if let stringType = msg_type as? String{
            if stringType == "5"{
                return (true, .notice)
            }
        }else if let intType = msg_type as? Int{
            if intType == 5{
                return (true, .notice)
            }
        }
        return (false, .text)
    }
    
    
    
    func determineFileType(from keyType: OpenChatRoomDataModel.KeyType, bucket: OpenChatRoomDataModel.KeyType) -> (fileType: ChatMessegeItem.MessageTypes, imageArray: [(String, String)]) {
        print("테스트 determineFileType 호출")
        var imageArray: [String] = []
        var bucketArray: [String] = []
        
        // Key 처리
        switch keyType {
        case .string(let fileString):
            print("테스트 Key String: \(fileString)")
            imageArray = returnStringToArray(jsonString: fileString).arr
        case .array(let fileArray):
            print("테스트 Key Array: \(fileArray)")
            imageArray = fileArray
        }
        
        // Bucket 처리
        switch bucket {
        case .string(let bucketString):
            print("테스트 Bucket String: \(bucketString)")
            bucketArray = returnStringToArray(jsonString: bucketString).arr
        case .array(let bucketArrayValues):
            print("테스트 Bucket Array: \(bucketArrayValues)")
            bucketArray = bucketArrayValues
        }
        
        // 이미지와 버킷 배열의 결합
        if imageArray.isEmpty || bucketArray.isEmpty || imageArray.count != bucketArray.count {
            return (.unowned, [])
        }
        
        let combinedArray = zip(imageArray, bucketArray).map { ($0, $1) }
        let fileType = fileType(for: imageArray.first ?? "") // 첫 번째 파일 경로로 파일 유형 결정
        
        return (fileType, combinedArray)
    }
    
    private func fileType(for filePath: String) -> ChatMessegeItem.MessageTypes {
        if filePath.contains("png") || filePath.contains("jpg") {
            return .photo
        } else {
            return .file
        }
    }
    
    
    //    텍스트 메시지 삽입
    func textMessageItem(type: ChatMessegeItem.MessageTypes,messege: String? = nil, time: String, date: String,amI: ChatMessegeItem.AmI,imgAr: [String]? = nil)->(ChatMessegeItem) {
        let newItem = ChatMessegeItem(
            type: type,
            HospitalName: "진해병원",
            messege: messege,
            ReadCount: false,
            time: time,
            amI: amI,
            chatDate: date,
            showETC: true,
            ImageArray: imgAr,
            progress: false
        )
        return (newItem)
    }
    func preMessageItem(type: ChatMessegeItem.MessageTypes,messege: String? = nil, time: String, date: String,amI: ChatMessegeItem.AmI,imgAr: [String]? = nil)->(ChatMessegeItem) {
        let newItem = ChatMessegeItem(
            type: type,
            HospitalName: "진해병원",
            messege: messege,
            ReadCount: false,
            time: time,
            amI: amI,
            chatDate: date,
            showETC: true,
            ImageArray: imgAr,
            progress: true
        )
        return (newItem)
    }
    
    //    초기 데이터 파싱 (리팩토링 필수)
    func SetFirstData(decodedData: OpenChatRoomDataModel.ChatMessage){
        //
        print("초기데이터 함수 호출")
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
            print("arr ContentType 출력\(arr.content_type)")
            let time = timeHandler.timeChangeToChatTime(time: arr.timestamp)
            
            //                날짜 비교 후 날짜 뷰 출력
            let dateChatSet = chatDateViewItem(ChatPreData: ChatPreData, date: time.chatDate)
            if !dateChatSet.error{
                ChatPreData.append(dateChatSet.Item!)
            }
            //                채팅 시간.
            let appendDataAndUpdate = MessegeTimeControl(ChatPreData: ChatPreData,msg_type: arr.msg_type,time: time.chatTime, date: time.chatDate)
            if appendDataAndUpdate.update, !ChatPreData.isEmpty {
                // 배열의 마지막 요소의 인덱스를 찾아 값을 수정합니다.
                let lastIndex = ChatPreData.count - 1
                ChatPreData[lastIndex].showETC = false
            }
            switch self.messageType(contentType: arr.content_type,fileArray: arr.key,bucket: arr.bucket,msg_type: arr.msg_type){
            case .text:
                let textItem = self.textMessageItem(type: .text, messege: arr.message, time: time.chatTime, date: time.chatDate, amI: appendDataAndUpdate.amI!)
                ChatPreData.append(textItem)
                print("text")
            case .photo:
                print("Photo")
                guard let key = arr.key , let bucket = arr.bucket else{
                    print("버킷이 없다.")
                    return
                }
                let makeImageArray = determineFileType(from: key, bucket: bucket)
                let ImageArray = returnURIArray(image: makeImageArray.imageArray)
                let textItem = self.textMessageItem(type: .photo, messege: arr.message, time: time.chatTime, date: time.chatDate, amI: appendDataAndUpdate.amI!,imgAr: ImageArray.imgArray)
                ChatPreData.append(textItem)
            case .file:
                print("file")
            case .notice:
                let textItem = self.textMessageItem(type: .notice,messege: arr.message, time: time.chatTime, date: time.chatDate, amI: appendDataAndUpdate.amI!)
                print("notice amI Data \(appendDataAndUpdate.amI!)")
                ChatPreData.append(textItem)
                print("notice")
            case .unowned:
                print("unowned")
            }
            //                ChatPreData.append(appendDataAndUpdate.Item!)
            //            }else if type == "file"{
            //                if let keytype = arr.key{
            //                    switch keytype {
            //                    case .string(let keyString):
            //                        print("파일아님\(keyString)")
            //                        let imageArr = returnStringToArray(jsonString: keyString)
            //                        print("사진 key값사진 key값사진 key값사진 key값사진 key값사진 key값 \(imageArr.arr[0])")
            //                    case .array(let keyArray):
            //                        print("사진 key값사진 key값사진 key값사진 key값사진 key값사진 key값 \(keyArray[0])")
            //                    }
            //                }
            //            }
        }
        DispatchQueue.main.async {
            print("Call")
            self.ChatData = ChatPreData
        }
    }
    func returnURIArray(image: [(String,String)]) -> (success: Bool, imgArray: [String]){
        var Array: [String] = []
        for index in 0 ..< image.count{
            print("이미지 이름 : \(image[index].0)")
            print("이미지 버켓 : \(image[index].1)")
            Array.append("https://\(image[index].1).s3.ap-northeast-2.amazonaws.com/\(image[index].0)")
        }
        if !Array.isEmpty{
            return (false, Array)
        }
        return (true, Array)
    }
}
