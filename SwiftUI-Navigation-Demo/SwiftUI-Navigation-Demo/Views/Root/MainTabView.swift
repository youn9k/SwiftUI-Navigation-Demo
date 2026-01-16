import SwiftUI

struct MainTabView: View {
  @State private var rootRouter = Router(level: 0)

  var body: some View {
    TabView(selection: $rootRouter.selectedTab) {
      // Home 탭 - Push 3단계 데모
      NavigationContainer(parentRouter: rootRouter, tab: .home) {
        HomeView()
      }
      .tabItem {
        Label("Home", systemImage: "house.fill")
      }
      .tag(TabDestination.home)

      // Profile 탭 - Sheet 데모
      NavigationContainer(parentRouter: rootRouter, tab: .profile) {
        ProfileView()
      }
      .tabItem {
        Label("Profile", systemImage: "person.fill")
      }
      .tag(TabDestination.profile)

      // Settings 탭 - Sheet 데모
      NavigationContainer(parentRouter: rootRouter, tab: .settings) {
        SettingsView()
      }
      .tabItem {
        Label("Settings", systemImage: "gear")
      }
      .tag(TabDestination.settings)
    }
    .environment(rootRouter)
    .onAppear {
      // 초기 탭 설정
      if rootRouter.selectedTab == nil {
        rootRouter.selectedTab = .home
      }
    }
  }
}

#Preview {
  MainTabView()
}
