# SwiftUI Navigation Demo App - Implementation Plan

## 개요

NotebookLM 문서 기반의 Router 패턴 + iOS 17+ `@Observable` 매크로를 활용한 SwiftUI 데모 앱 구현 계획

---

## 요구사항

### ✅ 3개의 탭 하단 탭바
- **Home 탭**: Push 네비게이션 데모 (3단계)
- **Profile 탭**: Sheet 데모 (1개)
- **Settings 탭**: Sheet 데모 (1개)

### ✅ 2개의 Sheet
- Sheet 1: 프로필 편집 (Profile 탭)
- Sheet 2: 설정 상세 옵션 (Settings 탭)

### ✅ 2개의 FullScreen
- FullScreen 1: 온보딩/튜토리얼
- FullScreen 2: 이미지 뷰어

### ✅ 3개의 Push (Home 탭에서)
- Push 1: Home → 아이템 상세
- Push 2: 아이템 상세 → 코멘트 목록
- Push 3: 코멘트 목록 → 답글 상세

---

## 아키텍처 설계

### @Observable 매크로 방식

| 항목 | 기존 방식 | **새로운 방식 (@Observable)** |
|------|----------|---------------------------|
| 클래스 선언 | `class Router: ObservableObject` | `@Observable class Router` |
| 프로퍼티 | `@Published var path` | `var path` (일반 변수) |
| 상태 생성 | `@StateObject var router` | `@State var router` |
| 환경 주입 | `.environmentObject(router)` | `.environment(router)` |
| 환경 읽기 | `@EnvironmentObject var router` | `@Environment(Router.self) var router` |
| 성능 | 전체 뷰 재렌더링 시도 | **특정 프로퍼티 변경 시만 렌더링** |

### 핵심 패턴 (NotebookLM 기반)

1. **값 기반 내비게이션 (Enum Destinations)**
   - 화면 간 결합도 최소화
   - 딥링크 및 프로그래밍 방식 전환 용이

2. **계층적 라우터 구조**
   - RootRouter: 탭 전환 제어
   - 각 탭별 독립적인 Router
   - 버블링 메커니즘으로 상위 전환 요청

3. **NavigationContainer**
   - NavigationStack 래핑
   - Sheet/FullScreen 통합 관리
   - 모달 내부에서도 독립적인 네비게이션

---

## 파일 구조

```
SwiftUI-Navigation-Demo/
├── SwiftUINavigationDemoApp.swift          # App 진입점
│
├── Navigation/                              # 네비게이션 시스템
│   ├── Router.swift                         # @Observable 라우터 (계층적 구조)
│   ├── NavigationContainer.swift            # NavigationStack 래퍼
│   ├── NavigationButton.swift               # 재사용 가능한 네비게이션 버튼
│   └── Destination/
│       ├── Destination.swift                # 모든 네비게이션 목적지 정의
│       │                                    #   - enum TabDestination
│       │                                    #   - enum PushDestination
│       │                                    #   - enum SheetDestination
│       │                                    #   - enum FullScreenDestination
│       └── Destination-ViewMapping.swift    # Destination → View 매핑 (extension)
│
├── Views/
│   ├── Root/
│   │   └── MainTabView.swift                # 루트 TabView (@State rootRouter)
│   │
│   ├── Home/                                # Push 네비게이션 (3단계)
│   │   ├── HomeView.swift                   # 아이템 목록
│   │   ├── ItemDetailView.swift             # 아이템 상세 (Push 1단계)
│   │   ├── CommentsView.swift               # 댓글 목록 (Push 2단계)
│   │   └── ReplyDetailView.swift            # 답글 상세 (Push 3단계)
│   │
│   ├── Profile/                             # Sheet 데모
│   │   ├── ProfileView.swift                # 프로필 화면
│   │   └── ProfileEditSheet.swift           # 프로필 편집 Sheet
│   │
│   ├── Settings/                            # Sheet 데모
│   │   ├── SettingsView.swift               # 설정 화면
│   │   └── SettingsDetailSheet.swift        # 고급 설정 Sheet
│   │
│   └── Modals/                              # FullScreen 모달
│       ├── OnboardingView.swift             # 온보딩 캐러셀
│       └── ImageViewerView.swift            # 이미지 뷰어
│
├── Models/
│   └── SampleData.swift                     # 더미 데이터 (Item, Comment, Reply)
│
└── Assets.xcassets/                         # 앱 아이콘 및 색상
    ├── AccentColor.colorset/
    └── AppIcon.appiconset/
```

---

### 3. Destination Enums

#### AppTab.swift
```swift
enum AppTab: Hashable {
    case home
    case profile
    case settings
}
```

#### PushDestination.swift
```swift
enum PushDestination: Hashable {
    case itemDetail(id: String)
    case comments(itemId: String)
    case replyDetail(commentId: String)
}
```

#### ModalDestination.swift
```swift
enum ModalDestination: Identifiable {
    case profileEdit
    case settingsDetail
    case onboarding
    case imageViewer(url: String)

    var id: Int { hashValue }
}
```

---


## 참고 자료

- NotebookLM
- https://developer.apple.com/documentation/SwiftUI/NavigationStack
- https://github.com/fespinoza/Youtube-SampleProjects/tree/main/MovieCatalog/Packages/2-Infrastructure/Navigation/Sources/Navigation
