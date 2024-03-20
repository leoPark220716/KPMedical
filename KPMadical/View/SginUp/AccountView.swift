//
//  AccountView.swift
//  KPMadical
//
//  Created by Junsung Park on 3/13/24.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var authViewModel: UserObservaleObject
    let UserDb = LocalDataBase.shared
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).onTapGesture {
            authViewModel.SetLoggedIn(logged: false)
            UserDb.removeAllUserDB()
        }
    }
}
