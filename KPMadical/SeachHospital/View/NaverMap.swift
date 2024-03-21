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
struct NMFMapViewRepresentable: UIViewRepresentable {
    let coord = NMGLatLng(lat: 37.4798, lng: 126.9773)
    let marker = NMFMarker()
    func makeUIView(context: Context) -> NMFMapView {
        marker.position = coord
        return NMFMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        // NMFMapView를 업데이트할 때 필요한 코드를 여기에 작성합니다.
        marker.position = coord
        marker.mapView = uiView
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord)
        uiView.moveCamera(cameraUpdate)
    }
}
