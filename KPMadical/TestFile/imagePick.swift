//
//  imagePick.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import Foundation
import SwiftUI

// SwiftUI에서 UIViewController를 사용할 수 있도록 UIViewControllerRepresentable 프로토콜을 채택하는 구조체 정의
struct ImagePicker: UIViewControllerRepresentable {

    // 이미지 선택기의 소스 타입을 설정합니다. 기본값은 포토 라이브러리입니다.
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    // 선택된 이미지를 저장할 바인딩 변수
    @Binding var selectedImage: UIImage
    // SwiftUI의 환경을 통해 뷰를 닫을 수 있는 기능을 제공하는 환경 변수
    @Environment(\.dismiss) private var dismiss

    // UIViewControllerRepresentable 프로토콜을 구현하여 UIViewController를 생성하는 메서드
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        // UIImagePickerController 인스턴스를 생성합니다.
        let imagePicker = UIImagePickerController()
        // 이미지 편집을 허용하지 않도록 설정합니다.
        imagePicker.allowsEditing = false
        // 이미지 선택기의 소스 타입을 설정합니다.
        imagePicker.sourceType = sourceType
        // 컨텍스트의 코디네이터를 이미지 픽커의 델리게이트로 설정합니다.
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    // UIViewControllerRepresentable 프로토콜을 구현하여 UIViewController를 업데이트하는 메서드(여기서는 비워둠)
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    // 코디네이터 객체를 생성하는 메서드. 코디네이터는 UIImagePicker의 델리게이트 역할을 함
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // UIImagePickerController의 델리게이트를 구현하기 위한 내부 코디네이터 클래스
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        // ImagePicker 구조체의 인스턴스를 참조하기 위한 변수
        var parent: ImagePicker
        
        // 초기화 메서드에서 ImagePicker 인스턴스를 받아 저장합니다.
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // 이미지 선택이 완료되었을 때 호출되는 메서드
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            // 선택된 이미지를 추출하고, 해당 이미지를 parent의 selectedImage에 할당합니다.
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            // 이미지 선택 후 뷰를 닫습니다.
            parent.dismiss()
        }
    }
}

