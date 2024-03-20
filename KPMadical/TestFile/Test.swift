import SwiftUI
import Combine
struct t: View {
    let jsonString: String = """
{
  "data": [
    {
      "hospital_name": "서울대병원",
      "hospital_image": "dsfafd",
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
    @State private var hospitals: [Hospitals] = []
    var body: some View {
            List(hospitals) { hospital in
                VStack(alignment: .leading) {
                    Text(hospital.hospital_name)
                        .font(.headline)
                    Text(hospital.address)
                        .font(.subheadline)
                    HStack {
                        ForEach(hospital.hospital_skill, id: \.self) { skill in
                            Text(skill)
                                .padding(.horizontal, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                }
            }
            .onAppear {
                self.hospitals = load_HospitalData(jsonString: jsonString) ?? []
            }
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
#Preview {
    t()
}
