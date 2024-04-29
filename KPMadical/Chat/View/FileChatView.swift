//
//  FileChatView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/28/24.
//

import SwiftUI

struct FileChatView: View {
    var urlString: String
    @StateObject var downloadManager = DownloadManager()
    @EnvironmentObject var router: GlobalViewRouter
    var body: some View {
        HStack(alignment:.center){
            Image(systemName: "folder.fill")
                .foregroundStyle(Color.blue.opacity(0.5))
                .padding(.leading)
            VStack(alignment: .leading,spacing: 3){
                Text("\(downloadManager.name).\(downloadManager.file_extension)")
                    .font(.system(size: 14))
                Text("용량 \(downloadManager.fileSize) KB")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.gray)
            }
            .padding(.leading,0)
            Spacer()
        }
        .frame(width: 200, height: 70)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20) // 모서리 둥근 사각형
                .stroke(Color.blue.opacity(0.5), lineWidth: 2) // 파란색, 두께 2의 태두리
        )
        .onAppear{
            if let encodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: encodedString) {
                let fullFileName = url.lastPathComponent
                if let hashIndex = fullFileName.firstIndex(of: "#") {
                    let fileName = String(fullFileName[..<hashIndex]) // '#' 이전의 문자열을 추출
                    DispatchQueue.main.async {
                        downloadManager.name = fileName
                    }
                }
                let fileExtension = url.pathExtension // 파일 확장자를 추출
                print("File extension: \(fileExtension)") // 출력: pdf
                DispatchQueue.main.async {
                    downloadManager.file_extension = fileExtension
                }
                downloadManager.checkContentLength(urlString: encodedString)
            }
        }
        .onTapGesture {
            downloadManager.startDownload(urlString: urlString)
        }
        .onChange(of: downloadManager.doen){
            print("Call ToastView")
            router.toast = true
        }
    }
}

#Preview {
//    https://download.samplelib.com/mp4/sample-5s.mp4
    
    FileChatView(urlString: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/구조도#1714339510758824476.pdf")
}

//FileChatView(urlString: "https://public-kp-medicals.s3.ap-northeast-2.amazonaws.com/chat_files/구조도#1714339510758824476.pdf")
