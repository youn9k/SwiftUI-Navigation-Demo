import SwiftUI

struct ItemDetailView: View {
  @Environment(Router.self) private var router
  let itemId: String

  private var item: Item? {
    SampleData.item(byId: itemId)
  }

  var body: some View {
    List {
      Section {
        if let item = item {
          VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
              .font(.title)
              .fontWeight(.bold)

            Text(item.description)
              .font(.body)
              .foregroundStyle(.secondary)
          }
          .padding(.vertical)
        } else {
          Text("아이템을 찾을 수 없습니다")
            .foregroundStyle(.secondary)
        }
      } header: {
        Text("아이템 정보")
      }

      Section {
        Button {
          router.push(.comments(itemId: itemId))
        } label: {
          Label("댓글 보기 (\(SampleData.comments.count))", systemImage: "bubble.left")
        }
      } header: {
        Text("액션")
      }

      Section {
        Button {
          router.select(tab: .profile)
        } label: {
          Label("Profile 탭으로 이동", systemImage: "person.fill")
        }

        Button {
          router.select(tab: .settings)
        } label: {
          Label("Settings 탭으로 이동", systemImage: "gear")
        }
      } header: {
        Text("탭 전환 데모")
      }
    }
    .navigationTitle("아이템 상세")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    ItemDetailView(itemId: "1")
      .environment(Router.previewRouter())
  }
}
