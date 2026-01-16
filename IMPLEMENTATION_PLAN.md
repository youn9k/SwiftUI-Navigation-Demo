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

## 핵심 코드 구조

### 1. Router.swift (@Observable 방식)

```swift
import SwiftUI
import Observation

@Observable
class Router {
    // @Published 불필요 - 일반 변수로 선언
    var path: [PushDestination] = []
    var sheet: ModalDestination?
    var fullScreen: ModalDestination?
    var selectedTab: AppTab = .home

    var parent: Router?

    init(parent: Router? = nil) {
        self.parent = parent
    }

    // Push 네비게이션
    func push(_ destination: PushDestination) {
        path.append(destination)
    }

    // Sheet 표시
    func presentSheet(_ destination: ModalDestination) {
        sheet = destination
    }

    // FullScreen 표시
    func presentFullScreen(_ destination: ModalDestination) {
        fullScreen = destination
    }

    // 탭 전환 (버블링)
    func navigateToTab(_ tab: AppTab) {
        if let parent = parent {
            parent.navigateToTab(tab)
        } else {
            selectedTab = tab
        }
    }

    // 뒤로가기
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
```

### 2. NavigationContainer.swift

```swift
import SwiftUI

struct NavigationContainer<Content: View>: View {
    // @StateObject 대신 @State 사용
    @State var router: Router
    let content: Content

    init(parent: Router? = nil, @ViewBuilder content: () -> Content) {
        self._router = State(wrappedValue: Router(parent: parent))
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationDestination(for: PushDestination.self) { destination in
                    ViewFactory.viewForPush(destination)
                }
                .sheet(item: $router.sheet) { destination in
                    NavigationContainer(parent: router) {
                        ViewFactory.viewForModal(destination)
                    }
                }
                .fullScreenCover(item: $router.fullScreen) { destination in
                    NavigationContainer(parent: router) {
                        ViewFactory.viewForModal(destination)
                    }
                }
        }
        // .environmentObject() 대신 .environment() 사용
        .environment(router)
    }
}
```

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

### 4. ViewFactory.swift

```swift
import SwiftUI

struct ViewFactory {
    @ViewBuilder
    static func viewForPush(_ destination: PushDestination) -> some View {
        switch destination {
        case .itemDetail(let id):
            ItemDetailView(itemId: id)
        case .comments(let itemId):
            CommentsView(itemId: itemId)
        case .replyDetail(let commentId):
            ReplyDetailView(commentId: commentId)
        }
    }

    @ViewBuilder
    static func viewForModal(_ destination: ModalDestination) -> some View {
        switch destination {
        case .profileEdit:
            ProfileEditSheet()
        case .settingsDetail:
            SettingsDetailSheet()
        case .onboarding:
            OnboardingView()
        case .imageViewer(let url):
            ImageViewerView(imageUrl: url)
        }
    }
}
```

### 5. MainTabView.swift

```swift
import SwiftUI

struct MainTabView: View {
    // @StateObject 대신 @State 사용
    @State private var rootRouter = Router()

    var body: some View {
        TabView(selection: $rootRouter.selectedTab) {
            // Home 탭
            NavigationContainer(parent: rootRouter) {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            // Profile 탭
            NavigationContainer(parent: rootRouter) {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(AppTab.profile)

            // Settings 탭
            NavigationContainer(parent: rootRouter) {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppTab.settings)
        }
        .environment(rootRouter)
    }
}
```

### 6. 자식 뷰 사용 예시

```swift
struct HomeView: View {
    // @EnvironmentObject 대신 @Environment 사용
    @Environment(Router.self) private var router

    var body: some View {
        List {
            ForEach(SampleData.items) { item in
                Button(item.title) {
                    router.push(.itemDetail(id: item.id))
                }
            }

            Button("온보딩 보기") {
                router.presentFullScreen(.onboarding)
            }
        }
        .navigationTitle("Home")
    }
}
```

---

## 네비게이션 플로우

### Home 탭 - Push 3단계
```
HomeView (아이템 목록)
  ↓ 아이템 클릭
ItemDetailView (아이템 상세)
  ↓ "댓글 보기" 버튼
CommentsView (댓글 목록)
  ↓ 댓글 클릭
ReplyDetailView (답글 상세)
```

### Profile 탭 - Sheet 1개
```
ProfileView
  ↓ "프로필 편집" 버튼
ProfileEditSheet (모달로 표시)
```

### Settings 탭 - Sheet 1개
```
SettingsView
  ↓ "고급 설정" 버튼
SettingsDetailSheet (모달로 표시)
```

### FullScreen 2개
```
앱 시작 시 → OnboardingView (튜토리얼)
이미지 클릭 → ImageViewerView (이미지 풀스크린)
```

---

## 각 화면 구성

### HomeView
- 아이템 목록 (List)
- 각 아이템 클릭 시 → `router.push(.itemDetail(id: "1"))`
- 상단에 "온보딩 보기" 버튼 → `router.presentFullScreen(.onboarding)`

### ItemDetailView
- 아이템 상세 정보
- "댓글 보기" 버튼 → `router.push(.comments(itemId: "1"))`
- 이미지 클릭 → `router.presentFullScreen(.imageViewer(url: "..."))`

### CommentsView
- 댓글 목록
- 댓글 클릭 → `router.push(.replyDetail(commentId: "1"))`

### ReplyDetailView
- 답글 상세 화면
- 다른 탭으로 이동 버튼 → `router.navigateToTab(.profile)`

### ProfileView
- 프로필 정보 표시
- "프로필 편집" 버튼 → `router.presentSheet(.profileEdit)`

### SettingsView
- 설정 옵션 목록
- "고급 설정" 버튼 → `router.presentSheet(.settingsDetail)`

---

## 더미 데이터 (SampleData.swift)

```swift
struct Item: Identifiable {
    let id: String
    let title: String
    let description: String
}

struct Comment: Identifiable {
    let id: String
    let text: String
    let replies: [Reply]
}

struct Reply: Identifiable {
    let id: String
    let text: String
}

class SampleData {
    static let items = [
        Item(id: "1", title: "아이템 1", description: "설명 1"),
        Item(id: "2", title: "아이템 2", description: "설명 2"),
        Item(id: "3", title: "아이템 3", description: "설명 3")
    ]

    static let comments = [
        Comment(id: "1", text: "좋은 아이템이네요!", replies: [
            Reply(id: "1", text: "동의합니다")
        ]),
        Comment(id: "2", text: "유용한 정보 감사합니다", replies: [])
    ]

    static let replies = [
        Reply(id: "1", text: "동의합니다"),
        Reply(id: "2", text: "좋은 의견입니다")
    ]
}
```

---

## @Observable의 장점

1. **더 간결한 코드**: `@Published` 불필요
2. **성능 향상**: 특정 프로퍼티 변경 시에만 관련 뷰만 렌더링
3. **현대적인 Swift**: iOS 17+의 최신 패턴
4. **타입 안전성**: `.environment(Router.self)` 명시적 타입 지정

---

## 구현 순서

1. ✅ Core/Navigation (Router, Container, Enums)
2. ✅ ViewFactory
3. ✅ SampleData
4. ✅ MainTabView (Root)
5. ✅ Home 탭 + 3단계 Push
6. ✅ Profile 탭 + Sheet
7. ✅ Settings 탭 + Sheet
8. ✅ FullScreen 2개
9. ✅ 통합 테스트

---

## 참고 자료

- NotebookLM: https://notebooklm.google.com/notebook/db2413a7-44f1-4314-a4c2-cb7379a2ab30
- Router 패턴: 결합도 해제, 계층적 라우터, 버블링 메커니즘
- iOS 17+ @Observable: Observation framework
