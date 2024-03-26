import SwiftUI

struct TestView: View {
    @State var path = NavigationPath()
    @State var Comst = ["adsf", "123", "ㅁㄴㅇㄹㅇㄴ"]
    var body: some View {
        NavigationStack(path: $path) {
            List(Comst.indices, id: \.self) { index in
                NavigationLink(value: index) {
                    ListItem(Comst: $Comst[index])
                }
            }
            .navigationDestination(for: Int.self) { index in
                // 여기서는 ColorDetail 뷰의 각 인자를 적절하게 설정해야 합니다.
                ColorDetail(color: .red, path: $path, Comst1: Comst[index], Comst2: Comst[index], Comst3: Comst[index])
            }
            .navigationTitle("Colors")
        }
    }

}

struct ColorDetail: View {
    var color: Color
    @Binding var path: NavigationPath
    @State var Comst1: String
    @State var Comst2: String
    @State var Comst3: String
    var body: some View {
        Text(Comst1)
            .onTapGesture {
                path.append(1) // 또는 원하는 대로 배열을 조정
            }
        Text(Comst2)
            .onTapGesture {
                path = .init()
            }
        Text(Comst3)
            .onTapGesture {
                path = .init()
            }
        
        color.navigationTitle(color.description)
    }
}

struct ListItem: View {
    @Binding var Comst: String
    var body: some View {
        Text(Comst)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
