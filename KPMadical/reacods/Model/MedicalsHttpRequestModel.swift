//
//  MedicalsHttpRequestModel.swift
//  KPMadical
//
//  Created by Junsung Park on 5/30/24.
//

import Foundation

class MedicalsHttpRequestModel{
    func TokenToServer(httpMethod: String, tocken: String,bucket: String, key: String) async -> String{
        let BodyData = filesData.init(bucket: bucket, key: key)
        guard let bodyJsonData = try? JSONEncoder().encode(BodyData),
              let bodyJsonString = String(data: bodyJsonData, encoding: .utf8) else {
            print("Failed to encode body data")
            return ""
        }
        print("CheckBodyString✅")
        print(bodyJsonString)
        
        let urlParse = "v2/hospitals/medical-data/file?files=[\(bodyJsonString)]&service_id=1"
                
        let httpStruct = http<Empty?, KPApiStructFrom<responseStruct>>.init(
            method: httpMethod,
            urlParse: urlParse,
            token: tocken ,
            UUID: getDeviceUUID()
        )
        
            let result = await StringJsonHttpRequest(HttpStructs: httpStruct)
            if result.success{
                print(result.data?.message ?? "Option Null")
                return result.data!.data.files[0].url
            }else{
                print(result.data?.message ?? "Option Null")
                return ""
            }
        
        struct bodyData:Codable{
            let files:[filesData]
        }
        struct filesData:Codable{
            let bucket:String
            let key:String
        }
        struct responseStruct:Codable{
            let files: [responsFilesData]
        }
        struct responsFilesData:Codable{
            let bucket:String
            let key:String
            let url:String
        }
    }
    func getImagsList(token:String,files: [ReacoderModel.File]) async -> [String]{
        var StringUrlArray: [String] = []
        var fileComponents = [String]()
        for file in files {
            let fileDict: [String: String] = ["bucket": file.bucket, "key": file.key]
            if let jsonData = try? JSONSerialization.data(withJSONObject: fileDict, options: []),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                fileComponents.append(jsonString)
            }
        }
        let filesString = "[\(fileComponents.joined(separator: ","))]"
        let queryString = "v2/hospitals/medical-data/file?files=\(filesString)&service_id=1"
        print("✅✅✅✅✅✅✅✅✅✅✅✅")
        print(queryString)
        let httpStruct = http<Empty?, KPApiStructFrom<responseStruct>>.init(
            method: "GET",
            urlParse: queryString,
            token: token,
            UUID: getDeviceUUID()
        )
        let result = await StringJsonHttpRequest(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            for item in result.data!.data.files{
                StringUrlArray.append(item.url)
            }
            return StringUrlArray
        }else{
            print(result.data?.message ?? "Option Null")
            return []
        }
        struct responseStruct:Codable{
            let files: [responsFilesData]
        }
        struct responsFilesData:Codable{
            let bucket:String
            let key:String
            let url:String
        }
    }
    func getNameAndImg(httpMethod: String, tocken: String,hospitalId: Int) async -> (success: Bool, name: String, img: String) {
        let httpStruct = http<Empty?, KPApiStructFrom<HospitalData>>.init(
            method: httpMethod,
            urlParse: "hospitals/detail?access_token=\(tocken)&uid=\(getDeviceUUID())&hospital_id=\(hospitalId)",
            token: tocken,
            UUID: getDeviceUUID()
        )
        let result = await KPWalletApi(HttpStructs: httpStruct)
        if result.success{
            print(result.data?.message ?? "Option Null")
            return (true, result.data!.data.hospital.hospital_name, result.data!.data.hospital.img_url[0])
        }else{
            print(result.data?.message ?? "Option Null")
            return (false,"","")
        }
        struct Hospital: Codable {
            let hospital_name: String
            let img_url: [String]
        }
        struct HospitalData: Codable {
            let hospital: Hospital
        }
    }
}
