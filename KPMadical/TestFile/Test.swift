import SwiftUI
import Combine
struct t: View {
    var jsonString: String = """
{
  "data": [
    {
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "11:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    },
        {
          "hospital_name": "서울대병원",
          "hospital_image": "dsfafd",
        "startTime" : "09:00",
        "endTime" : "19:00",
          "hospital_skill": [
            "안과",
            "비뇨기과",
            "내과"
          ],
          "hospital_id": "91",
          "address": "서울시 성북구 관양동",
          "longitude": "38.123512523",
          "latitude": "126.123512523"
        }
,{
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "19:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    },
    {
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "19:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    }
,{
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
        "endTime" : "11:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    }
,{
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "19:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    }
,{
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "19:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    }
,{
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
    "startTime" : "09:00",
    "endTime" : "19:00",
      "hospital_skill": [
        "안과",
        "비뇨기과",
        "내과",
        "성형외과",
        "신경외과",
        "산부인과"
      ],
      "hospital_id": "91",
      "address": "서울시 성북구 관양동",
      "longitude": "38.123512523",
      "latitude": "126.123512523"
    }
]
}
"""
    @State var hospitals: [Hospitals] = []
    @State var hospitals2: [Hospitals] = []
    var body: some View {
        List(hospitals.indices, id: \.self) {index in
            NavigationLink {
                Chat()
            } label: {
                viewTest(hospital: $hospitals[index])
            }
            .onAppear {
                if hospitals[index] == hospitals.last {
                    self.hospitals2 = load_HospitalData(jsonString: jsonString) ?? []
                    print(hospitals.last ?? "default value")
                    print("isBottom")
                    hospitals.append(contentsOf: hospitals2)
                }
            }
        }
        .onAppear {
            self.hospitals = load_HospitalData(jsonString: jsonString) ?? []
        }
        .navigationTitle("어떤 병원을 찾고 있으세요?")
    }
    

    func load_HospitalData(jsonString: String) -> [Hospitals]?{
        guard let jsonData = jsonString.data(using: .utf8) else{
            return nil
        }
        do{
            let hospitalList = try JSONDecoder().decode(HospitalData.self, from: jsonData)
            return hospitalList.data
        } catch {
            print("Err \(error)")
            return nil
        }
    }
}
struct viewTest: View{
//    var hospital: Hospitals = Hospitals(hospital_name: "Teamnova", hospital_image: "imageUrl",startTime: "09:00",endTime: "19:00", hospital_skill: ["비뇨기과", "안과", "내과"], hospital_id: "1", address: "서울시 성북구 성북동", longitude: "124.0", latitude: "38.0")
    @Binding var hospital: Hospitals
    @State var WorkingState: Bool?
    var body: some View{
        VStack(alignment: .leading) {
            Text(hospital.hospital_name)
                .font(.headline)
            Text(hospital.address)
                .font(.subheadline)
                HStack{
                    Image(systemName: "stopwatch")
                        .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
                        .font(.subheadline)
                    Text(WorkingState ?? false ? "진료중" : "진료종료")
                        .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
                        .font(.subheadline)
                    Text(WorkingState ?? false ? "\(hospital.startTime)~\(hospital.endTime)" : "")
                        .font(.subheadline)
                }
                .padding(.top, 2)
            HStack {
                ForEach(hospital.hospital_skill.prefix(4), id: \.self) { skill in
                    Text(skill)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .foregroundColor(.blue)
                }
                if hospital.hospital_skill.count > 4 {
                    Text("...")
                }
            }
        }
        .padding(.vertical,5)
        .onAppear(){
            WorkingState = checkTimeIn(startTime: hospital.startTime, endTime: hospital.endTime)
        }
    }
}
