//
//  ViewHandler.swift
//  KPMadical
//
//  Created by Junsung Park on 4/15/24.
//

import Foundation
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
}
