//
//  ㅇㅇ.swift
//  KPMadical
//
//  Created by Junsung Park on 4/14/24.
//

import SwiftUI
import PhotosUI

struct __: View {
    @State private var url1 = "https://picsum.photos/200/300"
    let imageUrls: [URL] = [
        
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713195478184121348.png")!,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430092586110.png")!
        ,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430253084965.png")!
        ,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430253084965.png")!
        ,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430390391651.png")!,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430528381850.png")!,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430528381850.png")!,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430528381850.png")!,
        URL(string: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/1713193430528381850.png")!
    ]
    var body: some View {
        HStack(alignment: .bottom,spacing: 3){
            Spacer()
            VStack(alignment: .trailing){
                Text("1")
                    .foregroundStyle(.red)
                    .font(.system(size: 12))
                
                Text("09:00")
                    .font(.system(size: 12))
            }
            DynamicImageViewManual3(images: imageUrls,totalWidth: 270, imageHeight: 90, oneItem: 270)
                .cornerRadius(20)
        }
        .padding(.trailing)
        .padding(.leading,20)
    }
}

struct DynamicImageView8: View {
    var images: [URL]
    
    private let totalWidth: CGFloat = 270 // 전체 그리드의 너비 설정
    private let numberOfColumns = 3 // 열의 최대 개수
    
    var body: some View {
        VStack {
            if images.count == 1 {
                AsyncImage(url: images.first) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: totalWidth, height: 90)
            } else {
                let numberOfRows = (images.count + numberOfColumns - 1) / numberOfColumns
                let remainingItems = images.count % numberOfColumns
                let columnWidth = totalWidth / CGFloat(numberOfColumns)
                let isLastRowPartial = remainingItems != 0 && numberOfRows > 1
                
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: 5), count: numberOfColumns)) {
                    ForEach(images.indices, id: \.self) { index in
                        AsyncImage(url: images[index]) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(
                            width: isLastRowPartial && index >= images.count - remainingItems ?
                            (remainingItems == 1 ? totalWidth : // 1개 일 경우 전체 너비
                             remainingItems == 2 ? totalWidth / 2 : // 2개 일 경우 반으로 나눔
                             columnWidth) : // 3개 있는 경우 각각 원래 열 너비
                            columnWidth,
                            height: 90
                        )
                        .clipped()
                    }
                }
            }
        }
    }
}

struct DynamicImageViewManual: View {
    var images: [URL]
    private let totalWidth: CGFloat = 270 // 전체 그리드의 너비 설정
    private let imageHeight: CGFloat = 90
    
    var body: some View {
        VStack {
            let numberOfColumns = 3
            let numberOfRows = (images.count + numberOfColumns - 1) / numberOfColumns
            let remainingItems = images.count % numberOfColumns
            let imageWidth = totalWidth / CGFloat(numberOfColumns)
            
            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                HStack(spacing: 3) {
                    ForEach(0..<numberOfColumns) { columnIndex in
                        let index = rowIndex * numberOfColumns + columnIndex
                        if index < images.count {
                            AsyncImage(url: images[index]) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: rowIndex == numberOfRows - 1 && rowIndex * numberOfColumns + columnIndex >= images.count - remainingItems ? totalWidth / CGFloat(remainingItems) : imageWidth, height: imageHeight)
                            .clipped()
                        }
                    }
                }
            }
        }
    }
}
import SwiftUI

struct DynamicImageViewManual2: View {
    var images: [URL]
    private let totalWidth: CGFloat = 270 // 전체 그리드의 너비 설정
    private let imageHeight: CGFloat = 90
    
    var body: some View {
        VStack(spacing: 3) {
            let rowCount = calculateRowCount(images.count)
            let rowItemCounts = calculateRowItemCounts(images.count)
            
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                HStack(spacing: 3) {
                    let startIndex = rowItemCounts[0..<rowIndex].reduce(0, +)
                    let count = rowItemCounts[rowIndex]
                    
                    ForEach(0..<count) { columnIndex in
                        let index = startIndex + columnIndex
                        if index < images.count {
                            AsyncImage(url: images[index]) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: totalWidth / CGFloat(count), height: imageHeight)
                            .clipped()
                        }
                    }
                }
            }
        }
    }
    
    private func calculateRowCount(_ itemCount: Int) -> Int {
        switch itemCount {
        case 1...3:
            return 1
        case 4, 6:
            return 2
        case 5, 7...:
            return (itemCount + 2) / 3
        default:
            return 0
        }
    }
    
    private func calculateRowItemCounts(_ itemCount: Int) -> [Int] {
        switch itemCount {
        case 1...3:
            return [itemCount]
        case 4:
            return [2, 2]
        case 5:
            return [3, 2]
        case 6:
            return [3, 3]
        case 7:
            return [3, 2, 2]
        default:
            var counts = Array(repeating: 3, count: itemCount / 3)
            if itemCount % 3 != 0 {
                counts.append(itemCount % 3)
            }
            return counts
        }
    }
}
import SwiftUI
//let totalWidth: CGFloat = 270 // 전체 그리드의 너비 설정
//let imageHeight: CGFloat = 90

struct DynamicImageViewManual3: View {
    var images: [URL]
    let totalWidth: CGFloat // 전체 그리드의 너비 설정
    let imageHeight: CGFloat
    let oneItem: CGFloat
    var body: some View {
        VStack(spacing: 3) {
            if images.count == 1 {
                // 이미지가 하나인 경우 200x200 크기로 표시
                AsyncImage(url: images.first!) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: oneItem, height: oneItem)
                .clipped()
            }else{
                ForEach(imageRows(images), id: \.self) { rowImages in
                    HStack(spacing: 3) {
                        ForEach(rowImages, id: \.self) { url in
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: totalWidth / CGFloat(rowImages.count), height: imageHeight)
                            .clipped()
                        }
                    }
                }
            }
        }
    }
    // 이미지를 행별로 그룹화
    private func imageRows(_ images: [URL]) -> [[URL]] {
        let rowItemCounts = calculateRowItemCounts(images.count)
        var rows: [[URL]] = []
        var startIndex = 0
        
        for count in rowItemCounts {
            let endIndex = startIndex + count
            if endIndex <= images.count {
                rows.append(Array(images[startIndex..<endIndex]))
            }
            startIndex = endIndex
        }
        return rows
    }
    
    // 각 행에 몇 개의 이미지가 배치될지 계산
    private func calculateRowItemCounts(_ itemCount: Int) -> [Int] {
        switch itemCount {
        case 2...3:
            return [itemCount]
        case 4:
            return [2, 2]
        case 5:
            return [3, 2]
        case 6:
            return [3, 3]
        case 7:
            return [3, 2, 2]
        default:
            var counts = Array(repeating: 3, count: itemCount / 3)
            if itemCount % 3 != 0 {
                counts.append(itemCount % 3)
            }
            return counts
        }
    }
}



#Preview {
    __()
}
