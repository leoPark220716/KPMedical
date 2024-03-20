//
//  TestNVSTack.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import SwiftUI

struct TestNVSTack: View {
    var body: some View {
        NavigationStack{
            NavigationLink(destination: t()){
                SearchHpView()
            }
        }
    }
}

#Preview {
    TestNVSTack()
}
struct lab: View {
    var body: some View {
        Text("Hello, World!")
    }
}
func getBotton(){
    
}
