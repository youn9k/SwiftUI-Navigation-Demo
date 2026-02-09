import SwiftUI

/// NavigationStack 컨테이너
/// NavigationContainer 자체가 Router를 소유 및 생명주기를 관리
public struct NavigationContainer<Content: View>: View {
  @State var router: Router
  let viewBuilder: ViewBuilder
  @ViewBuilder var content: (_ navigate: @escaping (Destination) -> Void) -> Content

  public init(
    parentRouter: Router,
    tab: TabDestination? = nil,
    viewBuilder: ViewBuilder,
    @ViewBuilder content: @escaping (_ navigate: @escaping (Destination) -> Void) -> Content
  ) {
    self._router = .init(initialValue: parentRouter.childRouter(for: tab))
    self.viewBuilder = viewBuilder
    self.content = content
  }

  public var body: some View {
    InnerContainer(router: router, viewBuilder: viewBuilder) {
      content { destination in
        router.navigate(to: destination)
      }
    }
    .onAppear(perform: router.setActive)
    .onDisappear(perform: router.setInactive)
  }
}

/// NavigationContainer의 실제 뷰 구성을 담당하는 내부 컨테이너
///
/// 분리가 필요한 이유:
/// - sheet/fullScreenCover에서 새로운 NavigationContainer를 생성해야 함
/// - NavigationContainer 내부에서 직접 생성하면 컴파일러가 제네릭 Content를
///   현재 타입의 Content와 동일하게 맞추려고 시도하여 타입 에러 발생
/// - 별도 타입으로 분리하면 NavigationContainer<X>의 X를 독립적으로 추론 가능
private struct InnerContainer<Content: View>: View {
  @Bindable var router: Router
  let viewBuilder: ViewBuilder
  @ViewBuilder var content: () -> Content

  var body: some View {
    NavigationStack(path: $router.navigationStackPath) {
      content()
        .navigationDestination(for: PushDestination.self) { destination in
          destination.view(navigate: { router.navigate(to: $0) }, builder: viewBuilder)
        }
    }
    .sheet(item: $router.presentingSheet) { sheet in
      NavigationContainer(
        parentRouter: router,
        viewBuilder: viewBuilder
      ) { navigate in
        sheet.view(navigate: navigate, builder: viewBuilder)
      }
    }
    .fullScreenCover(item: $router.presentingFullScreen) { fullScreen in
      NavigationContainer(
        parentRouter: router,
        viewBuilder: viewBuilder
      ) { navigate in
        fullScreen.view(navigate: navigate, builder: viewBuilder)
      }
    }
  }
}

#Preview {
  NavigationContainer(
    parentRouter: .previewRouter(),
    viewBuilder: AppViewFactory()
  ) { _ in
    Text("Hello")
  }
}
