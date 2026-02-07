import Foundation

/// 자식 화면에서 부모 화면으로 전달되는 네비게이션 이벤트
///
/// 사용 흐름:
/// 1. 부모 화면: `router.present(sheet:onEvent:)` 또는 `router.push(_:onEvent:)`로 핸들러 등록
/// 2. 자식 화면: `router.send(.someEvent)` 로 이벤트 전송
/// 3. Router가 이벤트를 부모의 핸들러로 전달
public enum NavigationEvent {
  // MARK: - Profile

  /// 프로필 편집 완료
  case profileUpdated(name: String, email: String)

  // MARK: - Settings

  /// 설정 변경 완료
  case settingsChanged(autoSave: Bool, dataSync: Bool, cacheSize: Double)

  // MARK: - Onboarding

  /// 온보딩 완료 (건너뛰기 포함)
  case onboardingCompleted(skipped: Bool)
}
