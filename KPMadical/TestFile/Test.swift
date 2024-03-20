//import SwiftUI
//import Combine
//struct viewTest: View{
//    @Binding var hospital: Hospitals
//    @State var WorkingState: Bool?
//    var body: some View{
//        VStack(alignment: .leading) {
//            Text(hospital.hospital_name)
//                .font(.headline)
//            Text(hospital.address)
//                .font(.subheadline)
//                HStack{
//                    Image(systemName: "stopwatch")
//                        .foregroundColor(WorkingState ?? false ? Color("ConceptColor") : Color(.gray))
//                        .font(.subheadline)
//                    Text(WorkingState ?? false ? "진료중" : "진료종료")
//                        .foregroundColor(WorkingState ?? false ? Color(.blue) : Color(.gray))
//                        .font(.subheadline)
//                    Text(WorkingState ?? false ? "\(hospital.startTime)~\(hospital.endTime)" : "")
//                        .font(.subheadline)
//                }
//                .padding(.top, 2)
//            HStack {
//                ForEach(hospital.hospital_skill.prefix(4), id: \.self) { skill in
//                    Text(skill)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.blue.opacity(0.1))
//                        .cornerRadius(10)
//                        .foregroundColor(.blue)
//                }
//                if hospital.hospital_skill.count > 4 {
//                    Text("...")
//                }
//            }
//        }
//        .padding(.vertical,5)
//        .onAppear(){
//            WorkingState = checkTimeIn(startTime: hospital.startTime, endTime: hospital.endTime)
//        }
//    }
//}
