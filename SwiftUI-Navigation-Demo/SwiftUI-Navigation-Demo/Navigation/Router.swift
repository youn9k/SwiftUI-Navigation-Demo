import Observation
import SwiftUI

/// @Observable 매크로를 사용한 네비게이션 라우터
/// 계층적 라우터 구조 + 활성 상태 추적
@Observable
public final class Router {
  let id = UUID()
  let level: Int

  /// level 0 루트 라우터에서만 사용: 선택된 탭
  public var selectedTab: TabDestination?

  /// NavigationStack 경로
  public var navigationStackPath: [PushDestination] = []

  /// 현재 표시 중인 Sheet
  public var presentingSheet: SheetDestination?

  /// 현재 표시 중인 FullScreen
  public var presentingFullScreen: FullScreenDestination?

  /// 부모 라우터 참조 (계층 구조 형성)
  /// level은 부모는 0, 자식은 1씩 증가
  weak var parent: Router?

  /// 현재 라우터가 활성 상태인지 추적 (추후 딥링크 적용 시 활용)
  private(set) var isActive: Bool = false

  /// 자식 화면에서 보낸 이벤트를 처리하는 핸들러
  ///
  /// - Sheet/FullScreen: 부모 라우터에 핸들러를 설정하면 자식 라우터의 `send()`가 부모로 전파
  /// - Push: 같은 라우터에 핸들러를 설정하면 `send()`가 로컬 핸들러를 호출
  var eventHandler: ((NavigationEvent) -> Void)?

  public init(level: Int) {
    self.level = level
    self.parent = nil
  }

  private func resetContent() {
    navigationStackPath = []
    presentingSheet = nil
    presentingFullScreen = nil
  }
}

// MARK: - Router Management

public extension Router {
  /// 자식 라우터 생성
  func childRouter(for tab: TabDestination? = nil) -> Router {
    let router = Router(level: level + 1)
    router.parent = self
    return router
  }

  /// 라우터를 활성 상태로 설정
  func setActive() {
    parent?.setInactive()
    isActive = true
  }

  /// 라우터를 비활성 상태로 설정
  func setInactive() {
    isActive = false
    parent?.setActive()
  }

  /// Preview용 라우터
  static func previewRouter() -> Router {
    Router(level: 0)
  }
}

// MARK: - Navigation

public extension Router {
  /// 통합 네비게이션 메서드
  func navigate(to destination: Destination) {
    switch destination {
    case let .tab(tab):
      select(tab: tab)
    case let .push(destination):
      push(destination)
    case let .sheet(destination):
      present(sheet: destination)
    case let .fullScreen(destination):
      present(fullScreen: destination)
    }
  }

  /// 탭 선택 (자식 → 부모 → 루트로 전송)
  func select(tab destination: TabDestination) {
    if level == 0 {
      selectedTab = destination
    } else {
      parent?.select(tab: destination)
      resetContent()
    }
  }

  /// Push 네비게이션
  func push(_ destination: PushDestination) {
    navigationStackPath.append(destination)
  }

  /// Push 네비게이션 + 이벤트 핸들러 등록
  ///
  /// Push된 화면에서 `router.send(.someEvent)`를 호출하면 핸들러가 실행됩니다.
  /// Push된 화면과 현재 화면은 같은 Router를 공유하므로 로컬 핸들러로 처리됩니다.
  func push(_ destination: PushDestination, onEvent handler: @escaping (NavigationEvent) -> Void) {
    eventHandler = handler
    navigationStackPath.append(destination)
  }

  /// Sheet 표시
  func present(sheet destination: SheetDestination) {
    presentingSheet = destination
  }

  /// Sheet 표시 + 이벤트 핸들러 등록
  ///
  /// Sheet 화면에서 `router.send(.someEvent)`를 호출하면 핸들러가 실행됩니다.
  /// Sheet는 별도의 자식 Router를 갖고, 이벤트는 부모 Router로 전파됩니다.
  func present(sheet destination: SheetDestination, onEvent handler: @escaping (NavigationEvent) -> Void) {
    eventHandler = handler
    presentingSheet = destination
  }

  /// FullScreen 표시
  func present(fullScreen destination: FullScreenDestination) {
    presentingFullScreen = destination
  }

  /// FullScreen 표시 + 이벤트 핸들러 등록
  ///
  /// FullScreen 화면에서 `router.send(.someEvent)`를 호출하면 핸들러가 실행됩니다.
  /// FullScreen은 별도의 자식 Router를 갖고, 이벤트는 부모 Router로 전파됩니다.
  func present(fullScreen destination: FullScreenDestination, onEvent handler: @escaping (NavigationEvent) -> Void) {
    eventHandler = handler
    presentingFullScreen = destination
  }

  /// 루트로 돌아가기
  func popToRoot() {
    navigationStackPath.removeAll()
  }
}

// MARK: - Event Handling

public extension Router {
  /// 이벤트를 부모 화면으로 전송
  ///
  /// 이벤트 전파 순서:
  /// 1. 현재 라우터의 eventHandler 확인 (Push 네비게이션 시 같은 라우터를 공유)
  /// 2. 없으면 부모 라우터로 전파 (Sheet/FullScreen 시 별도 자식 라우터 사용)
  func send(_ event: NavigationEvent) {
    if let handler = eventHandler {
      handler(event)
    } else {
      parent?.send(event)
    }
  }

  /// 이벤트 핸들러 해제
  func clearEventHandler() {
    eventHandler = nil
  }
}
