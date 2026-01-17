# 네비게이션 모듈 의존성 개선 방안

현재 문제: `Destination-ViewMapping.swift`가 모든 피쳐 뷰를 직접 참조하여 양방향 의존성 발생

---

## 방안 1: Protocol-Based View Factory Pattern ⭐ (추천)

### 구조
```
NavigationCore (프로토콜만)
    ↑                    ↑
    │                    │
Navigation Module    Feature Modules
(Router, Container)  (각 피쳐가 Factory 구현)
```

### 구현 예시

#### 1.1 NavigationCore 모듈 (프로토콜 정의)

```swift
// NavigationCore/ViewFactory.swift
import SwiftUI

/// 각 Destination 타입에 대한 뷰 팩토리 프로토콜
public protocol PushViewFactory {
    @ViewBuilder
    func view(for destination: PushDestination) -> AnyView
}

public protocol SheetViewFactory {
    @ViewBuilder
    func view(for destination: SheetDestination) -> AnyView
}

public protocol FullScreenViewFactory {
    @ViewBuilder
    func view(for destination: FullScreenDestination) -> AnyView
}

/// 전역 뷰 팩토리 컨테이너
public final class ViewFactoryContainer {
    public static let shared = ViewFactoryContainer()

    private var pushFactory: PushViewFactory?
    private var sheetFactory: SheetViewFactory?
    private var fullScreenFactory: FullScreenViewFactory?

    private init() {}

    // 팩토리 등록
    public func register(push factory: PushViewFactory) {
        pushFactory = factory
    }

    public func register(sheet factory: SheetViewFactory) {
        sheetFactory = factory
    }

    public func register(fullScreen factory: FullScreenViewFactory) {
        fullScreenFactory = factory
    }

    // 뷰 생성
    public func makeView(for destination: PushDestination) -> AnyView {
        guard let factory = pushFactory else {
            fatalError("PushViewFactory not registered")
        }
        return factory.view(for: destination)
    }

    public func makeView(for destination: SheetDestination) -> AnyView {
        guard let factory = sheetFactory else {
            fatalError("SheetViewFactory not registered")
        }
        return factory.view(for: destination)
    }

    public func makeView(for destination: FullScreenDestination) -> AnyView {
        guard let factory = fullScreenFactory else {
            fatalError("FullScreenViewFactory not registered")
        }
        return factory.view(for: destination)
    }
}
```

#### 1.2 Navigation 모듈 (수정된 Destination-ViewMapping.swift)

```swift
// Navigation/Destination/Destination-ViewMapping.swift
import SwiftUI
import NavigationCore

public extension PushDestination {
    @ViewBuilder
    var view: some View {
        ViewFactoryContainer.shared.makeView(for: self)
    }
}

public extension SheetDestination {
    @ViewBuilder
    var view: some View {
        ViewFactoryContainer.shared.makeView(for: self)
    }
}

public extension FullScreenDestination {
    @ViewBuilder
    var view: some View {
        ViewFactoryContainer.shared.makeView(for: self)
    }
}
```

#### 1.3 HomeFeature 모듈 (각 피쳐가 팩토리 구현)

```swift
// HomeFeature/HomeViewFactory.swift
import SwiftUI
import NavigationCore

public struct HomeViewFactory: PushViewFactory {
    public init() {}

    public func view(for destination: PushDestination) -> AnyView {
        switch destination {
        case let .itemDetail(id):
            return AnyView(ItemDetailView(itemId: id))
        case let .comments(itemId):
            return AnyView(CommentsView(itemId: itemId))
        case let .replyDetail(commentId):
            return AnyView(ReplyDetailView(commentId: commentId))
        }
    }
}
```

#### 1.4 ProfileFeature 모듈

```swift
// ProfileFeature/ProfileViewFactory.swift
import SwiftUI
import NavigationCore

public struct ProfileViewFactory: SheetViewFactory {
    public init() {}

    public func view(for destination: SheetDestination) -> AnyView {
        switch destination {
        case .profileEdit:
            return AnyView(ProfileEditSheet())
        case .settingsDetail:
            return AnyView(EmptyView()) // 다른 피쳐가 담당
        }
    }
}
```

#### 1.5 앱 진입점 (등록)

```swift
// App/SwiftUI_Navigation_DemoApp.swift
import SwiftUI
import NavigationCore
import HomeFeature
import ProfileFeature
import SettingsFeature
import ModalsFeature

@main
struct SwiftUI_Navigation_DemoApp: App {
    init() {
        // 모든 뷰 팩토리 등록
        ViewFactoryContainer.shared.register(push: HomeViewFactory())
        ViewFactoryContainer.shared.register(sheet: CombinedSheetFactory())
        ViewFactoryContainer.shared.register(fullScreen: ModalsViewFactory())
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

// 여러 피쳐의 Sheet을 합친 팩토리
struct CombinedSheetFactory: SheetViewFactory {
    let profileFactory = ProfileViewFactory()
    let settingsFactory = SettingsViewFactory()

    func view(for destination: SheetDestination) -> AnyView {
        switch destination {
        case .profileEdit:
            return profileFactory.view(for: destination)
        case .settingsDetail:
            return settingsFactory.view(for: destination)
        }
    }
}
```

### 장점
- ✅ 타입 안정성 유지 (컴파일 타임 검증)
- ✅ 명확한 의존성 방향 (Navigation ← Core → Features)
- ✅ 각 피쳐가 독립적으로 뷰 생성 로직 관리
- ✅ 테스트 용이 (Mock Factory 주입 가능)

### 단점
- ❌ AnyView 사용으로 인한 타입 정보 손실
- ❌ 보일러플레이트 코드 증가 (각 피쳐마다 Factory 구현 필요)
- ❌ 런타임에 팩토리 미등록 시 크래시 가능

---

## 방안 2: Registration Pattern (런타임 등록)

### 구조
```
Navigation Module (ViewRegistry)
    ↑
    │ 등록 (앱 시작 시)
    │
Feature Modules
```

### 구현 예시

#### 2.1 Navigation 모듈 (ViewRegistry)

```swift
// Navigation/ViewRegistry.swift
import SwiftUI

public final class ViewRegistry {
    public static let shared = ViewRegistry()

    private var pushBuilders: [String: (PushDestination) -> AnyView] = [:]
    private var sheetBuilders: [String: (SheetDestination) -> AnyView] = [:]
    private var fullScreenBuilders: [String: (FullScreenDestination) -> AnyView] = [:]

    private init() {}

    // Push 등록
    public func register(
        push key: String,
        builder: @escaping (PushDestination) -> AnyView
    ) {
        pushBuilders[key] = builder
    }

    // Sheet 등록
    public func register(
        sheet key: String,
        builder: @escaping (SheetDestination) -> AnyView
    ) {
        sheetBuilders[key] = builder
    }

    // FullScreen 등록
    public func register(
        fullScreen key: String,
        builder: @escaping (FullScreenDestination) -> AnyView
    ) {
        fullScreenBuilders[key] = builder
    }

    // 뷰 빌드
    public func build(push destination: PushDestination) -> AnyView {
        let key = destination.registryKey
        guard let builder = pushBuilders[key] else {
            assertionFailure("No builder registered for push destination: \(key)")
            return AnyView(Text("View not found: \(key)"))
        }
        return builder(destination)
    }

    public func build(sheet destination: SheetDestination) -> AnyView {
        let key = destination.registryKey
        guard let builder = sheetBuilders[key] else {
            assertionFailure("No builder registered for sheet destination: \(key)")
            return AnyView(Text("View not found: \(key)"))
        }
        return builder(destination)
    }

    public func build(fullScreen destination: FullScreenDestination) -> AnyView {
        let key = destination.registryKey
        guard let builder = fullScreenBuilders[key] else {
            assertionFailure("No builder registered for fullScreen destination: \(key)")
            return AnyView(Text("View not found: \(key)"))
        }
        return builder(destination)
    }
}

// Destination에 레지스트리 키 추가
extension PushDestination {
    var registryKey: String {
        switch self {
        case .itemDetail: return "itemDetail"
        case .comments: return "comments"
        case .replyDetail: return "replyDetail"
        }
    }
}

extension SheetDestination {
    var registryKey: String {
        switch self {
        case .profileEdit: return "profileEdit"
        case .settingsDetail: return "settingsDetail"
        }
    }
}

extension FullScreenDestination {
    var registryKey: String {
        switch self {
        case .onboarding: return "onboarding"
        case .imageViewer: return "imageViewer"
        }
    }
}
```

#### 2.2 수정된 Destination-ViewMapping.swift

```swift
// Navigation/Destination/Destination-ViewMapping.swift
import SwiftUI

public extension PushDestination {
    @ViewBuilder
    var view: some View {
        ViewRegistry.shared.build(push: self)
    }
}

public extension SheetDestination {
    @ViewBuilder
    var view: some View {
        ViewRegistry.shared.build(sheet: self)
    }
}

public extension FullScreenDestination {
    @ViewBuilder
    var view: some View {
        ViewRegistry.shared.build(fullScreen: self)
    }
}
```

#### 2.3 HomeFeature 모듈 (자체 등록)

```swift
// HomeFeature/HomeFeatureRegistration.swift
import SwiftUI
import Navigation

public struct HomeFeature {
    public static func register() {
        // ItemDetail 등록
        ViewRegistry.shared.register(push: "itemDetail") { destination in
            if case let .itemDetail(id) = destination {
                return AnyView(ItemDetailView(itemId: id))
            }
            return AnyView(EmptyView())
        }

        // Comments 등록
        ViewRegistry.shared.register(push: "comments") { destination in
            if case let .comments(itemId) = destination {
                return AnyView(CommentsView(itemId: itemId))
            }
            return AnyView(EmptyView())
        }

        // ReplyDetail 등록
        ViewRegistry.shared.register(push: "replyDetail") { destination in
            if case let .replyDetail(commentId) = destination {
                return AnyView(ReplyDetailView(commentId: commentId))
            }
            return AnyView(EmptyView())
        }
    }
}
```

#### 2.4 앱 진입점 (모든 피쳐 등록)

```swift
// App/SwiftUI_Navigation_DemoApp.swift
import SwiftUI
import HomeFeature
import ProfileFeature
import SettingsFeature
import ModalsFeature

@main
struct SwiftUI_Navigation_DemoApp: App {
    init() {
        // 모든 피쳐 등록
        HomeFeature.register()
        ProfileFeature.register()
        SettingsFeature.register()
        ModalsFeature.register()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
```

### 장점
- ✅ 유연성 높음 (런타임에 동적으로 추가/제거 가능)
- ✅ 각 피쳐가 완전히 독립적
- ✅ 플러그인 아키텍처 구현 가능

### 단점
- ❌ 컴파일 타임 검증 불가 (등록 누락 시 런타임 에러)
- ❌ 타입 안정성 감소
- ❌ 디버깅 어려움 (어떤 뷰가 등록되었는지 추적 어렵)

---

## 방안 3: Type Erasure with Simplified AnyView

### 구조
```
Navigation Module (최소한의 변경)
    ↓
Feature Modules (기존 구조 유지)
```

### 구현 예시

#### 3.1 수정된 Destination-ViewMapping.swift

```swift
// Navigation/Destination/Destination-ViewMapping.swift
import SwiftUI

// 기존 코드를 최대한 유지하되, AnyView로 타입 소거만 추가
public extension PushDestination {
    @ViewBuilder
    var view: some View {
        switch self {
        case let .itemDetail(id):
            AnyView(ItemDetailView(itemId: id))
        case let .comments(itemId):
            AnyView(CommentsView(itemId: itemId))
        case let .replyDetail(commentId):
            AnyView(ReplyDetailView(commentId: commentId))
        }
    }
}

public extension SheetDestination {
    @ViewBuilder
    var view: some View {
        switch self {
        case .profileEdit:
            AnyView(ProfileEditSheet())
        case .settingsDetail:
            AnyView(SettingsDetailSheet())
        }
    }
}

public extension FullScreenDestination {
    @ViewBuilder
    var view: some View {
        switch self {
        case .onboarding:
            AnyView(OnboardingView())
        case let .imageViewer(url):
            AnyView(ImageViewerView(imageUrl: url))
        }
    }
}
```

#### 3.2 대안: Lazy Loading (옵션)

각 피쳐를 LazyView로 감싸서 실제 사용 시에만 로드:

```swift
// Navigation/LazyView.swift
import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

// 사용
public extension PushDestination {
    @ViewBuilder
    var view: some View {
        switch self {
        case let .itemDetail(id):
            LazyView(ItemDetailView(itemId: id))
        case let .comments(itemId):
            LazyView(CommentsView(itemId: itemId))
        case let .replyDetail(commentId):
            LazyView(ReplyDetailView(commentId: commentId))
        }
    }
}
```

### 장점
- ✅ 구현 단순함 (최소한의 변경)
- ✅ 기존 코드 구조 유지
- ✅ 이해하기 쉬움

### 단점
- ❌ 양방향 의존성 문제 근본적으로 해결 못함
- ❌ 모듈 분리 시 여전히 모든 피쳐 import 필요
- ❌ AnyView 사용으로 성능 영향 (SwiftUI 최적화 제한)

---

## 비교 요약

| 항목 | 방안 1: Protocol Factory | 방안 2: Registration | 방안 3: AnyView |
|------|-------------------------|---------------------|----------------|
| **의존성 방향** | ✅ 단방향 (Core ← 모두) | ✅ 단방향 (Navigation ← Features) | ❌ 양방향 유지 |
| **타입 안정성** | ⚠️ 중간 (AnyView 사용) | ❌ 낮음 (런타임 등록) | ⚠️ 중간 (AnyView 사용) |
| **컴파일 타임 검증** | ✅ 팩토리 구현 검증 | ❌ 등록 누락 감지 불가 | ✅ 뷰 존재 검증 |
| **구현 복잡도** | ⚠️ 중간 | ⚠️ 중간 | ✅ 낮음 |
| **유연성** | ⚠️ 중간 | ✅ 높음 | ❌ 낮음 |
| **모듈 분리 용이성** | ✅ 우수 | ✅ 우수 | ❌ 어려움 |
| **성능** | ⚠️ AnyView 오버헤드 | ⚠️ AnyView 오버헤드 | ⚠️ AnyView 오버헤드 |
| **테스트 용이성** | ✅ Mock Factory 주입 | ⚠️ Registry 모킹 필요 | ❌ 어려움 |

---

## 추천: 방안 1 (Protocol-Based View Factory)

### 이유
1. **명확한 의존성 구조**: Core 프로토콜을 중심으로 단방향 의존성
2. **타입 안정성**: 컴파일러가 Factory 구현 강제
3. **모듈화 용이**: SPM/CocoaPods 등으로 쉽게 분리 가능
4. **테스트 가능**: Mock Factory 주입으로 격리된 테스트

### 단점 보완책
- AnyView 오버헤드: SwiftUI는 이미 내부적으로 타입 소거를 사용하므로 실제 성능 영향 미미
- 보일러플레이트: 코드 생성 도구(Sourcery 등)로 자동화 가능

---

## 구현 계획

### Phase 1: NavigationCore 모듈 생성
1. ViewFactory 프로토콜 정의
2. ViewFactoryContainer 구현
3. Destination enum을 NavigationCore로 이동

### Phase 2: Navigation 모듈 리팩토링
1. Destination-ViewMapping을 Factory 기반으로 변경
2. Router, NavigationContainer는 그대로 유지

### Phase 3: Feature 모듈 분리
1. HomeFeature 모듈 생성 + HomeViewFactory 구현
2. ProfileFeature 모듈 생성 + ProfileViewFactory 구현
3. SettingsFeature 모듈 생성 + SettingsViewFactory 구현
4. ModalsFeature 모듈 생성 + ModalsViewFactory 구현

### Phase 4: 앱 레벨 통합
1. 각 Feature의 Factory를 App.init()에서 등록
2. 기존 코드 동작 검증
3. 불필요한 import 제거

### Phase 5: 테스트 및 문서화
1. 각 Feature별 단위 테스트 추가
2. 통합 테스트 (네비게이션 플로우)
3. 아키텍처 문서 업데이트
