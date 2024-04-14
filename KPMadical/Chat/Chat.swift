//
//  Chat.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI
import CoreLocation

struct Chat: View {
    @ObservedObject var userInfo: UserObservaleObject
    @State private var isVisible: Bool = false // 뷰의 표시 여부를 결정하는 상태 변수
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var ChatText = ""
    @State private var TextArray: [TestChatData] = []
    @ObservedObject var Socket = WebSocket()
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        VStack{
            ScrollView{
                ForEach(TextArray.indices, id:\.self){ index in
                    if TextArray[index].My == 0{
                        OthersChatItem(testArr: $TextArray[index])
                    }else{
                        MyChatItem(testArr: $TextArray[index])
                    }
                }
                .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
                .rotationEffect(Angle(degrees: 180))
                .padding(.top)
            }
            .scaleEffect(x: -1.0, y: 1.0, anchor: .center)
            .rotationEffect(Angle(degrees: 180))
            .background(Color.gray.opacity(0.1))
            HStack{
                Image(systemName: "plus")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(.leading)
                HStack{
                    TextField("체팅을 입려해주세요.", text: $ChatText)
                    Image(systemName: "paperplane.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        .onTapGesture {
                            let from = Socket.GetUserAccountString(token: userInfo.token)
                            if from.status{
                                Socket.sendMessage(from: from.account, to: "47", content_type: "text", message: ChatText)
                            }
                            //                            router.currentView = .tab
                            //                            TextArray.append(TestChatData(text: ChatText, My: 1, id: TextArray.count))
                            //                            ChatText = ""
                        }
                }
                .padding(.leading)
                .frame(height: 40)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                .padding(.trailing, 10)
            }
        }
        .onAppear{
            Socket.SetToken(token: userInfo.token)
            Socket.Connect()
            Socket.PingBy10Sec()
            for index in 0...19{
                TextArray.append(TestChatData(text: "가나다\(index)", My: Int.random(in: 0...1), id: index))
            }
            
        }
        .onChange(of: scenePhase){
            switch scenePhase{
            case .active:
                if Socket.webSocketTask?.state != .running{
                    Socket.Connect()
                    Socket.PingBy10Sec()
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
}






struct TestChatData : Codable{
    var text: String
    var My: Int
    var id: Int
}
