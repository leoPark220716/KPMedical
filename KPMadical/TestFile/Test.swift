import SwiftUI
import MapKit // 맵 표시를 위해 필요합니다.
import Combine

class HospitalViewModel: ObservableObject {
    let requestList = HospitalHTTPRequest()
    @Published var hospitals: [HospitalDataManager.Hospitals] = []
    @Published var isSearching = false
    @Published var showList = false
    private var cancellables: Set<AnyCancellable> = []
    let searchTextPublisher = PassthroughSubject<String, Never>()
    
    init() {
        searchTextPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] completedText in
                // 여기에 HTTP 요청을 배치합니다.
                // 예시입니다, 실제로는 당신의 네트워크 요청으로 대체하세요.
                self?.fetchHospitals(keyword: completedText)
            }
            .store(in: &cancellables)
    }
    
    func fetchHospitals(keyword: String) {
        self.isSearching = true
        // 여기에서 hospitals 리스트를 업데이트하는 네트워크 요청을 수행합니다.
        // 요청이 성공하면 `@Published var hospitals`를 업데이트합니다.
        print(keyword)
        requestList.CallHospitalList(orderBy: "name", x: "", y: "", keyword: keyword, department_id: "") { result in
            
            switch result {
            case .success(let hospitals):
                DispatchQueue.main.async {
                    self.isSearching = false
                    self.showList = true
                    if !hospitals.isEmpty{
                        self.hospitals = hospitals
                        print(self.hospitals[0].department_id)
                    }
                }
            case .failure(let error):
                print("Failed Received Hospital: \(error)")
            }
            
        }
    }
}

struct Hospital__DetailView: View {
    @State private var searchText = ""
    @ObservedObject private var viewModel = HospitalViewModel()
    // 태그 배열
    var body: some View {
        VStack(alignment: .leading) {
            // 검색 바
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("찾고있는 병원을 검색하세요.", text: $searchText)
                    .font(.subheadline)
                    .onChange(of: searchText) {
                        viewModel.hospitals = []
                        viewModel.showList = false
                        if searchText != ""{
                            viewModel.searchTextPublisher.send(searchText)
                        }
                    }
            }
            .padding(.horizontal, 10)
            .frame(height: 40)
            .background(Color(.systemGray5)) // 연한 회색 배경
            .cornerRadius(10)
            .padding()
            if viewModel.hospitals.isEmpty{
                // 추천 키워드
                Text("추천 키워드")
                    .font(.headline)
                    .padding(.horizontal)
                // 태그들
                HStack(spacing: 10) {
                    ForEach(["외과", "진해병원", "안과"], id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 13))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("ConceptColor"), lineWidth: 2) // 파란색 태두리
                            )
                            .foregroundColor(Color("ConceptColor"))
                            .onTapGesture {
                                searchText = tag
                            }
                    }
                }
                .padding(.horizontal)
            }
            if viewModel.isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle()) // 또는 .progressViewStyle(.circular) for iOS 15+
                    .padding()
            }else{
                if viewModel.hospitals.isEmpty && !searchText.isEmpty && viewModel.showList{
                    HStack {
                        Spacer() // 왼쪽 공간을 추가하여 중앙 정렬
                        Text("'\(searchText)'에 대한 검색결과가 존재하지 않습니다.")
                            .foregroundColor(.gray) // 필요에 따라 색상 조정
                        Spacer() // 오른쪽 공간을 추가하여 중앙 정렬
                    }
                    .padding() // 추가적인 패딩을 제공하여 더 좋은 UI를 제공
                }else{
                    List(viewModel.hospitals.indices, id: \.self) {index in
                        FindHosptialItem(hospital: $viewModel.hospitals[index])
                            .background(
                                NavigationLink("",destination : HospitalDetailView())
                                    .opacity(0)
                            )
                    }
                    .listStyle(InsetListStyle())
                    .padding(.top, 10)
                }
            }
            Spacer()
        }
        .navigationBarTitle("검색", displayMode: .inline)
        .background(Color.white) // 전체 배경색
        
    }
}
struct HospitalDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Hospital__DetailView()
    }
}
