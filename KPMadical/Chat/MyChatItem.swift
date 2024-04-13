//
//  MyChaiItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/7/24.
//

import SwiftUI

struct MyChatItem: View {
    @Binding var testArr: TestChatData
    var body: some View {
        HStack(alignment: .bottom,spacing: 3){
            Spacer()
            VStack(alignment: .trailing){
                Text("1")
                    .foregroundStyle(.red)
                    .font(.system(size: 14))
                Text("오후 9:25")
                    .font(.system(size: 13))
            }
            Text(testArr.text)
                .font(.system(size: 17))
                .padding(10)
                .foregroundColor(.black)
                .background(Color.blue.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.trailing)
        .padding(.leading,20)
    }
}

struct MyChatItem_Previews: PreviewProvider {
    static var previews: some View {
        MyChatItem(testArr: .constant(TestChatData(text: "asdfklfklma",My: 1,id: 1)))
    }
}
