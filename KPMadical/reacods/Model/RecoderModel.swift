//
//  RecoderModel.swift
//  KPMadical
//
//  Created by Junsung Park on 5/29/24.
//

import Foundation
import BigInt

class ReacoderModel: KNPWallet,ObservableObject{
    @Published var ItemArray: [MedicalData] = []
    @Published var DocRecode: [DoctorRecord] = []
    @Published var PhaRecode: [PharmacistRecord] = []
    @Published var combineArray: [MedicalCombineArrays] = []
    func setRecodeData(token: String){
        Task{
            let account = GetUserAccountString(token: token)
            if !account.status {
                print("어카운트 실패")
                return
            }
            let addr = GetWalletPublicKey(account: account.account)
            if !addr.success {
                print("❌공개키 가져오기 실패")
                return
            }
            let WalletAddr = await walletHttp.CheckAndGetContractAddress(token: token, uid: getDeviceUUID(), address: addr.addres)
            if !WalletAddr.success {
                print("❌Http요청 실패")
                return
            }
            let password = GetPasswordKeystore(account: account.account)
            if !password.seccess {
                print("❌비밀번호 가져오기 실패")
                return
            }
            let privateKeyData = getWalletPrivateKey(account: account.account, password: password.password)
            if !privateKeyData.success {
                print("❌개인키 가져오기 실패")
                return
            }
            let callConfirmSaveRecord = await recodeRead(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, param1: 9999, param2: 100, methodName: "getMyRecord")
            if !callConfirmSaveRecord.success {
                print("❌컨트랙트 가져오기 실패")
                return
            }
            let ParseContract = ReturningUnDecodArray(dic: callConfirmSaveRecord.result)
            if !ParseContract.success{
                print("❌pase 실패")
                return
            }
            let setSymetricKey = getSymetricKeys(array: ParseContract.contractResult!, account: account.account)
            if !setSymetricKey.success{
                print("❌개인키 가져오기 실패")
            }
            let decodedData = decodeMedicalDataArray(array: setSymetricKey.contractResult!)
            if !decodedData.success{
                print("❌복호화 실패")
            }
            print("✅✅✅✅✅✅✅✅✅✅복호화 확인✅✅✅✅✅✅✅✅✅✅")
            print(decodedData.contractResult!)
            let combinData = finalMedicalCombineDatas(array: decodedData.contractResult!)
            if combinData.success{
                DispatchQueue.main.async {
                    self.combineArray = combinData.comArray
                }
            }
            let docarray = finalMedicalDocDatas(array: decodedData.contractResult!)
            if docarray.success {
                DispatchQueue.main.async {
                    self.DocRecode = docarray.DocArray
                }
            }
            let phaarray = finalMedicalPhaDatas(array: decodedData.contractResult!)
            if phaarray.success {
                DispatchQueue.main.async {
                    self.PhaRecode = phaarray.PhaArray
                }
            }
            
        }
    }
    func LastRecodeData(token: String) async -> (success: Bool,item:DoctorRecord?){
        
        let account = GetUserAccountString(token: token)
        if !account.status {
            print("어카운트 실패")
            return (false,nil)
        }
        let addr = GetWalletPublicKey(account: account.account)
        if !addr.success {
            print("❌공개키 가져오기 실패")
            return (false,nil)
        }
        let WalletAddr = await walletHttp.CheckAndGetContractAddress(token: token, uid: getDeviceUUID(), address: addr.addres)
        if !WalletAddr.success {
            print("❌Http요청 실패")
            return (false,nil)
        }
        let password = GetPasswordKeystore(account: account.account)
        if !password.seccess {
            print("❌비밀번호 가져오기 실패")
            return (false,nil)
        }
        let privateKeyData = getWalletPrivateKey(account: account.account, password: password.password)
        if !privateKeyData.success {
            print("❌개인키 가져오기 실패")
            return (false,nil)
        }
        let callConfirmSaveRecord = await recodeRead(account: account.account, key: privateKeyData.key!, contractAddress: WalletAddr.contract, param1: 9999, param2: 100, methodName: "getMyRecord")
        if !callConfirmSaveRecord.success {
            print("❌컨트랙트 가져오기 실패")
            return (false,nil)
        }
        let ParseContract = ReturningUnDecodArray(dic: callConfirmSaveRecord.result)
        if !ParseContract.success{
            print("❌pase 실패")
            return (false,nil)
        }
        let setSymetricKey = getSymetricKeys(array: ParseContract.contractResult!, account: account.account)
        if !setSymetricKey.success{
            print("❌개인키 가져오기 실패")
            return (false,nil)
        }
        let decodedData = decodeMedicalDataArray(array: setSymetricKey.contractResult!)
        if !decodedData.success{
            print("❌복호화 실패")
            return (false,nil)
        }
        print("✅✅✅✅✅✅✅✅✅✅복호화 확인✅✅✅✅✅✅✅✅✅✅")
        print(decodedData.contractResult!)
        let combinData = finalMedicalCombineDatas(array: decodedData.contractResult!)
        if !combinData.success{
            return (false,nil)
        }
        let docarray = finalMedicalDocDatas(array: decodedData.contractResult!)
        if !docarray.success {
            return (false,nil)
        }
        return (true,docarray.DocArray.last)
        
    }
    private func sepStrings(inputString: String) -> (er :Bool, DocId: String, DocName:String, hsNmae: String){
        let componets = inputString.components(separatedBy: ",")
        guard componets.count == 3 else{
            return (true,"","","")
        }
        return (false,componets[0],componets[1],componets[2] )
    }
    private func returnDepartName(departCode: Int) -> String{
        if let department = Department(rawValue: departCode) {
            return department.name
        }else{
            return "일반의"
        }
    }
    
    
    
    //    묶음 데이터
    private func finalMedicalCombineDatas(array: [MedicalData]) -> (success: Bool,comArray: [MedicalCombineArrays]){
        var combineDatas: [MedicalCombineArrays] = []
        for item in array{
            let parseData = getDecodeComRecode(PhaJosnString: item.pharmaciRecode,DocJsonString: item.doctorRecode,departCode: Int(item.departmentCode),unix: Int(item.unixTime),hospitalId: Int(item.hospitalId))
            if parseData.success{
                combineDatas.append(parseData.com!)
            }
        }
        print("✅✅✅✅✅✅✅✅✅✅Check CombineDatas✅✅✅✅✅✅✅✅✅✅")
        print(combineDatas)
        if combineDatas.isEmpty{
            return (false,[])
        }
        return (true,combineDatas)
    }
    //    묶음 기록 반환
    private func getDecodeComRecode(PhaJosnString: String,DocJsonString: String,departCode: Int,unix: Int,hospitalId: Int) -> (success: Bool ,com : MedicalCombineArrays?){
        let Pha = PhaJosnString.data(using: .utf8)!
        let Doc = DocJsonString.data(using: .utf8)!
        var ComRecode: MedicalCombineArrays
        var PhaRecodeData: PharmacistRecord
        var DocRecodeData: DoctorRecord
        do{
            let PhaData = try JSONDecoder().decode(PhaRoot.self, from: Pha)
            print("✅ success Pha : \(PhaData.pharmacist_record.type1)")
            PhaRecodeData = PhaData.pharmacist_record
        }catch{
            print("❌pha Err : \(error)")
            return (false, nil)
        }
        do{
            var DocData = try JSONDecoder().decode(DoCRoot.self, from: Doc)
            print("✅ success Doc : \(DocData.doctor_record.doctorID)")
            DocData.doctor_record.departmentCode = departCode
            DocRecodeData = DocData.doctor_record
        }catch{
            print("❌doc Err : \(error)")
            return (false, nil)
        }
        ComRecode = MedicalCombineArrays(doc: DocRecodeData, pha: PhaRecodeData,unixTiem: unix, hospitalId: hospitalId)
        return (true, ComRecode)
    }
    
    //
    private func finalMedicalDocDatas(array: [MedicalData]) -> (success: Bool,DocArray: [DoctorRecord]){
        var DocRecode: [DoctorRecord] = []
        print(array[0].departmentCode)
        for item in array {
            let parseData = getDecodeDocRecode(DocJsonString: item.doctorRecode,depart: Int(item.departmentCode))
            if parseData.success{
                DocRecode.append(parseData.doc!)
                print("✅✅✅✅✅✅✅✅✅✅")
                print(DocRecode[0])
            }
        }
        print(DocRecode.count)
        if DocRecode.count != 0{
            print("Doc is not Empty")
            print(DocRecode)
            return (true,DocRecode)
        }
        return (false,[])
    }
    private func finalMedicalPhaDatas(array: [MedicalData]) -> (success: Bool,PhaArray: [PharmacistRecord]){
        var PhaRecode: [PharmacistRecord] = []
        for item in array{
            let parseData = getDecodePhaRecode(PhaJosnString: item.pharmaciRecode)
            if parseData.success{
                PhaRecode.append(parseData.pha!)
            }
        }
        if !PhaRecode.isEmpty{
            return (true,PhaRecode)
        }
        return (false,[])
    }
    //    처방데이터 기록 반환
    private func getDecodePhaRecode(PhaJosnString: String) -> (success: Bool ,pha : PharmacistRecord?){
        let Pha = PhaJosnString.data(using: .utf8)!
        var PhaRecodeData: PharmacistRecord
        do{
            let PhaData = try JSONDecoder().decode(PhaRoot.self, from: Pha)
            print("✅ success Pha : \(PhaData.pharmacist_record.type1)")
            PhaRecodeData = PhaData.pharmacist_record
        }catch{
            print("❌pha Err : \(error)")
            return (false, nil)
            
        }
        return (true, PhaRecodeData)
    }
    //    의사 기록 반환
    private func getDecodeDocRecode(DocJsonString: String,depart: Int) -> (success: Bool ,doc : DoctorRecord?){
        let Doc = DocJsonString.data(using: .utf8)!
        var DocRecodeData: DoctorRecord
        do{
            var DocData = try JSONDecoder().decode(DoCRoot.self, from: Doc)
            print("✅ success Doc : \(DocData.doctor_record.doctorID)")
            DocData.doctor_record.departmentCode = depart
            DocRecodeData = DocData.doctor_record
        }catch{
            print("❌doc Err : \(error)")
            return (false, nil)
            
        }
        return (true, DocRecodeData)
    }
    //    데이터 복호화
    private func decodeMedicalDataArray(array: [MedicalData]) -> (success: Bool, contractResult: [MedicalData]?){
        var returnItem: [MedicalData] = []
        for item in array{
            let doctorRecode = decodeMedicalData(symatricKey: item.patientKey, encodeData: item.doctorRecode)
            let pharmaciRecode = decodeMedicalData(symatricKey: item.patientKey, encodeData: item.pharmaciRecode)
            if doctorRecode.success && pharmaciRecode.success{
                returnItem.append(MedicalData(index: item.index,
                                              hospitalId: item.hospitalId,
                                              doctorRecode: doctorRecode.result,
                                              pharmaciRecode: pharmaciRecode.result,
                                              patientKey: item.patientKey,
                                              departmentCode: item.departmentCode,
                                              unixTime: item.unixTime))
            }else{
                return (false,nil)
            }
        }
        return (true,returnItem)
    }
    //    초기 데이터 파싱
    private func ReturningUnDecodArray(dic: [String:Any]) -> (success: Bool, contractResult: getRecodeFromSmartContract?){
        do{
            let smartContract = try getRecodeFromSmartContract(from: dic)
            print("✅contract parse success")
            //            print("contract parse value : \(smartContract.items[0].doctorRecode)")
            return (true, smartContract)
        }catch{
            return (false, nil)
        }
    }
    //    대칭키 추출
    private func getSymetricKeys(array: getRecodeFromSmartContract, account: String) -> (success: Bool, contractResult: [MedicalData]?){
        var returnItem: [MedicalData] = []
        guard let privatKey = getPrivateKeyFromKeyChain(account: account) else{
            return (false,nil)
        }
        for item in array.items{
            //            대칭키 복호화 후 새로운 배열 리턴
            let symetricKey = prkeyDecoding(privateKey: privatKey, encodeKey: item.patientKey)
            if symetricKey.success{
                print("✅decode Key success")
                print("decode key value : \(symetricKey.decodeKey)")
                returnItem.append(MedicalData(index: item.index, hospitalId: item.hospitalId, doctorRecode: item.doctorRecode, pharmaciRecode: item.pharmaciRecode, patientKey: symetricKey.decodeKey, departmentCode: item.departmentCode, unixTime: item.unixTime))
                
            }else{
                print("❌시메트릭키 뽑아오기 실패")
                print("Undecode key value : \(item.patientKey)")
            }
        }
        return (true, returnItem)
    }
    
    
    struct MedicalCombineArrays: Codable{
        var doc: DoctorRecord
        var pha : PharmacistRecord
        var unixTiem: Int
        var hospitalId: Int
    }
    struct MedicalData: Codable {
        var index: BigUInt
        var hospitalId: BigUInt
        var doctorRecode: String
        var pharmaciRecode: String
        var patientKey: String
        var hospitalKey: String
        var departmentCode: BigUInt
        var unixTime: BigUInt
        
        init(index: BigUInt, hospitalId: BigUInt, doctorRecode: String, pharmaciRecode: String, patientKey: String, departmentCode: BigUInt, unixTime: BigUInt) {
            self.index = index
            self.hospitalId = hospitalId
            self.doctorRecode = doctorRecode
            self.pharmaciRecode = pharmaciRecode
            self.patientKey = patientKey
            self.hospitalKey = ""
            self.departmentCode = departmentCode
            self.unixTime = unixTime
            
        }
        init(from array: [Any]) throws {
            guard array.count == 8 else {
                throw NSError(domain: "Invalid Array", code: 1, userInfo: [NSLocalizedDescriptionKey: "Array does not contain exactly 8 elements"])
            }
            guard let index = array[0] as? BigUInt else {
                throw NSError(domain: "Invalid id", code: 1, userInfo: [NSLocalizedDescriptionKey: "\(array[0])"])
            }
            guard let hospitalId = array[1] as? BigUInt else {
                throw NSError(domain: "Invalid value", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid value"])
            }
            guard let doctorRecode = array[2] as? String else {
                throw NSError(domain: "Invalid enc", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid encryptedData"])
            }
            guard let pharmaciRecode = array[3] as? String else {
                throw NSError(domain: "Invalid key", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid key"])
            }
            guard let patientKey = array[4] as? String else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid validation"])
            }
            guard let hospitalKey = array[5] as? String else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid emptyField"])
            }
            guard let departmentCode = array[6] as? BigUInt else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid status"])
            }
            guard let unixTime = array[7] as? BigUInt else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid timestamp"])
            }
            
            self.index = index
            self.hospitalId = hospitalId
            self.doctorRecode = doctorRecode
            self.pharmaciRecode = pharmaciRecode
            self.patientKey = patientKey
            self.hospitalKey = hospitalKey
            self.departmentCode = departmentCode
            self.unixTime = unixTime
        }
    }
    
    struct getRecodeFromSmartContract {
        let items: [MedicalData]
        let success: Bool
        
        init(from dictionary: [String: Any]) throws {
            guard let success = dictionary["_success"] as? Bool else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid _success key"])
            }
            guard let data = dictionary["0"] as? [[Any]] else {
                throw NSError(domain: "Invalid data", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing or invalid data array"])
            }
            self.success = success
            self.items = try data.map { array in
                do {
                    return try MedicalData(from: array)
                } catch {
                    print("Failed to parse Item from array: \(array), error: \(error.localizedDescription)")
                    throw error
                }
            }
        }
    }
    struct DoCRoot: Codable {
        var doctor_record: DoctorRecord
    }
    struct DoctorRecord: Codable {
        let doctorID: String
        let staffID: Int
        let userID: String
        let symptoms: Symptoms
        let diseases: [Disease]
        let medicalTests: [MedicalTest]
        let treatments: [Treatment]
        let medicalSupplies: [MedicalSupply]
        let files: [File]
        var departmentCode: Int?
        var imgUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case doctorID = "doctor_id"
            case staffID = "staff_id"
            case userID = "user_id"
            case symptoms
            case diseases
            case medicalTests = "medical_tests"
            case treatments
            case medicalSupplies = "medical_spplies"
            case files
            case departmentCode
            case imgUrl
        }
    }
    
    struct Symptoms: Codable {
        let content: String
        let files: [File]
    }
    
    struct Disease: Codable {
        let diseaseID: Int
        let diseaseCode: String
        let name: String
        let name_eng : String
        
        enum CodingKeys: String, CodingKey {
            case diseaseID = "disease_id"
            case diseaseCode = "disease_code"
            case name
            case name_eng
        }
    }
    
    struct MedicalTest: Codable {
        let testID: Int
        let feeCode: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case testID = "test_id"
            case feeCode = "fee_code"
            case name
        }
    }
    
    struct Treatment: Codable {
        let treatmentID: Int
        let feeCode: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case treatmentID = "treatment_id"
            case feeCode = "fee_code"
            case name
        }
    }
    
    struct MedicalSupply: Codable {
        let supplyID: Int
        let supplyCode: String
        let name: String
        
        enum CodingKeys: String, CodingKey {
            case supplyID = "supply_id"
            case supplyCode = "supply_code"
            case name
        }
    }
    
    struct File: Codable,Equatable,Hashable {
        let name: String
        let bucket: String
        let key: String
    }
    
    struct PharmacistRecord: Codable {
        let type1: [MedicationType1]
        let type2: [MedicationType2]
        
        enum CodingKeys: String, CodingKey {
            case type1 = "type_1"
            case type2 = "type_2"
        }
    }
    struct MedicationType1: Codable {
        let medicationID: Int
        let medicationCode: Int
        let name: String
        let formulation: String
        let period: Period
        
        enum CodingKeys: String, CodingKey {
            case medicationID = "medication_id"
            case medicationCode = "medication_code"
            case name
            case formulation
            case period
        }
    }
    
    struct Period: Codable {
        let morning: Int
        let lunch: Int
        let dinner: Int
        let days: Int
    }
    
    struct MedicationType2: Codable {
        let medicationID: Int
        let medicationCode: Int
        let name: String
        let formulation: String
        let count: Int
        
        enum CodingKeys: String, CodingKey {
            case medicationID = "medication_id"
            case medicationCode = "medication_code"
            case name
            case formulation
            case count
        }
    }
    
    struct PhaRoot: Codable {
        let pharmacist_record: PharmacistRecord
    }
    
}
