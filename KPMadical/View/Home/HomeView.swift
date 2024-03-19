//
//  SwiftUIView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/11/24.
//
import SwiftUI

struct HomeView: View {
    @ObservedObject var authViewModel: UserObservaleObject
    var logined: Bool
    @Environment(\.dismiss) var dismiss
    @State private var showSignUp = false
    @State private var goLogin = false
    var body: some View {
        NavigationView() {
            VStack {
                HStack{
                    Text("팀노바님")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .bold()
                        .padding(.leading)
                    Text("안녕하세요!")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .bold()
                    Spacer()
                }
                .padding([.top, .leading])
                NavigationLink(destination: Chat()){
                    TreatmentCardView(CurrentHospital: "xx병원", CurrentCheckUp: "xx", Currentdisease: "xx", CurrentDoc: "의사명", Currentmedical: "진료과",ImageURL: "https://picsum.photos/200/300")
                }
//                NavigationLink(destination: Chat()){
                ShowingHospitalView(ImageURL: "https://picsum.photos/200/300").onTapGesture {
                    authViewModel.isLoggedIn = false
                }
//                }
                Spacer()
            }
            .onAppear(){
                NotificationCenter.default.post(name: .CloseLoginChanel, object: nil)
            }
        }
    }
}


struct TreatmentCardView: View {
    @State var CurrentHospital: String = ""
    @State var CurrentCheckUp: String = ""
    @State var Currentdisease: String = ""
    @State var CurrentDoc: String = ""
    @State var Currentmedical: String = ""
    @State var ImageURL: String = ""
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(height: 240)
            .shadow(radius: 10,
                    x: 5, y:5)
            .overlay(
                VStack(spacing: 0){
                    HStack{
                        Text("진료내역")
                            .font(.system(size: 26))
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .bold()
                            .padding(.leading)
                        Spacer()
//                        일자 넣을시 여기에 일자 Text 추가하면될듯
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    HStack {
                        AsyncImage(url: URL(string: ImageURL)){ image in
                            image.resizable()
                            image.aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 90, height: 90)
                            .cornerRadius(25)
                            .padding()
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                        VStack(alignment: .leading) {
                            Text(CurrentHospital)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.black)
                            Text("증상 : \(CurrentCheckUp)")
                                .bold()
                                .foregroundColor(.gray)
                            Text("병명 : \(Currentdisease)")
                                .bold()
                                .foregroundColor(.gray)
                            HStack {
                                Text("\(Currentmedical)")
                                    .font(.system(size: 15))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(Color("ConceptColor"))
                                    .cornerRadius(20)
                                Text("👨🏻‍⚕️ \(CurrentDoc)")
                                    .font(.system(size: 15))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 5)
                                    .background(Color("ConceptColor"))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.bottom)
                        Spacer()
                    }
                    HStack() {
                        Spacer()
                        Text("진료내역 확인")
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .background(Color("ConceptColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            )
            .padding()
    }
}
struct ShowingHospitalView: View {
    @State var ImageURL: String = ""
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(height: 240)
            .shadow(radius: 10,
                    x: 5, y:5)
            .overlay(
                VStack(spacing: 0){
                    HStack{
                        Text("등록된 병원을 구경해보세요")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .bold()
                            .padding(.leading)
                        Spacer()
//                        일자 넣을시 여기에 일자 Text 추가하면될듯
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    HStack {
                        AsyncImage(url: URL(string: ImageURL)){ image in
                            image.resizable()
                            image.aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 90, height: 90)
                            .cornerRadius(25)
                            .padding()
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                        AsyncImage(url: URL(string: ImageURL)){ image in
                            image.resizable()
                            image.aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 90, height: 90)
                            .cornerRadius(25)
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                        AsyncImage(url: URL(string: ImageURL)){ image in
                            image.resizable()
                            image.aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                            .frame(width: 90, height: 90)
                            .cornerRadius(25)
                            .padding()
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                    }
                    HStack() {
                        Spacer()
                        Text("진료내역 확인")
                            .foregroundColor(.white)
                            .padding(.vertical, 15)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .background(Color("ConceptColor"))
                    .cornerRadius(10)
                    .padding(.horizontal)
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

//#Preview {
//    HomeView(logined: false)
//}
