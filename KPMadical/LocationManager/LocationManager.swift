import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var address: String?
    @Published var address_Naver: String?
    @Published var latitude: String?
    @Published var longitude: String?
    private let Navergeo = NaverGeocoder()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 위치 서비스 사용 동의 요청
    }

    func requestLocation() {
        locationManager.requestLocation() // 단일 위치 요청
    }

    // CLLocationManagerDelegate 메소드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            print("Call Location")
            self.currentLocation = location.coordinate // 현재 위치 업데이트
            self.lookupAddress(location: location)
            self.longitude = String(location.coordinate.longitude)
            self.latitude = String(location.coordinate.latitude)
        }
        self.Navergeo.callNaverAddress(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude) { address in
            DispatchQueue.main.async {
                self.address_Naver = address
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error)")
    }
    func lookupAddress(location: CLLocation) {
           geocoder.reverseGeocodeLocation(location) { placemarks, error in
               if let error = error {
                   print("Error getting address: \(error)")
                   return
               }
               if let firstPlacemark = placemarks?.first {
                   self.address = firstPlacemark.detailedAddress
               }
           }
       }
}
extension CLPlacemark {
    // 편리한 주소 형식으로 변환
    var detailedAddress: String? {
        var components: [String] = []

        if let subThoroughfare = subThoroughfare {
            components.append(subThoroughfare) // 번지
        }
        if let thoroughfare = thoroughfare {
            components.append(thoroughfare) // 거리
        }
        if let locality = locality {
            components.append(locality) // 도시
        }
        if let subAdministrativeArea = subAdministrativeArea {
            components.append(subAdministrativeArea) // 시나 군
        }
        if let administrativeArea = administrativeArea {
            components.append(administrativeArea) // 주나 도
        }
        if let postalCode = postalCode {
            components.append(postalCode) // 우편번호
        }
        if let country = country {
            components.append(country) // 국가
        }

        return components.joined(separator: ", ")
    }
}
