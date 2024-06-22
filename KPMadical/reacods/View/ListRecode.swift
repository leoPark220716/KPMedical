import SwiftUI

struct ListRecodeView: View {
    @EnvironmentObject var authViewModel: UserInformation
    @StateObject var model = ReacoderModel()
    @EnvironmentObject var router: GlobalViewRouter
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .latest
    var body: some View {
        VStack {
            // 검색 바
            SearchBar(text: $searchText)
                .padding(.horizontal)
            // 정렬 피커
            HStack{
                Picker("정렬 순서", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .pickerStyle(.segmented)
                .padding(.leading, 10)
                .frame(width: 200)
                Spacer()
            }
            if !filteredAndSortedCombineArray.isEmpty {
                ScrollView {
                    VStack {
                        ForEach(filteredAndSortedCombineArray.indices, id: \.self) { index in
                            TreatmentCard(item: filteredAndSortedCombineArray[index].doc, token: authViewModel.token)
                                .onTapGesture {
//                                    filteredAndSortedCombineArray[index]
                                    print("✅ 진단내용")
                                    var diagnosString = ""
                                    let diseases = filteredAndSortedCombineArray[index].doc.diseases
                                    for (i, item) in diseases.enumerated() {
                                        diagnosString += "🦠 ID \(item.diseaseID)\n🧪 CODE \(item.diseaseCode)\n🩸 \(item.name), \(item.name_eng)"
                                        if i < diseases.count - 1 {
                                            diagnosString += "\n"
                                        }
                                    }
                                    print(diagnosString)
                                    print("✅ 이미지 동영상")
                                    print(filteredAndSortedCombineArray[index].doc.files)
                                    print(filteredAndSortedCombineArray[index].doc.symptoms.files)
                                    print("✅ 진료기록")
                                    let contentString = "🩺 \(filteredAndSortedCombineArray[index].doc.symptoms.content)"
                                    print(contentString)
                                    print("✅ 처방")
                                    var pillsString = ""
                                    let pill = filteredAndSortedCombineArray[index].pha.type1
                                    for (i, item) in pill.enumerated(){
                                        pillsString += "💊 \(item.name)\n🦠 ID \(item.medicationID)\n🧪 CODE \(item.medicationCode)\n🗓️ \(item.period.days)\n🕘 아침 \(item.period.morning)알, 오후 \(item.period.lunch)알, 저녁 \(item.period.dinner)알"
                                        if i < pill.count - 1 {
                                            pillsString += "\n"
                                        }
                                    }
                                    print(pillsString)
                                    print("✅ 첨부파일")
                                    let name = sepStrings(inputString: filteredAndSortedCombineArray[index].doc.doctorID)
                                    router.tabPush(to: Route.detail_medical(
                                        item: DetailMedicalRecord(id: filteredAndSortedCombineArray[index].hospitalId,
                                                                  recodeString: contentString,
                                                                  diagnosString: diagnosString,
                                                                  treatmentString: pillsString,
                                                                  imageFiles: filteredAndSortedCombineArray[index].doc.symptoms.files,
                                                                  departCode: filteredAndSortedCombineArray[index].doc.departmentCode!,docName:name.DocName)))
                                }
                                .padding(.vertical, 5)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("검색 결과가 없습니다.")
                    .padding()
            }
            Spacer()
        }
        .onAppear {
            model.setRecodeData(token: authViewModel.token)
//            Task{
//                await model.ConfirmToShare(token: authViewModel.token)
//            }
//            model.createRSATest()
        }
        .navigationTitle("진료기록")
    }
    private func sepStrings(inputString: String) -> (er :Bool, DocId: String, DocName:String, hsNmae: String){
        let componets = inputString.components(separatedBy: ",")
        guard componets.count == 3 else{
            return (true,"","","")
        }
        return (false,componets[0],componets[1],componets[2] )
    }
    
    // 검색어와 정렬 기준에 따른 필터링 및 정렬된 배열
    var filteredAndSortedCombineArray: [ReacoderModel.MedicalCombineArrays] {
        var filteredArray = model.combineArray
        // 검색 필터링
        if !searchText.isEmpty {
            filteredArray = filteredArray.filter {
                $0.doc.symptoms.content.contains(searchText) ||
                $0.doc.doctorID.contains(searchText) ||
                $0.doc.symptoms.content.contains(searchText) ||
                $0.doc.diseases.contains { $0.name.contains(searchText) }
            }
        }
        // 정렬
        switch sortOrder {
        case .latest:
            filteredArray.sort { $0.unixTiem > $1.unixTiem }
        case .oldest:
            filteredArray.sort { $0.unixTiem < $1.unixTiem }
        }
        
        return filteredArray
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("검색", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}

enum SortOrder: String, CaseIterable {
    case latest = "최신순"
    case oldest = "오래된순"
}



struct ListRecodeView_Previews: PreviewProvider {
    static var previews: some View {
        ListRecodeView()
            .environmentObject(UserInformation())
    }
}
