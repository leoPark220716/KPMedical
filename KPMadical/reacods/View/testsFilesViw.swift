import SwiftUI

struct TestView: View {
    @State private var selectedTab = 0
    @Namespace private var topID
    @Namespace private var medicalRecordID
    @Namespace private var imagesID
    @Namespace private var diagnosisID
    @Namespace private var treatmentID
    @Namespace private var filesID
    let data: DetailMedicalRecord
    let model = MedicalsHttpRequestModel()
    @EnvironmentObject var authViewModel: UserInformation
    @State var imgs:[String] = []
    @State var check = false
    var body: some View {
        VStack {
            // 상단 탭 뷰
            HStack(spacing: 10) {
                TabButton(title: "진료기록", tag: 0, selectedTab: $selectedTab, scrollTo: medicalRecordID)
                    .frame(maxWidth: .infinity)
                TabButton(title: "이미지", tag: 1, selectedTab: $selectedTab, scrollTo: imagesID)
                    .frame(maxWidth: .infinity)
                TabButton(title: "진단내용", tag: 2, selectedTab: $selectedTab, scrollTo: diagnosisID)
                    .frame(maxWidth: .infinity)
                TabButton(title: "처방", tag: 3, selectedTab: $selectedTab, scrollTo: treatmentID)
                    .frame(maxWidth: .infinity)
                TabButton(title: "첨부파일", tag: 4, selectedTab: $selectedTab, scrollTo: filesID)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment:.leading,spacing: 20) {
                        CardView(departCode: data.departCode, docName: data.docName,hosId: data.id,token: authViewModel.token)
                        // 진료기록 섹션
                        SectionView(id: medicalRecordID, title: "진료기록", content: data.recodeString)
                        if check{
                            // 이미지 섹션
                            ImageHorizontalView(id: imagesID, title: "이미지/동영상", content: imgs)
                        }
                        
                        // 진단내용 섹션
                        SectionView(id: diagnosisID, title: "진단내용", content: data.diagnosString)
                        
                        // 처방 섹션
                        SectionView(id: treatmentID, title: "처방", content: data.treatmentString)
                        
                        // 첨부파일 섹션
                        SectionView(id: filesID, title: "첨부파일", content: "첨부파일 내용")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .onChange(of: selectedTab) {
                        withAnimation {
                            switch selectedTab {
                            case 0: proxy.scrollTo(medicalRecordID, anchor: .top)
                            case 1: proxy.scrollTo(imagesID, anchor: .top)
                            case 2: proxy.scrollTo(diagnosisID, anchor: .top)
                            case 3: proxy.scrollTo(treatmentID, anchor: .top)
                            case 4: proxy.scrollTo(filesID, anchor: .top)
                            default: break
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear{
            Task{
                let imgarray = await model.getImagsList(token: authViewModel.token, files: data.imageFiles)
                if !imgarray.isEmpty{
                    DispatchQueue.main.async {
                        imgs = imgarray
                        check = true
                    }
                }
            }
        }
        .background(Color(UIColor.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

struct TabButton: View {
    let title: String
    let tag: Int
    @Binding var selectedTab: Int
    let scrollTo: Namespace.ID
    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(selectedTab == tag ? Color.blue : Color.black)
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        
    }
}

struct SectionView: View {
    let id: Namespace.ID
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(
            radius: 10,
            x: 5, y:5
        )
        .id(id)
    }
}
struct ImageHorizontalView: View {
    let id: Namespace.ID
    let title: String
    let content: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) { // 가로 스크롤 활성화
                HStack(spacing: 10) { // 이미지들 사이의 간격을 10으로 설정
                    ForEach(content.indices, id: \.self) { index in
                        recodeDitailImages(ima: content[index])
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(
            radius: 10,
            x: 5, y:5
        )
        .id(id)
    }
}
struct CardView: View {
    let departCode: Int
    let docName: String
    let hosId: Int
    let model = MedicalsHttpRequestModel()
    let token: String
    @State var img = ""
    @State var hosName = ""
    @State var stat = false
    
    var body: some View {
        VStack {
            HStack {
                if stat{
                    AsyncImage(url: URL(string: img)){ image in
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
                VStack {
                    Spacer()
                    Text(hosName)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.black)
                 Spacer()
                    HStack{
                        Spacer()
                        if let department = Department(rawValue: departCode) {
                            Text("\(department.name)")
                                .font(.system(size: 15))
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                                .background(Color("ConceptColor"))
                                .cornerRadius(20)
                        }
                        Spacer()
                        Text("👨🏻‍⚕️ \(docName)")
                            .font(.system(size: 15))
                            .bold()
                            .foregroundColor(.white)
                            .padding(.leading,5)
                            .padding(.trailing, 10)
                            .padding(.vertical, 5)
                            .background(Color("ConceptColor"))
                            .cornerRadius(20)
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 5)
        }
        .onAppear{
            Task{
                let name_img =  await model.getNameAndImg(httpMethod: "GET", tocken: token,hospitalId: hosId)
                if name_img.success{
                    DispatchQueue.main.async {
                        hosName = name_img.name
                        img = name_img.img
                        stat = true
                    }
                }
                print(name_img.img)
            }
        }
    }
}
struct recodeDitailImages: View {
    let ima: String
    var body: some View {
        VStack{
            ZStack(alignment: .topTrailing){
                AsyncImage(url: URL(string: ima)){ image in
                    image.resizable()  // 이미지 크기 조절 가능하도록 설정
                        .aspectRatio(contentMode: .fill)  // 내용을 프레임에 맞추어 채움
                        .frame(width: 150, height: 200)
                        .clipped()
                } placeholder: {
                    ProgressView()
                }
                
                    
                
            }
        }
    }
}
//struct TestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestView()
//    }
//}
