import SwiftUI
import CryptoSwift

import web3swift
import Web3Core
import BigInt

import Security

struct cryptoTest: View {
    @State private var mnemonics: String = ""
    @State private var generatedAddress: String = ""
    let keyChainClass = KeystoreKeyChain()
    var body: some View {
           NavigationView {
               VStack(spacing: 20) {
                   Text("HD Wallet Example").font(.headline)
                   Button("Generate Mnemonics") { self.generateMnemonics() }
                   Text("Mnemonics: \(mnemonics)")
                   Button("Generate Wallet") { self.generateWallet() }
                   Text("Generated Address: \(generatedAddress)")
                   NavigationLink(destination:Test2View(address: generatedAddress)){
                       Text("다음")
                           .disabled(generatedAddress.isEmpty)
                   }
                   NavigationLink(destination: WalletRecoveryView()){
                       Text("다음")
                           .disabled(generatedAddress.isEmpty)
                   }
                   
               }.padding()
           }
       }
//    니모닉 생성
    func generateMnemonics() {
        
        do {
            guard let newMnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128, language: .korean) else {
                self.mnemonics = "Error generating mnemonics"
                return
            }
            self.mnemonics = newMnemonics
        } catch {
            self.mnemonics = "Error generating mnemonics"
        }
    }
//     지갑생성
    func generateWallet() {
        guard !mnemonics.isEmpty else {
            self.generatedAddress = "Mnemonics not generated"
            return
        }
        do {
            // 니모닉 구문과 패스워드(옵션)을 이용해 keystore를 생성합니다.
            let password = "strong password" // 이 부분은 사용자로부터 안전하게 수집해야 합니다.
            print(mnemonics)
//            keystore 생성.
            guard let keystore = try BIP32Keystore(mnemonics: mnemonics, password: password) else {
                self.generatedAddress = "Failed to create keystore"
                return
            }
            
//            keystore 직렬화
            guard let keystoreData = try keystore.serialize()else{
                self.generatedAddress = "failed To keystore"
                return
            }
//            직렬화 keystore keychain 에 저장
            let saveStatus = keyChainClass.saveToKeyChain(keystoreData: keystoreData, service: "com.knp.KpMadical", account: "test")
            
            // 새로운 계정을 생성합니다.
            try keystore.createNewChildAccount(password: password)
            
            
            // 첫 번째 주소를 가져옵니다.
            if let address = keystore.addresses?.first {
                print(address.address)
                self.generatedAddress = address.address
            } else {
                self.generatedAddress = "Address not found"
            }
        } catch {
            self.generatedAddress = "Error creating wallet"
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        cryptoTest()
    }
}

struct Test2View: View {
    var address: String = "0x9218555d4324B2fa11416F155a5Ea08BF865345F"
    @State private var balance: String = ""
    
    var body: some View {
        VStack {
            Text("Address: \(address)")
            Button("잔액 조회") {
                Task {
                    await fetchBalance()
                }
            }
            Text("잔액: \(balance)")
        }
    }
    
    func fetchBalance() async {
        guard let providerURL = URL(string: "http://203.234.103.157:3222"),
              let ethereumAddress = EthereumAddress(address) else {
            print("Invalid URL or address")
            return
        }
        
        do {
            let provider = try await Web3HttpProvider(url: providerURL, network: nil, keystoreManager: nil)
            let web3 = Web3(provider: provider)
            
            // `web3.eth.getBalance`을 이용하여 잔액 조회
            let balanceResult = try await web3.eth.getBalance(for: ethereumAddress)
            
            let etherUnit = BigUInt(10).power(18)
            let etherCoast = balanceResult / etherUnit
            
            DispatchQueue.main.async {
                self.balance = String(etherCoast)
            }
            
            print("잔액: \(String(describing: etherCoast)) Ether")
        } catch {
            print("Failed to fetch balance: \(error)")
        }
    }
}
struct WalletRecoveryView: View {
    @State private var mnemonics: String = ""
    @State private var recoveredAddress: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("지갑 복구").font(.headline)
            TextField("니모닉 입력", text: $mnemonics)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            Button("지갑 복구") { self.recoverWallet() }
            Text("복구된 주소: \(recoveredAddress)")
        }.padding()
    }
    
    func recoverWallet() {
        let password = "strong password" // 복구 시 사용할 패스워드, 생성 시와 동일해야 함
        do {
            guard let keystore = try BIP32Keystore(mnemonics: mnemonics, password: password) else {
                self.recoveredAddress = "Failed to recover keystore"
                return
            }
            
            // 복구된 계정의 첫 번째 주소를 가져옵니다.
            if let address = keystore.addresses?.first {
                print(address.address)
                self.recoveredAddress = address.address
            } else {
                self.recoveredAddress = "Address not found"
            }
        } catch {
            self.recoveredAddress = "Error recovering wallet: \(error)"
        }
    }
}

class KeystoreKeyChain {
    
    
    func saveToKeyChain(keystoreData: Data, service: String, account: String) ->OSStatus {
        let query: [String:Any] = [
//            저장하는 아이템 타입 정의
            kSecClass as String: kSecClassGenericPassword,
//            서비스 식별 문자열 정의
            kSecAttrService as String: service,
//            계정 식별 문자열 정의
            kSecAttrAccount as String: account,
//            실제 저장하는 데이터 정의
            kSecValueData as String: keystoreData
        ]
//        동일한 서비스와 계정에 대한 아이템 제거 중복저장 방지.
        SecItemDelete(query as CFDictionary)
//        새로운 Keychain 추가.
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    func loadFromKeychain(service: String, account: String) ->Data?{
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: AnyObject?
//        쿼리에 해당하는 아이템 검색, 검색에 성공하면 item 변수에 저장되고 errSecSuccess 반환.
        let status = SecItemCopyMatching(query as CFDictionary,&item)
        guard status == errSecSuccess else{
            return nil
        }
        return item as? Data
    }
}
// 지갑 생성, -> 지갑 keyChain 저장 -> 지갑 개인키로 rsa 생성 -> rsa 개인키도 저장 -> 공개키로 인찬이가 다 암호화하고 rsa 개인키로 복호화 할 수 있도록 만듬.
