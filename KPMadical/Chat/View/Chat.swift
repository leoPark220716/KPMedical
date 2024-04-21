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
    let controler = ChatViewHandler()
    @State var SendingImages: [UIImage] = []
    @State var SendingImagesByte: [Data] = []
    var data: parseParam
    var body: some View {
        NavigationView(content: {
            VStack{
                ScrollView{
                    ForEach(Socket.ChatData.indices, id: \.self){ index in
                        ChatItemView(item: $Socket.ChatData[index],items: $Socket.ChatData,index: index)
                    }
                    .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                    .rotationEffect(Angle(degrees: 180))
                    .padding(.top)
                    
                }
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .rotationEffect(Angle(degrees: 180))
                .background(Color.gray.opacity(0.1))
                .padding(.bottom,10)
                .onTapGesture {
                    chatField = false
                }
                VStack{
                    HStack{
                        Image(systemName: TabPlus ? "plus" : "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding(.leading)
                            .onTapGesture {
                                if !TabPlus{
                                    SendingImages.removeAll()
                                    SendingImagesByte.removeAll()
                                    selectedItems.removeAll()
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
                            if ChatText != "" || !SendingImages.isEmpty {
                                Image(systemName: "paperplane.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                    .onTapGesture {
                                        if SendingImages.isEmpty{
                                            let textItem = Socket.preMessageItem(type: .text,messege: ChatText ,time: "", date: "", amI:ChatMessegeItem.AmI.user)
                                            Socket.ChatData.append(textItem)
                                        }else{
                                            let textItem = Socket.preMessageItem(type: .photo,messege: ChatText ,time: "", date: "", amI:ChatMessegeItem.AmI.user)
                                            Socket.ChatData.append(textItem)
                                        }
                                        let from = Socket.GetUserAccountString(token: userInfo.token)
                                        if SendingImages.isEmpty{
                                            if from.status{
                                                print("Account \(from.account)")
                                                Task{
                                                    let success = await Socket.sendMessage(from: from.account, to: "47", content_type: "text", message: ChatText)
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
                                                let file_ext = Array(repeating: ".png", count: SendingImages.count)
                                                Task{
                                                   let check = await Socket.sendMessage(from: from.account, to: "47", content_type: "file",file_cnt: SendingImages.count,file_ext:file_ext)
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
                                    print("finish : \(SendingImagesByte.count)")
                                }
                            }
                            SocialLoginButton(systemName: "camera.fill", color: .blue.opacity(0.5))
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
            .onAppear{
                Socket.SetToken(token: userInfo.token)
                Socket.Connect()
            }
            .onChange(of: scenePhase){
                switch scenePhase{
                case .active:
                    if Socket.webSocketTask?.state != .running{
                        Socket.Connect()
                    }
                    print("App is active")
                case .inactive:
                    print("App is inactive")
                case .background:
                    Socket.disconnect()
                    print("App is in the background")
                @unknown default:
                    print("Unknown phase")
                }
            }
        }
            )
        .navigationTitle(String(data.des))
        
    }
    
}






struct TestChatData : Codable{
    var text: String
    var My: Int
    var id: Int
}
