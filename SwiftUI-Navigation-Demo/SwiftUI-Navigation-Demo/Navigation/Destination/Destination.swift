import Foundation

/// 모든 네비게이션 타입을 포함하는 상위 열거형
public enum Destination: Hashable {
  case tab(_ destination: TabDestination)
  case push(_ destination: PushDestination)
  case sheet(_ destination: SheetDestination)
  case fullScreen(_ destination: FullScreenDestination)
}

// MARK: - Tab Destination

public enum TabDestination: String, Hashable {
  case home // Home 탭 - Push 네비게이션 데모
  case profile // Profile 탭 - Sheet 데모
  case settings // Settings 탭 - Sheet 데모
}

// MARK: - Push Destination

public enum PushDestination: Hashable {
  case itemDetail(id: String) // Push 1: Home → 아이템 상세
  case comments(itemId: String) // Push 2: 아이템 상세 → 코멘트 목록
  case replyDetail(commentId: String) // Push 3: 코멘트 목록 → 답글 상세
}

// MARK: - Sheet Destination

public enum SheetDestination: Hashable {
  case profileEdit // Sheet 1: 프로필 편집 (Profile 탭)
  case settingsDetail // Sheet 2: 설정 상세 (Settings 탭)
}

extension SheetDestination: Identifiable {
  public var id: String {
    switch self {
    case .profileEdit: "profileEdit"
    case .settingsDetail: "settingsDetail"
    }
  }
}

// MARK: - FullScreen Destinations

public enum FullScreenDestination: Hashable {
  case onboarding // FullScreen 1: 온보딩/튜토리얼
  case imageViewer(url: String) // FullScreen 2: 이미지 뷰어
}

extension FullScreenDestination: Identifiable {
  public var id: String {
    switch self {
    case .onboarding: "onboarding"
    case let .imageViewer(url): "imageViewer-\(url)"
    }
  }
}
