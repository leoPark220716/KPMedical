//
//  Chat.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI
import CoreLocation
import PhotosUI

struct Chat: View {
    @EnvironmentObject var userInfo: UserInformation
    @State private var isVisible: Bool = false // 뷰의 표시 여부를 결정하는 상태 변수
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var ChatText = ""
    @ObservedObject var Socket = ChatSocketModel()
    @Environment(\.scenePhase) private var scenePhase
    // 채팅 텍스트 필드 포커스
    @FocusState private var chatField: Bool
    // 체팅 Plus 버튼 클릭
    @State private var TabPlus = true
    @EnvironmentObject var router: GlobalViewRouter
    @State var selectedItems: [PhotosPickerItem] = []
    @State var SendingImages: [UIImage] = []
    @State var SendingImagesByte: [Data] = []
    let controler = ChatViewHandler()
    var data: parseParam
    @State var HospitalImage = ""
    @State var ChatId: Int = 0
    @State private var importing = false
    @State private var toast: normal_Toast? = nil
    var body: some View {
            VStack{
                ScrollView{
                    LazyVStack{
                        if !Socket.ChatData.isEmpty{
                            ForEach(Socket.ChatData.indices, id: \.self){ index in
                                ChatItemView(item: $Socket.ChatData[index], items:$Socket.ChatData , img: $HospitalImage, HospitalName: data.name, index: Int(index))
                                    .onAppear {
                                        if ChatId != 0{
                                            if index == Socket.ChatData.count - 3 {
                                                Socket.loadMoreData(token: userInfo.token, chatId: ChatId)
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        print("✅ Date Time \(Socket.ChatData[index])")
                                    }
                            }
                            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                            .rotationEffect(Angle(degrees: 180))
                        }
                    }
                }
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .rotationEffect(Angle(degrees: 180))
                .padding(.bottom,4)
                .onTapGesture {
                    chatField = false
                }
                .padding(.bottom, 12)
                .background(Color.gray.opacity(0.1))
                VStack{
                    HStack{
                        Image(systemName: TabPlus ? "plus" : "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(.leading)
                            .onTapGesture {
                                if !TabPlus{
                                    cleanDataArray()
                                }
                                let result = ChatViewHandler().ControlBottomView(TabPlus: TabPlus, chatField: chatField, ChatText: ChatText)
                                TabPlus = result.TabPlus
                                chatField = result.chatField
                                ChatText = result.ChatText
                            }
                        HStack{
                            TextEditor(text: $ChatText)
                                .focused($chatField)
                                .onTapGesture {
                                    TabPlus = true
                                }
                            if ChatText != "" || !controler.SendingImages.isEmpty {
                                Image(systemName: "paperplane.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    .onTapGesture {
                                        if controler.SendingImages.isEmpty{
                                            let textItem = Socket.preMessageItem(type: .text,messege: ChatText ,time: "", date: "", amI:ChatMessegeItem.AmI.user)
                                            Socket.ChatData.insert(textItem, at: 0)
                                        }else{
                                            let textItem = Socket.preMessageItem(type: .photo,messege: ChatText ,time: "", date: "", amI:ChatMessegeItem.AmI.user)
                                            Socket.ChatData.insert(textItem, at: 0)
                                        }
                                        let from = Socket.GetUserAccountString(token: userInfo.token)
                                        if controler.SendingImages.isEmpty{
                                            if from.status{
                                                print("Account \(from.account)")
                                                Task{
                                                    let success = await Socket.sendMessage(msg_type: 3 ,from: from.account, to: String(data.hospital_id), content_type: "text", message: ChatText)
                                                    if success{
                                                        print("메시지 전송 성공")
                                                    }else{
                                                        print("메시지 전송 실패")
                                                    }
                                                    ChatText = ""
                                                }
                                            }
                                        }else{
                                            if from.status{
                                                print("Account \(from.account)")
                                                let file_ext = Array(repeating: ".png", count: controler.SendingImages.count)
                                                let file_name = Array(repeating: "1", count: controler.SendingImages.count)
                                                Task{
                                                    let check = await Socket.sendMessage(msg_type: 3,from: from.account, to: String(data.hospital_id), content_type: "file",file_cnt: SendingImages.count,file_ext:file_ext,file_name:file_name)
                                                    if check{
                                                        print("메타데이터 전송 성공")
                                                        for index in 0..<SendingImagesByte.count{
                                                            Socket.SendFileData(data: SendingImagesByte[index])
                                                        }
                                                    }else{
                                                        print("메시지 전송 실패")
                                                    }
                                                    SendingImages.removeAll()
                                                    SendingImagesByte.removeAll()
                                                    selectedItems.removeAll()
                                                    TabPlus = true
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.leading)
                        .frame(height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        .padding(.trailing, 10)
                    }
                    .padding(.top,4)
                    if !TabPlus && SendingImages.isEmpty{
                        HStack{
                            PhotosPicker(
                                selection: $selectedItems,
                                maxSelectionCount: 20,
                                selectionBehavior: .default,
                                matching: .images,
                                preferredItemEncoding: .automatic
                            ) {
                                SocialLoginButton(systemName: "photo.fill", color: .green.opacity(0.5))
                                    .padding(.leading)
                            }
                            .onChange(of:selectedItems){
                                print("Change")
                                //                                보여줄 이미지
                                var sendingImages: [UIImage] = []
                                //                                보낼 이미지 데이터
                                var sendingImagesByte: [Data] = []
                                print("Change\(selectedItems.count)")
                                let taskGroup = DispatchGroup()
                                for imgs in selectedItems{
                                    taskGroup.enter()
                                    imgs.loadTransferable(type: Data.self) { result in
                                        switch result {
                                        case .success(let data):
                                            if let data = data, let image = UIImage(data: data) {
                                                sendingImages.append(image)
                                                sendingImagesByte.append(controler.PngReturnByData_Img(data:data,img:image))
                                                print("ChangeDone")
                                            }
                                        case .failure(let error):
                                            print("Error loading image: \(error)")
                                        }
                                        taskGroup.leave()
                                    }
                                }
                                taskGroup.wait()
                                taskGroup.notify(queue: .main){
                                    self.SendingImages = sendingImages
                                    self.SendingImagesByte = sendingImagesByte
                                    sendingImagesByte = []
                                    sendingImages = []
                                    print("finish : \(SendingImagesByte.count)")
                                }
                            }
                            SocialLoginButton(systemName: "camera.fill", color: .blue.opacity(0.5))
                            Button{
                                importing = true
                            } label: {
                                SocialLoginButton(systemName: "folder.fill", color: .yellow.opacity(0.5))
                            }
                            .fileImporter(
                                isPresented: $importing,
                                allowedContentTypes: [.item]
                            ){ result in
                                switch result {
                                case .success(let file):
                                    if file.startAccessingSecurityScopedResource() {  // 권한 요청 시작
                                        defer { file.stopAccessingSecurityScopedResource() }  // 작업 완료 후 권한 해제
                                        do {
                                            let from = Socket.GetUserAccountString(token: userInfo.token)
                                            let fileData = try Data(contentsOf: file)
                                            let fileExtension = file.pathExtension
                                            let fileNameBase = file.deletingPathExtension().lastPathComponent
                                            let isSpecialFile = fileNameBase == "1" || fileNameBase == "2"
                                            let fileName = isSpecialFile ? "\(fileNameBase)\(fileExtension)" : fileNameBase
                                            let extensions = [".\(fileExtension)"]
                                            let fileNames = [fileName]
                                            print("🫡 File Get Success FileName \(fileNames[0])")
                                            print("🫡 File Get Success Extensions \(extensions[0])")
                                            Task{
                                                let check = await Socket.sendMessage(msg_type: 3,from: from.account, to: String(data.hospital_id), content_type: "file",file_cnt: 1 ,file_ext: extensions, file_name: fileNames)
                                                if check{
                                                    Socket.SendFileData(data: fileData)
                                                }
                                            }
                                        } catch {
                                            print("❌ File 데이터 변환 실패: \(error)")
                                        }
                                    } else {
                                        print("❌ 파일 접근 권한을 얻지 못했습니다.")
                                    }
                                case .failure(let error):
                                    print("❌ File Get error \(error.localizedDescription)")
                                }
                            }
                            Spacer()
                        }
                        .cornerRadius(10)
                        .background(Color.white)
                        .padding(.top)
                    }
                    if !TabPlus && !SendingImages.isEmpty{
                        ScrollView(.horizontal, showsIndicators: false) { // 가로 스크롤 활성화
                            HStack(spacing: 10) { // 이미지들 사이의 간격을 10으로 설정
                                ForEach(SendingImages.indices, id: \.self) { index in
                                    SendImageItemView(SendingImageArray: $SendingImages, SendingImagesByte: $SendingImagesByte,selectedItems: $selectedItems,index: index,SendingImage: $SendingImages[index])
                                        .frame(width: 150, height: 200)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom,10)
            }
            .onChange(of: router.toast){
                if router.toast == true{
                    print("show Toast")
                    toast = normal_Toast(message: "다운로드가 완료되었습니다.")
                    router.toast = false
                }
            }
            .normalToastView(toast: $toast)
            .onAppear{
                let httpStructCheck = http<Empty?, KPApiStructFrom<ChatHTTPresponseStruct.CreateResponse>>.init(method:"GET", urlParse:"v2/chat/room?service_id=1&hospital_id=\(data.hospital_id)", token: userInfo.token, UUID: getDeviceUUID())
                Task{
                    let result = await HttpRequest(HttpStructs: httpStructCheck)
                    if result.success{
                        print("🫡 \(result.data!.message)")
                        if result.data!.data.chat_id != -1{
                            ChatId = result.data!.data.chat_id
                            print("🫡 \(ChatId)")
                            let httpStruct = http<Empty?, KPApiStructFrom<ChatHTTPresponseStruct.MessageData>>.init(method:"GET", urlParse:"v2/chat/\(result.data!.data.chat_id)?service_id=1", token: userInfo.token, UUID: getDeviceUUID())
                            let result = await HttpRequest(HttpStructs: httpStruct)
                            if result.success{
                                var chatItem: [ChatHTTPresponseStruct.Chat_Message] = []
                                chatItem = result.data?.data.messages ?? []
                                print(chatItem.first?.message ?? "?????")
                                Socket.SetFirstData(decodedData: chatItem, hospitalTime: result.data?.data.chat_info?.h_connected_time)
                                HospitalImage = result.data?.data.chat_info?.icon ?? ""
                            }
                        }else{
                            let joinRoomData = ChatHTTPresponseStruct.JoinRoom.init(service_id: 1, hospital_id: data.hospital_id)
                            let httpStruct = http<ChatHTTPresponseStruct.JoinRoom?, KPApiStructFrom<ChatHTTPresponseStruct.CreateResponse>>(
                                method: "POST",
                                urlParse: "v2/chat",
                                token: userInfo.token,
                                UUID: getDeviceUUID(),
                                requestVal: joinRoomData // POST 데이터 제공
                            )
                            let result = await HttpRequest(HttpStructs: httpStruct)
                            if result.success{
                                print("채팅방 생성")
                                print(result.data!.data.chat_id)
                            }
                        }
                    }
                }
                Socket.SetToken(token: userInfo.token)
                Socket.Connect(hospitalId: data.hospital_id,fcmToken: userInfo.FCMToken)
            }
            .onChange(of: scenePhase){
                switch scenePhase{
                case .active:
                    if Socket.webSocketTask?.state != .running{
                        Socket.Connect(hospitalId: data.hospital_id,fcmToken: userInfo.FCMToken)
                    }
                    print("App is active")
                case .inactive:
                    print("App is inactive")
                case .background:
                    Task{
                        let from = Socket.GetUserAccountString(token: userInfo.token)
                        let success = await Socket.sendMessage(msg_type: 2 ,from: from.account, to: "", content_type: "", message: "")
                        if success{
                            print("메시지 전송 성공")
                            Socket.disconnect()
                        }else{
                            print("메시지 전송 실패")
                            Socket.disconnect()
                        }
                    }
                    Socket.disconnect()
                    print("App is in the background")
                @unknown default:
                    print("Unknown phase")
                }
            }
        .navigationTitle(String(data.name))
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigation){
                Button(action:{
                    Task{
                        let from = Socket.GetUserAccountString(token: userInfo.token)
                        let success = await Socket.sendMessage(msg_type: 2 ,from: from.account, to: "", content_type: "", message: "")
                        if success{
                            print("메시지 전송 성공")
                            Socket.disconnect()
                            router.goBack()
                        }else{
                            print("메시지 전송 실패")
                            Socket.disconnect()
                            router.goBack()
                        }
                    }
                }){
                    Image(systemName: "chevron.left")
                }
            }
        }
    }
    private func cleanDataArray(){
        SendingImages.removeAll()
        SendingImagesByte.removeAll()
        selectedItems.removeAll()
    }
}

//class ChatViewModel: ObservableObject{
//    @Published var hospitalImage: String ""
//    @Published var
//}
