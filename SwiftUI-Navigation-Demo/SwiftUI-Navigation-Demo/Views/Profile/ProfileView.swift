import SwiftUI

struct ProfileView: View {
  @Environment(Router.self) private var router
  @State private var name = "홍길동"
  @State private var email = "hong@example.com"

  var body: some View {
    List {
      Section {
        HStack {
          Image(systemName: "person.circle.fill")
            .font(.system(size: 60))
            .foregroundStyle(.blue)

          VStack(alignment: .leading, spacing: 4) {
            Text(name)
              .font(.title2)
              .fontWeight(.bold)

            Text(email)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          .padding(.leading, 12)
        }
        .padding(.vertical, 12)
      }

      Section {
        LabeledContent("이름", value: name)
        LabeledContent("이메일", value: email)
        LabeledContent("전화번호", value: "010-1234-5678")
        LabeledContent("가입일", value: "2024.01.01")
      } header: {
        Text("프로필 정보")
      }

      Section {
        Button {
          router.present(sheet: .profileEdit) { event in
            if case let .profileUpdated(newName, newEmail) = event {
              name = newName
              email = newEmail
            }
          }
        } label: {
          Label("프로필 편집", systemImage: "pencil")
        }
      }
    }
    .navigationTitle("Profile")
  }
}

#Preview {
  NavigationStack {
    ProfileView()
      .environment(Router.previewRouter())
  }
}
