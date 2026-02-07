import SwiftUI

struct HomeView: View {
  @Environment(Router.self) private var router
  @State private var onboardingCompleted = false

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
        Button {
          router.present(fullScreen: .onboarding) { event in
            if case let .onboardingCompleted(skipped) = event {
              onboardingCompleted = true
              print("온보딩 완료 (건너뜀: \(skipped))")
            }
          }
        } label: {
          HStack {
            Label("온보딩 보기", systemImage: "info.circle")
            Spacer()
            if onboardingCompleted {
              Text("완료")
                .font(.caption)
                .foregroundStyle(.green)
            }
          }
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
