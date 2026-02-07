import SwiftUI

struct SettingsView: View {
  @Environment(Router.self) private var router
  @State private var notificationsEnabled = true
  @State private var darkModeEnabled = false
  @State private var autoSave = true
  @State private var dataSync = true
  @State private var cacheSize = 50.0

  var body: some View {
    List {
      Section {
        Toggle("알림", isOn: $notificationsEnabled)
        Toggle("다크 모드", isOn: $darkModeEnabled)
      } header: {
        Text("일반")
      }

      Section {
        LabeledContent("자동 저장", value: autoSave ? "켜짐" : "꺼짐")
        LabeledContent("데이터 동기화", value: dataSync ? "켜짐" : "꺼짐")
        LabeledContent("캐시 크기", value: "\(Int(cacheSize))MB")
      } header: {
        Text("고급 설정 상태")
      }

      Section {
        Button {
          router.present(sheet: .settingsDetail) { event in
            if case let .settingsChanged(newAutoSave, newDataSync, newCacheSize) = event {
              autoSave = newAutoSave
              dataSync = newDataSync
              cacheSize = newCacheSize
            }
          }
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
    SettingsView()
      .environment(Router.previewRouter())
  }
}
