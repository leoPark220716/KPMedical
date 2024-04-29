//
//  ChatTEst.swift
//  KPMadical
//
//  Created by Junsung Park on 4/18/24.
//

import SwiftUI


#Preview {
    ChatTEst()
}
struct ChatTEst: View {
    @StateObject private var manager = NotificationManager()
    var body: some View {
        Button("Request Notification\n Permission"){
            Task{
                await manager.request()
            }
        }
        AsyncImage(url: URL(string:"https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1%231714336746440246849.png")){
            image in
            image.resizable()
        }placeholder: {
            ProgressView()
        }
    
        .buttonStyle(.bordered)
        .disabled(manager.hasPermission)
        .task {
            await manager.getAuthStatus()
        }
    }
    
    
}
