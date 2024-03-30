import SwiftUI
import CryptoSwift
import web3swift
import Web3Core


struct cryptoTest: View {
    @State private var mnemonics: String = ""
        @State private var generatedAddress: String = ""
        
        var body: some View {
            VStack(spacing: 20) {
                Text("HD Wallet Example")
                    .font(.headline)
                
                Button("Generate Mnemonics") {
                    self.generateMnemonics()
                }
                
                Text("Mnemonics: \(mnemonics)")
                
                Button("Generate Wallet") {
                    self.generateWallet()
                }
                
                Text("Generated Address: \(generatedAddress)")
            }
            .padding()
        }
        
        func generateMnemonics() {
            do {
                guard let newMnemonics = try BIP39.generateMnemonics(bitsOfEntropy: 128) else {
                    self.mnemonics = "Error generating mnemonics"
                    return
                }
                self.mnemonics = newMnemonics
            } catch {
                self.mnemonics = "Error generating mnemonics"
            }
        }
        
        func generateWallet() {
            guard !mnemonics.isEmpty else {
                self.generatedAddress = "Mnemonics not generated"
                return
            }
            do {
                // 니모닉 구문과 패스워드(옵션)을 이용해 keystore를 생성합니다.
                let password = "strong password" // 이 부분은 사용자로부터 안전하게 수집해야 합니다.
                guard let keystore = try BIP32Keystore(mnemonics: mnemonics, password: password) else {
                    self.generatedAddress = "Failed to create keystore"
                    return
                }
                
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
