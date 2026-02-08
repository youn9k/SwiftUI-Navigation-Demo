import SwiftUI

// MARK: - Push Destination

public extension PushDestination {
  /// Push 네비게이션 목적지를 뷰로 매핑하는 전역 함수
  @ViewBuilder
  var view: some View {
    switch self {
    case let .itemDetail(id):
      ItemDetailView(itemId: id)

    case let .comments(itemId):
      CommentsView(itemId: itemId)

    case let .replyDetail(commentId):
      ReplyDetailView(commentId: commentId)

    case .custom:
      // 커스텀 뷰는 NavigationContainer에서 Router를 통해 직접 해석됩니다.
      // 이 분기는 실행되지 않지만, 컴파일러 exhaustive check를 위해 필요합니다.
      EmptyView()
    }
  }
}

// MARK: - Sheet Destination

public extension SheetDestination {
  /// Sheet 목적지를 뷰로 매핑하는 전역 함수
  @ViewBuilder
  var view: some View {
    switch self {
    case .profileEdit:
      ProfileEditSheet()

    case .settingsDetail:
      SettingsDetailSheet()
    }
  }
}

// MARK: - FullScreen Destination

public extension FullScreenDestination {
  /// FullScreen 목적지를 뷰로 매핑하는 전역 함수
  @ViewBuilder
  var view: some View {
    switch self {
    case .onboarding:
      OnboardingView()

    case let .imageViewer(url):
      ImageViewerView(imageUrl: url)
    }
  }
}
