//
//  GallerriTest.swift
//  KPMadical
//
//  Created by Junsung Park on 4/13/24.
//

import SwiftUI

struct GallerriTest: View {
    @State private var openPhoto = false
    @State private var image = UIImage()
    @State private var newImage = UIImage()
    @State private var ImageData = Data()
    var body: some View {
        NavigationView {
            
            VStack {
                VStack{
                    Image(uiImage: self.image)
                        .resizable()
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .background(Color.gray)
                VStack{
                    Image(uiImage: self.newImage)
                        .resizable()
                        .frame(minWidth: 0, maxWidth: .infinity)
                }
                .background(Color.red)
                HStack{
                    Button("바이트 변환", action:{
                        let iamgeData = image.imageData()
                        ImageData = iamgeData.data!
                        print(ImageData)
                    })
                    Button("이미지로 변환", action:{
                        guard let img = UIImage(data: ImageData) else{
                            print("실패")
                            return
                        }
                        DispatchQueue.main.async {
                            newImage = img
                        }
                    })
                }
            
            }
            .navigationBarTitle("홈", displayMode: .inline)
            .navigationBarItems(trailing:
                                    Button(action: {
                self.openPhoto = true
            }) {
                Text("사진 추가")
            }
            )
        }                             .sheet(isPresented: $openPhoto) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
        }
    }
}

#Preview {
    GallerriTest()
}
extension UIImage {
    func imageData() -> (data: Data?, format: String) {
        if let pngData = self.pngData() {
            return (pngData, "PNG")
        } else if let jpegData = self.jpegData(compressionQuality: 1.0) {
            return (jpegData, "JPEG")
        }
        return (nil, "Unknown")
    }
}
