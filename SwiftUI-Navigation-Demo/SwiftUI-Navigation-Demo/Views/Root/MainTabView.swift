import SwiftUI

struct MainTabView: View {
  @State private var rootRouter = Router(level: 0)
  let viewBuilder: ViewBuilder

  var body: some View {
    TabView(selection: $rootRouter.selectedTab) {
      NavigationContainer(
        parentRouter: rootRouter,
        tab: .home,
        viewBuilder: viewBuilder
      ) { navigate in
        viewBuilder.makeHomeView(navigate: navigate)
      }
      .tabItem {
        Label("Home", systemImage: "house.fill")
      }
      .tag(TabDestination.home)

      NavigationContainer(
        parentRouter: rootRouter,
        tab: .profile,
        viewBuilder: viewBuilder
      ) { navigate in
        viewBuilder.makeProfileView(navigate: navigate)
      }
      .tabItem {
        Label("Profile", systemImage: "person.fill")
      }
      .tag(TabDestination.profile)

      NavigationContainer(
        parentRouter: rootRouter,
        tab: .settings,
        viewBuilder: viewBuilder
      ) { navigate in
        viewBuilder.makeSettingsView(navigate: navigate)
      }
      .tabItem {
        Label("Settings", systemImage: "gear")
      }
      .tag(TabDestination.settings)
    }
    .onAppear {
      if rootRouter.selectedTab == nil {
        rootRouter.selectedTab = .home
      }
    }
  }
}

#Preview {
  MainTabView(viewBuilder: AppViewFactory())
}
