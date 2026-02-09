import SwiftUI

struct HomeView: View {
  let onItemTapped: (String) -> Void
  let onOpenOnboarding: () -> Void
  let onOpenImageViewer: (String) -> Void

  var body: some View {
    List {
      Section {
        ForEach(SampleData.items) { item in
          Button {
            onItemTapped(item.id)
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
          onOpenOnboarding()
        } label: {
          Label("온보딩 보기", systemImage: "info.circle")
        }

        Button {
          onOpenImageViewer("url")
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
    HomeView(
      onItemTapped: { _ in },
      onOpenOnboarding: {},
      onOpenImageViewer: { _ in }
    )
  }
}
