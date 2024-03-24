//
//  NaverMap.swift
//  KPMadical
//
//  Created by Junsung Park on 3/21/24.
//

import SwiftUI
import NMapsMap

//struct MapView: View {
//    var body: some View {
//        NMFMapViewRepresentable()
//            .frame(width: 300, height: 400)
//            .cornerRadius(20)
//    }
//}
//#Preview {
//    MapView()
//}
// UIViewRepresentable 프로토콜임, 앱의 커스텀 인스턴스 중 하나를 채택하고 매소드를 사용해 뷰 생성, 업데이트 해제등이 가능함. 생성 및 업데이트 과정은 SwiftUi 뷰의 동작과정과 같이가고. 이것을 사용해서 뷰를 앱의 현재 상태정보와 함깨 같이 설정할 수 있음 (Context 를 말하는듯)
// 뷰가 사라지는것을 다른 객체에 알리기 위해 해제 과정을 사용할 수도 있음.
// ios 와 같은 시스템은 뷰 내에서 발생하는 변경사항을 자동으로 해당 인터페이스의 다른 부분에과 통신하지 않는다. 통신하고 싶다면 코디네이터 인스턴스를 사용해 두 인터페이스 사이의 상호작용을 관리하고 조정해야한다.

struct NMFMapViewRepresentable: UIViewRepresentable {
    @Binding var coord: NMGLatLng
    let marker = NMFMarker()
    func makeUIView(context: Context) -> NMFMapView {
        let mapView = NMFMapView(frame: .zero)
        print("makeUiView")
        marker.position = coord
        return mapView
    }
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        print("updateUiView")
        marker.position = coord
        marker.mapView = uiView
        DispatchQueue.main.async{
            let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
            uiView.moveCamera(cameraUpdate)
        }
    }
}
