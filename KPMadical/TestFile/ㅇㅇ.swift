//
//  ㅇㅇ.swift
//  KPMadical
//
//  Created by Junsung Park on 4/14/24.
//

import SwiftUI
import PhotosUI


struct __: View {
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImage: UIImage?
    @State private var NewImage: UIImage?
    @State private var ImageData = Data()
    var body: some View {
        NavigationView {
            VStack {
                VStack{
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                    }
                }
                VStack{
                    if let selectedImage = NewImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                    }
                }
                Button("이미지로 변환", action:{
                    guard let img = UIImage(data: ImageData) else{
                        print("실패")
                        return
                    }
                    DispatchQueue.main.async {
                        NewImage = img
                    }
                })
                PhotosPicker(
                    selection: $selectedItems,
                    maxSelectionCount: 1,
                    selectionBehavior: .default,
                    matching: .images,
                    preferredItemEncoding: .automatic
                ) {
                    Label("Select Image", systemImage: "photo")
                }
                .onChange(of: selectedItems) {
                    guard let item = selectedItems.first else { 
                        return
                    }
                    item.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let image = UIImage(data: data) {
                                print(data)
                                DispatchQueue.main.async {
                                    self.selectedImage = image
                                    self.ImageData = data
                                }
                            }
                        case .failure(let error):
                            print("Error loading image: \(error)")
                        }
                    }
                }
            }
            .navigationTitle("Image Picker")
        }
    }
}



#Preview {
    __()
}
