//
//  ChatList.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import SwiftUI

struct ChatList: View {
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onTapGesture {
                router.currentView = .chat
            }
    }
}

#Preview {
    ChatList()
}
