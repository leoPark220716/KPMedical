//
//  TreatmentCard.swift
//  KPMadical
//
//  Created by Junsung Park on 5/29/24.
//

import SwiftUI

struct TreatmentCard: View {
    let item: ReacoderModel.DoctorRecord
    let model = MedicalsHttpRequestModel()
    let token: String
    @State var firstImage = ""
    @State var loadImage = false
    @State var valuse: (DocId:String, DocName:String, hosname:String) = ("", "", "")
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(height: 150)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
                .overlay(
                    HStack{
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(valuse.hosname)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.black)
                                Text("증상 : \(item.symptoms.content)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("병명 : \(item.diseases.isEmpty ? "미상" : item.diseases[0].name)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            HStack(spacing: 10) {
                                if let department = Department(rawValue: item.departmentCode ?? 0) {
                                    Text(department.name)
                                        .font(.system(size: 15))
                                        .bold()
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 5)
                                        .background(Color("ConceptColor"))
                                        .cornerRadius(20)
                                }
                                Text("👨🏻‍⚕️ \(valuse.DocName)")
                                    .font(.system(size: 15))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.leading,5)
                                    .padding(.trailing, 10)
                                    .padding(.vertical, 5)
                                    .background(Color("ConceptColor"))
                                    .cornerRadius(20)
                            }
                            .padding(.horizontal)
                            Spacer()
                        }
                        Spacer()
                        if !loadImage {
                            EmptyView()
                        }else{
                            AsyncImage(url: URL(string: firstImage)){ image in
                                image.resizable() // 이미지를 resizable로 만듭니다.
                                    .aspectRatio(contentMode: .fill) // 이미지의 종횡비를 유지하면서 프레임에 맞게 조정합니다.
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 90, height: 90)
                            .cornerRadius(25)
                            .padding()
                            .shadow(
                                radius: 10,
                                x: 5, y:5
                            )
                        }
                    }
                    .frame(maxWidth: .infinity) // 이 줄을 추가하여 왼쪽 정렬
                    .padding(.vertical, 20)
                )
                
        }
        .onAppear{
            if !item.symptoms.files.isEmpty{
                Task{
                    let img = await model.TokenToServer(httpMethod: "GET", tocken: token, bucket: item.symptoms.files[0].bucket, key: item.symptoms.files[0].key)
                    DispatchQueue.main.async{
                     firstImage = img
                        print(firstImage)
                        loadImage = true
                    }
                }
            }
            let setus = sepStrings(inputString: item.doctorID)
            if !setus.er{
                valuse.hosname = setus.hsNmae
                valuse.DocId = setus.DocId
                valuse.DocName = setus.DocName
            }
        }
    }
    private func sepStrings(inputString: String) -> (er :Bool, DocId: String, DocName:String, hsNmae: String){
        let componets = inputString.components(separatedBy: ",")
        guard componets.count == 3 else{
            return (true,"","","")
        }
        return (false,componets[0],componets[1],componets[2] )
    }
    
}

//#Preview {
//    TreatmentCard()
//}
