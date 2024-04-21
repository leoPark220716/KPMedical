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
        .buttonStyle(.bordered)
        .disabled(manager.hasPermission)
        .task {
            await manager.getAuthStatus()
        }
    }
    
    
}
