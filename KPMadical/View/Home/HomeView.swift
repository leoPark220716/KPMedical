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
        NavigationStack {
            VStack {
                NavigationLink(destination: Chat()){
                    HospitalCard()
                }
            }
        }
    }
}


struct HospitalCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .frame(height: 250)
            .shadow(radius: 10,
                    x: 5, y:5)
            .overlay(
                VStack(spacing: 1){
                    HStack{
                        Text("진료내역")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .bold()
                            .padding([.top, .leading])
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    HStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white)
                            .frame(width:100, height: 100)
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                            .padding()
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 50)
                                    .padding()
                            )
                        VStack(alignment: .leading) {
                            Text("XX병원")
                                .font(.title)
                                .bold()
                                .foregroundColor(.black)
                            Text("Best hospital")
                                .bold()
                                .foregroundColor(.gray)
                            Text("Best hospital")
                                .bold()
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom)
                        
                        Spacer()
                    }
                    HStack {
                        
                    }
                }
            )
            .padding()
    }
}

struct CardView: View {
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 5)
                    VStack {
                        HStack {
                            Image("SNUH") // Replace "SNUH" with your actual image name
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(25)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.padding()

                        HStack {
                            Text("XX 병원")
                                .fontWeight(.bold)
                            Text("중상: 도두리기")
                            Text("병명: 아테스페 발병")
                        }
                        HStack {
                            Button("파파라") {
                                // Action for first button
                            }
                            .buttonStyle(.bordered)
                            Button("방방봅") {
                                // Action for second button
                            }
                            .buttonStyle(.bordered)
                        }
                    }.padding()
                }
                .frame(height: 150)

                NavigationLink(destination: Text("진료내역 화면")) {
                    Text("진료내역 확인")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }.padding()
        }
    }
}


//ZStack{
//    Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea()
//    VStack{
//        Text("Home화면")
//            .onTapGesture {
//                if !logined {
//                    showSignUp = true
//                }
//            }
//            .fullScreenCover(isPresented: $showSignUp){
//                LoginView()
//            }
//    }
//}

#Preview {
    HomeView(logined: false)
}
