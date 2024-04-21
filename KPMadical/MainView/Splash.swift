//
//  Splash.swift
//  KPMadical
//
//  Created by Junsung Park on 4/20/24.
//

import SwiftUI

struct Splash: View {
    var body: some View {
        ZStack{
            Color("SplashBack").edgesIgnoringSafeArea(.all) // 화면 전체에 색상 적용
            VStack {
                Text("KP Madical")
                    .font(.system(size: 40))
                    .bold()
                    .foregroundColor(.black) // 텍스트 색상을 밝은 색으로 설정
                    .padding(.top, 100) // 상단 여백 추가
                Spacer() // 나머지 공간을 모두 차지하도록 설정
            }
            Image("Splash")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    Splash()
}
