//
//  SwiftUIView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//

import SwiftUI

struct HomeView: View {
    var logined: Bool
    @State private var showSignUp = false
    var body: some View {
        ZStack{
            Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea()
            VStack{
                Text("Home화면")
                    .onTapGesture {
                        if !logined {
                            showSignUp = true
                        }
                    }
                    .fullScreenCover(isPresented: $showSignUp){
                        LoginView()
                    }
            }
        }
    }
}


#Preview {
    HomeView(logined: false)
}
