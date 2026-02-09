import SwiftUI

// ViewBuilder를 통한 뷰 생성으로 완전 교체
// 이 파일은 더 이상 Feature View를 직접 import하지 않음

// MARK: - Push Destination

public extension PushDestination {
  func view(navigate: @escaping (Destination) -> Void, builder: ViewBuilder) -> AnyView {
    builder.makeView(for: self, navigate: navigate)
  }
}

// MARK: - Sheet Destination

public extension SheetDestination {
  func view(navigate: @escaping (Destination) -> Void, builder: ViewBuilder) -> AnyView {
    builder.makeView(for: self, navigate: navigate)
  }
}

// MARK: - FullScreen Destination

public extension FullScreenDestination {
  func view(navigate: @escaping (Destination) -> Void, builder: ViewBuilder) -> AnyView {
    builder.makeView(for: self, navigate: navigate)
  }
}
