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
        Text("임시 로그아웃").onTapGesture {
            authViewModel.SetLoggedIn(logged: false)
            UserDb.removeAllUserDB()
        }
    }
}
