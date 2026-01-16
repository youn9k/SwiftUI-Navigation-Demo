import SwiftUI

struct HomeView: View {
  var body: some View {
    List {
      Section {
        ForEach(SampleData.items) { item in
          NavigationButton(destination: .push(.itemDetail(id: item.id))) {
            VStack(alignment: .leading, spacing: 4) {
              Text(item.title)
                .font(.headline)
                .foregroundStyle(.primary)
              Text(item.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
          }
        }
      } header: {
        Text("아이템 목록")
      }

      Section {
        NavigationButton(destination: .fullScreen(.onboarding)) {
          Label("온보딩 보기", systemImage: "info.circle")
        }

        NavigationButton(destination: .fullScreen(.imageViewer(url: "url"))) {
          Label("이미지 뷰어 열기", systemImage: "photo")
        }
      } header: {
        Text("FullScreen 데모")
      }
    }
    .navigationTitle("Home")
  }
}

#Preview {
  NavigationStack {
    HomeView()
      .environment(Router.previewRouter())
  }
}
