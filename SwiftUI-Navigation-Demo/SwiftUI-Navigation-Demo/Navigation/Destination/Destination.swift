import Foundation

/// 모든 네비게이션 타입을 포함하는 상위 열거형
public enum Destination {
  case tab(_ destination: TabDestination)
  case push(_ destination: PushDestination)
  case sheet(_ destination: SheetDestination)
  case fullScreen(_ destination: FullScreenDestination)
  case popToRoot  // 루트로 돌아가기
}

// Hashable 구현 (id 기반, 클로저는 비교에서 제외)
extension Destination: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .tab(dest):
            hasher.combine("tab")
            hasher.combine(dest)
        case let .push(dest):
            hasher.combine("push")
            hasher.combine(dest.id)
        case let .sheet(dest):
            hasher.combine("sheet")
            hasher.combine(dest.id)
        case let .fullScreen(dest):
            hasher.combine("fullScreen")
            hasher.combine(dest.id)
        case .popToRoot:
            hasher.combine("popToRoot")
        }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.tab(l), .tab(r)):
            return l == r
        case let (.push(l), .push(r)):
            return l.id == r.id
        case let (.sheet(l), .sheet(r)):
            return l.id == r.id
        case let (.fullScreen(l), .fullScreen(r)):
            return l.id == r.id
        case (.popToRoot, .popToRoot):
            return true
        default:
            return false
        }
    }
}

// MARK: - Tab Destination

public enum TabDestination: String, Hashable {
  case home // Home 탭 - Push 네비게이션 데모
  case profile // Profile 탭 - Sheet 데모
  case settings // Settings 탭 - Sheet 데모
}

// MARK: - Push Destination

public enum PushDestination {
  case itemDetail(id: String, onOpenComments: (String) -> Void)
  case comments(itemId: String, onReplyTapped: (String) -> Void)
  case replyDetail(commentId: String, onPopToRoot: () -> Void)
}

// PushDestination: Hashable + Identifiable (id 기반, 클로저 무시)
extension PushDestination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension PushDestination: Identifiable {
    public var id: String {
        switch self {
        case let .itemDetail(id, _):
            return "itemDetail-\(id)"
        case let .comments(itemId, _):
            return "comments-\(itemId)"
        case let .replyDetail(commentId, _):
            return "replyDetail-\(commentId)"
        }
    }
}

// MARK: - Sheet Destination

public enum SheetDestination {
  case profileEdit(onSave: (String) -> Void)
  case settingsDetail
}

// SheetDestination: Hashable + Identifiable (id 기반, 클로저 무시)
extension SheetDestination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension SheetDestination: Identifiable {
  public var id: String {
    switch self {
    case .profileEdit:
        return "profileEdit"
    case .settingsDetail:
        return "settingsDetail"
    }
  }
}

// MARK: - FullScreen Destinations

public enum FullScreenDestination {
  case onboarding
  case imageViewer(url: String)
}

// FullScreenDestination: Hashable + Identifiable
extension FullScreenDestination: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension FullScreenDestination: Identifiable {
  public var id: String {
    switch self {
    case .onboarding:
        return "onboarding"
    case let .imageViewer(url):
        return "imageViewer-\(url)"
    }
  }
}
