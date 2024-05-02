//
//  ViewHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 4/15/24.
//

import Foundation
import UIKit
//    Chat 뷰의 상태 변환
class ChatViewHandler {

    
    
    func ControlBottomView(TabPlus: Bool, chatField: Bool,ChatText: String)-> (TabPlus: Bool, chatField: Bool,ChatText: String){
        var tab = TabPlus
        var editor = chatField
        var text = ChatText
        if TabPlus{
            text = ""
            tab = false
            editor = false
        }else{
            tab = true
            editor = true
        }
        return (tab,editor,text)
    }
    
    
    func PngReturnByData_Img(data: Data,img: UIImage)->(Data){
        let pngData = data.isPNG() ? data : img.pngData() // PNG인 경우 변환 생략
        return pngData ?? data
    }
    func pngReturnByDataToImage(data: Data) -> (succsess: Bool, img:UIImage?) {
        if let image = UIImage(data: data) {
            if data.isPNG() {
                // 이미 PNG 형식인 경우 바로 UIImage 객체를 반환
                return (true,image)
            } else {
                // PNG 형식이 아닌 경우, UIImage를 PNG 데이터로 변환
                guard let pngData = image.pngData(), let newImage = UIImage(data: pngData) else{
                    // 변환된 PNG 데이터로 다시 UIImage 객체 생성
                    return (false, nil)
                }
                return (true, newImage)
            }
        }
        // 이미지 생성 실패한 경우 nil 반환
        return (false, nil)
    }
}
