//
//  test__.swift
//  KPMadical
//
//  Created by Junsung Park on 4/30/24.
//

import SwiftUI
import Foundation


struct test__: View {
    @State var name = "박준성"
    @State var nt = false
    @State var path = NavigationPath()
    var body: some View {
        
                Text("dd")
                .onTapGesture {
                    
                }
                .navigationDestination(for: Route.self){ route in
                    switch route {
                    case .item(_):
                        EmptyView()
                    case .chat(data: let data):
                        Chat(data: data)
                    }
                }
        }
    
}






struct test_1: View {
    @Binding var name: String
    @Binding var path: NavigationPath
    var body: some View {
        HStack{
            Text(name)
                .onTapGesture {
                    name = "한인친"
                }
                .padding(.leading, 10)
            Spacer()

        }
    }
}



#Preview {
    test__()
}

