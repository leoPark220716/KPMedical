//
//  KNPWalletView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import SwiftUI

struct KNPWalletView: View {
    @ObservedObject var userInfo: UserObservaleObject
    @EnvironmentObject var router: GlobalViewRouter
    @State var path = NavigationPath()
    @State var Items: [WalletDataStruct.AccessItem] = []
    @State var pass: String = ""
    @State var WalletAddres = ""
    @State var ContractAddres = ""
    @State var HaveWallet = false
    let model = KNPWallet()
    var body: some View {
        NavigationStack(path:$path){
            ScrollView{
                VStack{
                    if HaveWallet{
                        walletAddressView
                        walletAccessList
                    }else{
                        dontHaveWalletView
                    }
                    Spacer()
                }
                .onAppear{
                    var tempItems: [WalletDataStruct.AccessItem] = []
                    for _ in 1...10 {
                        let item = WalletDataStruct.AccessItem(HospitalName: "진해병원", Purpose: "진료데이터", State: "완료", Date: "3.20")
                        tempItems.append(item)
                    }
                    self.Items = tempItems
                }
            }
            .navigationTitle("KPM Wallet")
            .toolbar{
                ToolbarItem(placement: .navigation){
                    Button(action:{
                        router.currentView = .tab
                    }){
                        Image(systemName: "chevron.left")
                    }
                }
            }
            .navigationDestination(for: Int.self){ value in
                switch value {
                case 1:
                    WalletPassword(path: $path, Checkpassword: $pass, userInfo: userInfo)
                case 2:
                    mnemonicView(path: $path, password: $pass,userInfo: userInfo)
                case 3:
                    recoverWalletView(userInfo: userInfo, path: $path)
                default: EmptyView()
                }
            }
        }
        .onAppear{
            print("Apper")
            let account = model.GetUserAccountString(token: userInfo.token)
            if !account.status{
                print("어카운트 실패")
                HaveWallet = false
                return
            }
            let addr = model.GetWalletPublicKey(account: account.account)
            if !addr.success{
                print("공개키 가져오기 실패")
                HaveWallet = false
                return
            }
            Task{
                let WalletAddr = await model.walletHttp.CheckAndGetContractAddress(token: userInfo.token, uid: getDeviceUUID(), address: addr.addres)
                if !WalletAddr.success{
                    print("Http요청 실패")
                    HaveWallet = false
                    return
                }
                WalletAddres = WalletAddr.addres
                ContractAddres = WalletAddr.contract
                HaveWallet = true
            }
            
            
        }
    }
    var dontHaveWalletView: some View{
        VStack{
            HStack{
                Text("지갑이 존재하지 않습니다.")
                    .bold()
                    .font(.title3)
                Spacer()
            }
            Text("지갑을 생성해 주세요")
                .foregroundStyle(Color.gray)
                .bold()
                .padding()
                .padding(.top)
            HStack{
                Text("지갑생성")
                    .bold()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(Color("ConceptColor"))
                    .cornerRadius(10)
                    .padding(.top)
                    .onTapGesture {
                        path.append(1)
                    }
                Text("지갑찾기")
                    .bold()
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.blue)
                    .background(Color.white)
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .padding(.top)
                    .onTapGesture {
                        path.append(3)
                    }
            }
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray)
        )
        .padding()
    }
    
    var walletAddressView: some View{
        VStack(alignment: .leading){
            Text("Address")
                .bold()
                .font(.title3)
            HStack{
                Text(WalletAddres)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 15))
            }
            .padding()
            .padding(.vertical,3)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.init(white: 0, alpha: 0.2)))
                .cornerRadius(10)
            Text("Storage")
                .bold()
                .font(.title3)
            HStack{
                Text(ContractAddres)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .foregroundStyle(Color.blue)
                    .font(.system(size: 15))
            }
            .padding()
            .padding(.vertical,3)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray)
        )
        .padding()
    }
    var walletAccessList: some View{
        VStack(alignment: .leading){
            Text("KPM 요청 내역")
                .bold()
                .font(.title3)
            if !Items.isEmpty{
                List(Items.indices, id: \.self) { index in
                    WalletAccessItem(item: $Items[index])
                }
                .listStyle(InsetListStyle())
            }
            else{
                Spacer()
                HStack{
                    Text("요청내역이 존재하지 않습니다.")
                        .bold()
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(height: 300)
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray)
        )
        .padding()
    }
}

struct WalletAccessItem: View {
    @Binding var item: WalletDataStruct.AccessItem
    var body: some View {
        HStack {
            // 첫 번째 VStack에서 "3.30" 텍스트를 상단 정렬합니다.
            VStack {
                Text(item.Date)
                    .padding(.top,7)
                Spacer() // 남은 공간을 채워서 "3.30"을 상단에 위치시킵니다.
            }
            // 두 번째 VStack에서 진료 데이터 요청과 거절 텍스트를 세로로 정렬합니다.
            VStack(alignment: .leading) {
                Text("\(item.HospitalName)에서 \(item.Purpose) 요청")
                    .bold()
                Text("\(item.State)")
                    .padding(.top, 4) // "거절" 텍스트와 상단 텍스트 사이의 간격을 추가합니다.
            }
        }
    }
}

struct KNPWalletViewPreviews: PreviewProvider {
    // 프리뷰를 위한 더미 ObservableObject
    static var dummyUserInfo = UserObservaleObject()

    // 프리뷰를 위한 더미 바인딩
    @State static var dummyPath = NavigationPath()
    @State static var dummyPassword = "asdfasdf12@@"

    static var previews: some View {
        KNPWalletView(userInfo: dummyUserInfo)
    }
}
