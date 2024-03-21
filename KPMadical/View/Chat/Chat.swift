//
//  Chat.swift
//  KPMadical
//
//  Created by Junsung Park on 3/12/24.
//

import SwiftUI
import CoreLocation

struct Chat: View {
    @State private var isVisible: Bool = false // 뷰의 표시 여부를 결정하는 상태 변수
    @StateObject private var locationService = LocationService()
    @State private var userLocation: CLLocationCoordinate2D?
    
    var body: some View {
          VStack {
              if let currentLocation = locationService.currentLocation {
                  Text("Latitude: \(currentLocation.latitude)")
                  Text("Longitude: \(currentLocation.longitude)")
              } else {
                  Text("Determining your location...")
              }
              if let address = locationService.address{
                  Text("주소 : \(address)")
              }else{
                  Text("주소 찾는중입니다")
              }
              if let Naver_Adress = locationService.address_Naver{
                  Text("네이버 주소 : \(Naver_Adress)")
              }else{
                  Text("주소 찾는중입니다")
              }
          }
          .onAppear {
              locationService.requestLocation()
          }
      }
     
 }


#Preview {
    Chat()
}

    
import SwiftUI
import Combine

extension Notification.Name {
    static let closeParentView = Notification.Name("closeParentView")
}
//


struct ParentView: View {
    @State private var isChildViewPresented = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack{
                Button("자식 뷰 열기") {
                    isChildViewPresented = true
                }
                .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                .navigationDestination(isPresented: $isChildViewPresented) {
                    ChildView(isPresented: $isChildViewPresented)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .closeParentView)) { _ in
            // 이벤트 감지 시 부모 뷰를 닫음
            dismiss()
        }
    }
}



struct ChildView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Text("??")
            Button("닫기") {
                // 자식 뷰를 닫음
                isPresented = false
                // NotificationCenter를 통해 이벤트 방송
                NotificationCenter.default.post(name: .closeParentView, object: nil)
            }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }
}
