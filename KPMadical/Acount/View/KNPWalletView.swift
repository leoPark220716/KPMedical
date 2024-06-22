//
//  KNPWalletView.swift
//  KPMadical
//
//  Created by Junsung Park on 4/3/24.
//

import SwiftUI

struct KNPWalletView: View {
    @ObservedObject var userInfo: UserInformation
    @EnvironmentObject var router: GlobalViewRouter
    @State var path = NavigationPath()
    @State var Items: [WalletDataStruct.AccessItem] = []
    @State var pass: String = ""
    @State var WalletAddres = ""
    @State var ContractAddres = ""
    @State var HaveWallet = false
    @State var key = Data()
    @State var account = ""
    @State var passwordd = ""
    @State var contract = ""
    @State var loading = false
    let model = KNPWallet()
    var body: some View {
        NavigationStack(path:$path){
            ScrollView{
                VStack{
                    if loading == false{
                        SpinnerView(Title: "지갑을 불러오고 있습니다.")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else{
                        if HaveWallet{
                            walletAddressView
                            walletAccessList
                        }else{
                            dontHaveWalletView
                            
                        }
                        Spacer()
                    }
                }
                .onAppear{
                    Task{
                        let account = model.GetUserAccountString(token: userInfo.token)
                        let items = await model.walletHttp.getTransactionList(Limit: "10", token: userInfo.token,account: account.account)
                        if items.success{
                            DispatchQueue.main.async {
                                self.Items = items.array
                            }
                        }
                        DispatchQueue.main.async {
                            loading = true
                        }
                    }
                    
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .onAppear {
                DispatchQueue.global(qos: .background).async {
                    print("Appear")
                    let account = model.GetUserAccountString(token: userInfo.token)
                    if !account.status {
                        print("어카운트 실패")
                        DispatchQueue.main.async {
                            HaveWallet = false
                        }
                        return
                    }
                    let addr = model.GetWalletPublicKey(account: account.account)
                    if !addr.success {
                        print("공개키 가져오기 실패")
                        DispatchQueue.main.async {
                            HaveWallet = false
                        }
                        return
                    }
                    Task {
                        let WalletAddr = await model.walletHttp.CheckAndGetContractAddress(token: userInfo.token, uid: getDeviceUUID(), address: addr.addres)
                        if !WalletAddr.success {
                            print("Http요청 실패")
                            DispatchQueue.main.async {
                                HaveWallet = false
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            WalletAddres = WalletAddr.addres
                            ContractAddres = WalletAddr.contract
                            HaveWallet = true
                        }
                        let account = model.GetUserAccountString(token: userInfo.token)
                        if !account.status {
                            print("계정 상태가 유효하지 않음")
                            // 계정 상태가 유효하지 않을 때의 처리
                            return
                        }
                        let password = model.GetPasswordKeystore(account: account.account)
                        if !password.seccess {
                            print("비밀번호 가져오기 실패")
                            return
                        }
                        let privateKeyData = model.getWalletPrivateKey(account: account.account, password: password.password)
                        if !privateKeyData.success {
                            print("개인키 가져오기 실패")
                            return
                        }
                        DispatchQueue.main.async {
                            key = privateKeyData.key!
                            passwordd = password.password
                            self.account = account.account
                            contract = WalletAddr.contract
                            print(WalletAddr.contract)
                        }
                    }
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
    
    var walletAddressView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Address")
                .bold()
                .font(.title3)
            HStack {
                Text(WalletAddres)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.blue)
                    .font(.system(size: 15))
                    .onTapGesture {
                        UIPasteboard.general.string = WalletAddres
                    }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            Text("Storage")
                .bold()
                .font(.title3)
            HStack {
                Text(ContractAddres)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Spacer()
                Image(systemName: "doc.on.doc")
                    .foregroundColor(.blue)
                    .font(.system(size: 15))
                    .onTapGesture {
                        UIPasteboard.general.string = ContractAddres
                    }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding()
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding()
    }
    var walletAccessList: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("KPM 요청 내역")
                .bold()
                .font(.title3)
            if !Items.isEmpty {
                List {
                    ForEach(Items.indices, id: \.self) { index in
                        WalletAccessItem(item: $Items[index])
                            .listRowInsets(EdgeInsets())
                            .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                Spacer()
                HStack {
                    Text("요청내역이 존재하지 않습니다.")
                        .bold()
                        .foregroundColor(.gray)
                    Spacer()
                }
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .frame(height: 300)
        .padding()
    }
}

struct WalletAccessItem: View {
    @Binding var item: WalletDataStruct.AccessItem
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Text(item.Date)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 7)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.HospitalName)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(item.Purpose)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text(item.blockHash)
                    .lineLimit(1)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            Spacer()
            VStack{
                Spacer()
                if item.State {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    Image(systemName: "arrow.left.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                Text(item.State ? "응답" : "요청")
                    .font(.system(size: 13))
                    .foregroundColor(item.State ? .green : .red)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(item.State ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    .cornerRadius(5)
                Spacer()
            }
        }
        .padding()
        .cornerRadius(10)
    }
}

struct KNPWalletViewPreviews: PreviewProvider {
    @State static var items = WalletDataStruct.AccessItem(HospitalName: "서울종합병원", Purpose: "진료기록 저장을 요청하셨습니다.", State: true, Date: "5.5",blockHash: "0x70df01a844d91b0c513856c3c3b08523c3b0fab556d56612690dd12021ca5839",unixTime: 123213)

    static var previews: some View {
        WalletAccessItem(item: $items)
    }
}


//HStack{
//    Button("Send") {
//        Task{
//            let callConfirmSaveRecord = await model.sendTxForConfirm(account: account, key: key)
//            if callConfirmSaveRecord{
//                print("호출 성공?")
//            }
//        }
//    }
//    Button("Contract") {
//        Task{
//            print("Contract 호출")
//            let contractModel = await model.SmartContractDeploy(account: account, password: passwordd, contractPara: "MIGJAoGBANCN+GTloeeqB4MHJWadrd9bJJ0kT892rX+M7oDeVCoartKWBjVJFIMSs6hD+lRYuHPeAXxtDEcuRVy2fiZQL6ghLL6i1XDYAM8JzevhVYpeXlnd9tV06zupV632Vu5kbPXoIlqMRgQYUMaJB14FW+HPsr4pEg5/G2hDF9diTu7fAgMBAAE=")
//            if contractModel.success{
//                print("성공")
//            }else{
//                print("실패")
//            }
//        }
//    }
//    Button("Recode") {
//        Task{
//            let callConfirmSaveRecord = await model.recodeRead(account: account, key: key, contractAddress: contract, start: 9999, limit: 100)
////                                    if callConfirmSaveRecord{
////                                        print("호출 성공?")
////                                    }
//        }
//    }
//    Button("RecoverSymetricKey") {
//        let StringRSAKeys = model.getStringRSAPrivateKey(account: account)
//        print("공개키")
//        print(StringRSAKeys.publickey)
//        print("여기까지")
//            if let privateKey = model.getPrivateKeyFromKeyChain(account: account) {
//                let stringkey = model.convertSecKeyToPEM(privateKey: privateKey)
//                model.prkeyDecoding2(privateKeyString: stringkey!)
//            } else {
//                print("Failed to retrieve private key")
//            }
//        
//    }
//    Button("encrype Data") {
//        print(decryptAES256() ?? "")
//    }
//}
