import SwiftUI

struct HomeView: View {
  @Environment(Router.self) private var router

  var body: some View {
    List {
      Section {
        ForEach(SampleData.items) { item in
          Button {
            router.push(.itemDetail(id: item.id))
          } label: {
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
        Button {
          router.present(fullScreen: .onboarding)
        } label: {
          Label("온보딩 보기", systemImage: "info.circle")
        }

        Button {
          router.present(fullScreen: .imageViewer(url: "sample-image"))
        } label: {
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
