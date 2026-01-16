import SwiftUI

public struct NavigationButton<Content: View>: View {
  let destination: Destination
  @ViewBuilder var content: () -> Content
  @Environment(Router.self) private var router

  public init(
    destination: Destination,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.destination = destination
    self.content = content
  }

  public var body: some View {
    Button(action: { router.navigate(to: destination) }) {
      content()
    }
  }
}
