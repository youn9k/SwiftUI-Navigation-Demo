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

  /// Sheet 표시
  func present(sheet destination: SheetDestination) {
    presentingSheet = destination
  }

  /// FullScreen 표시
  func present(fullScreen destination: FullScreenDestination) {
    presentingFullScreen = destination
  }

  /// 루트로 돌아가기
  func popToRoot() {
    navigationStackPath.removeAll()
  }
}
