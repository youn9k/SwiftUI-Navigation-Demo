import SwiftUI

@main
struct SwiftUINavigationDemoApp: App {
    private let container = AppContainer.shared

    var body: some Scene {
        WindowGroup {
            MainTabView(
                viewBuilder: container.resolve(ViewBuilder.self)
            )
        }
    }
}
