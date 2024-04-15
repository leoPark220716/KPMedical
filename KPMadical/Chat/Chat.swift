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
    @ObservedObject var userInfo: UserObservaleObject
    @State private var isVisible: Bool = false // 뷰의 표시 여부를 결정하는 상태 변수
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var ChatText = ""
    @ObservedObject var Socket = WebSocket()
    @Environment(\.scenePhase) private var scenePhase
// 채팅 텍스트 필드 포커스
    @FocusState private var chatField: Bool
// 체팅 Plus 버튼 클릭
    @State private var TabPlus = true
    @EnvironmentObject var router: GlobalViewRouter
    @State private var selectedItems: [PhotosPickerItem] = []
    let controler = ChatViewHandler()
    var body: some View {
        NavigationView(content: {
            VStack{
                ScrollView{
                        ForEach(Socket.ChatData.indices, id: \.self){ index in
                            ChatItemView(item: $Socket.ChatData[index])
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
                            Image(systemName: "paperplane.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .onTapGesture {
                                    let from = Socket.GetUserAccountString(token: userInfo.token)
                                    if from.status{
                                        print("Account \(from.account)")
                                        Socket.sendMessage(from: from.account, to: "47", content_type: "text", message: ChatText)
                                        ChatText = ""
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
                    if !TabPlus{
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
                                
                            }
                            
                            SocialLoginButton(systemName: "camera.fill", color: .blue.opacity(0.5))
                            Spacer()
                        }
                        .cornerRadius(10)
                        .background(Color.white)
                        .padding(.top)
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
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button(action:{
                        router.currentView = .tab
                    }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
        })
    }
}






struct TestChatData : Codable{
    var text: String
    var My: Int
    var id: Int
}
