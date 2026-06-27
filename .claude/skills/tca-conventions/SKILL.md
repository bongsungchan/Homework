---
name: tca-conventions
description: 이 프로젝트의 TCA Reducer 작성 표준 — State/Action/body 구조, Dependency 주입, 효과 취소·디바운스 패턴. TCA Feature를 작성/리뷰할 때 참조.
---

# TCA 컨벤션

## Feature 골격
```swift
@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var query = ""
        var viewState: ViewState = .idle
        var recentSearches: [RecentSearch] = []
    }

    enum Action {
        case queryChanged(String)
        case searchResponse(Result<[Repository], SearchError>)
        case recentTapped(RecentSearch)
        case deleteRecent(RecentSearch.ID)
        case clearAllRecents
    }

    @Dependency(\.repositoryClient) var repositoryClient
    @Dependency(\.recentSearchClient) var recentSearchClient
    @Dependency(\.continuousClock) var clock

    enum CancelID { case search }

    var body: some ReducerOf<Self> {
        Reduce { state, action in /* ... */ }
    }
}
```

## 규칙
- State는 `Equatable`, 가능한 값 타입. 화면 상태는 `ViewState` enum으로.
- 모든 부수효과는 `@Dependency` Client를 통해서만. raw URLSession/UserDefaults 직접 호출 금지.
- 비동기는 `.run { send in ... }`, 취소는 `.cancellable(id: CancelID.search, cancelInFlight: true)`.
- 검색어 디바운스: `clock.sleep` 후 요청, 이전 요청은 `cancelInFlight`로 취소.
- 화면 전이는 부모에서 `Scope`/`ifLet`/`StackState`로 조립. Feature 간 직접 의존 금지.
- `// MARK: -` 로 State / Action / Dependencies / body 구획.
