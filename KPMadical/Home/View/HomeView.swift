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
    let HomeViewHttp = HomviewHttp()
    @Environment(\.dismiss) var dismiss
    @State private var showSignUp = false
    @State private var goLogin = false
    @State private var url1 = "https://example.com/default-image.png"
    @State private var url2 = "https://example.com/default-image.png"
    @State private var url3 = "https://example.com/default-image.png"
    let userDb = LocalDataBase.shared
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        ScrollView {
            VStack {
                //                NavigationLink(destination: Chat()) {
                //                        일시적으로 여기에다 잠시 나중에 최근 진료기록 확인할 수 있으면 TreatmentCardView 주석 해제
                //                TreatmentCardView(CurrentHospital: "xx병원", CurrentCheckUp: "xx", Currentdisease: "xx", CurrentDoc: "의사명", Currentmedical: "진료과", ImageURL: "https://picsum.photos/200/300")
                ShowingHospitalView(ImageURL1: $url1,ImageURL2: $url2,ImageURL3: $url3)
                //                }
                //                NavigationLink(destination: FindHospitalView()){
                SearchHpView()
                    .onTapGesture {
                        router.currentView = .findHospital
                    }
                //                }
                Spacer()
                HStack{
                    calendarView()
                    PillView()
                }
                .padding(.top)
            }
            .onAppear{
                HomeViewHttp.requestHomViewItems(token: authViewModel.token) { url1, url2, url3 in
                    self.url1 = url1
                    self.url2 = url2
                    self.url3 = url3
                }
            }
        }.background(Color(.init(white: 0, alpha: 0.05))
            .ignoresSafeArea())
        
    }
}
// 성훈 코딩 끝나면 상황에 따라 추가할 부분
//NavigationLink(destination: Chat()){
//    ShowingHospitalView(ImageURL: "https://picsum.photos/200/300").onTapGesture {
//        userDb.removeAllUserDB()
//        authViewModel.SetLoggedIn(logged: false)
//    }
//}
struct calendarView: View{
    var body: some View{
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(width: 150,height: 110)
            .shadow(radius: 40,
                    x: 10, y:10)
            .overlay(
                ZStack{
                    Image("Pill") // 여기서 "backgroundImage"는 교체해야 할 배경 이미지의 이름입니다.
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 170,height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    // 이미지가 화면 전체를 채우도록 설정
                    VStack(spacing: 0){
                        HStack{
                            Text("처방내역")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .bold()
                                .padding([.leading,.top])
                            Spacer()
                        }
                        Spacer()
                    }
                }
            )
            .padding(.horizontal)
    }
}
struct PillView: View{
    var body: some View{
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(width: 150,height: 110)
            .shadow(radius: 40,
                    x: 10, y:10)
            .overlay(
                ZStack{
                    Image("date_") // 여기서 "backgroundImage"는 교체해야 할 배경 이미지의 이름입니다.
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 170,height: 170)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    // 이미지가 화면 전체를 채우도록 설정
                    VStack(spacing: 0){
                        HStack{
                            Text("예약현황")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .bold()
                                .padding([.leading,.top])
                            Spacer()
                        }
                        Spacer()
                    }
                }
            )
            .padding(.horizontal)
    }
}
struct SearchHpView: View {
    var body: some View {RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(height: 200)
            .shadow(radius: 10,
                    x: 5, y:5)
            .overlay(
                ZStack{
                    Image("SelectHP") // 여기서 "backgroundImage"는 교체해야 할 배경 이미지의 이름입니다.
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    // 이미지가 화면 전체를 채우도록 설정
                    VStack(spacing: 0){
                        HStack{
                            Text("손쉽게 원하는 병원을")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                                .bold()
                                .padding([.leading, .top])
                            Spacer()
                        }
                        HStack{
                            Text("병원찾기")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .bold()
                                .padding(.leading)
                            Spacer()
                        }
                        Spacer()
                        HStack() {
                            Spacer()
                            Text("진료내역 확인")
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .font(.system(size: 20, weight: .semibold))
                            Spacer()
                        }
                        .background(Color("ConceptColor"))
                        .cornerRadius(10)
                        .padding([.bottom, .horizontal])
                    }
                }
            )
            .padding([.bottom,.horizontal])
        
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
            .frame(height: 230)
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
                            image.resizable() // 이미지를 resizable로 만듭니다.
                                 .aspectRatio(contentMode: .fit) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
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
                            .padding(.vertical, 12)
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
    @Binding var ImageURL1: String
    @Binding var ImageURL2: String
    @Binding var ImageURL3: String
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
                        AsyncImage(url: URL(string: ImageURL1)){ image in
                            image.resizable() // 이미지를 resizable로 만듭니다.
                                 .aspectRatio(contentMode: .fit) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
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
                        AsyncImage(url: URL(string: ImageURL2)){ image in
                            image.resizable() // 이미지를 resizable로 만듭니다.
                                 .aspectRatio(contentMode: .fit) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 90, height: 90)
                        .cornerRadius(25)
                        .shadow(
                            radius: 10,
                            x: 5, y:5
                        )
                        AsyncImage(url: URL(string: ImageURL3)){ image in
                            image.resizable() // 이미지를 resizable로 만듭니다.
                                 .aspectRatio(contentMode: .fit) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
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
