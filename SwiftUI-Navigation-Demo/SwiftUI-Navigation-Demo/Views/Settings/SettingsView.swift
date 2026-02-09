import SwiftUI

struct SettingsView: View {
  let onShowDetail: () -> Void

  @State private var notificationsEnabled = true
  @State private var darkModeEnabled = false

  var body: some View {
    List {
      Section {
        Toggle("알림", isOn: $notificationsEnabled)
        Toggle("다크 모드", isOn: $darkModeEnabled)
      } header: {
        Text("일반")
      }

      Section {
        Button {
          onShowDetail()
        } label: {
          Label("고급 설정", systemImage: "gearshape.2")
        }
      }

      Section {
        LabeledContent("버전", value: "1.0.0")
        LabeledContent("빌드", value: "100")
      } header: {
        Text("앱 정보")
      }

      Section {
        Button(role: .destructive) {
          // 로그아웃 로직
        } label: {
          Text("로그아웃")
            .frame(maxWidth: .infinity)
        }
      }
    }
    .navigationTitle("Settings")
  }
}

#Preview {
  NavigationStack {
    SettingsView(onShowDetail: {})
  }
}
