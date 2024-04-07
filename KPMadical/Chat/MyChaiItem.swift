//
//  MyChaiItem.swift
//  KPMadical
//
//  Created by Junsung Park on 4/7/24.
//

import SwiftUI

struct MyChaiItem: View {
    var body: some View {
        HStack(alignment: .bottom){
            Spacer()
            VStack(alignment: .trailing){
                Text("1")
                    .foregroundStyle(.red)
                    .font(.system(size: 16))
                Text("오후 9:25")
                    .font(.system(size: 14))
            }
            Text("asdfklasdmfklmaskdlfaafafafadsfklasdmflkasmdflkmasdlkfmalks;dm;lkasdm;lkasdmf;ladmsl;kamsdfmasdmflamsdflkamsdfklma")
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

#Preview {
    MyChaiItem()
}
