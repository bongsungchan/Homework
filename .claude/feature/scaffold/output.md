# Scaffold 단계 산출물

## 모듈 의존 그래프

```mermaid
flowchart TD
    subgraph APP["App"]
        A([GithubSearch App])
    end

    subgraph FEAT["Features"]
        F1([검색 입력])
        F2([검색 결과 목록])
        F3([저장소 웹 뷰어])
    end

    subgraph DOMAIN["Domain"]
        D1([도메인 모델])
        D2([유스케이스 / 클라이언트 키])
    end

    subgraph CORE["Core"]
        C1([네트워킹 클라이언트])
        C2([영속성 클라이언트])
        C3([디자인 시스템])
    end

    EXT([ComposableArchitecture]):::ext

    A --> F1
    A --> F2
    A --> F3

    F1 --> D1
    F1 --> D2
    F1 --> C3
    F2 --> D1
    F2 --> D2
    F2 --> C3
    F3 --> D1
    F3 --> C3

    D2 --> D1
    D2 --> C1
    D2 --> C2

    C1 --> D1
    C2 --> D1

    A -.->|외부| EXT
    F1 -.->|외부| EXT
    F2 -.->|외부| EXT
    F3 -.->|외부| EXT
    D2 -.->|외부| EXT

    classDef app fill:#4A90D9,stroke:#2C5F8A,color:#fff
    classDef feat fill:#7B68EE,stroke:#5A4BC7,color:#fff
    classDef domain fill:#50C878,stroke:#2E8B57,color:#fff
    classDef core fill:#FF8C42,stroke:#CC6A1F,color:#fff
    classDef ext fill:#B0B0B0,stroke:#808080,color:#fff

    class A app
    class F1,F2,F3 feat
    class D1,D2 domain
    class C1,C2,C3 core
    class EXT ext
```

---

## 생성 파일 / 모듈

| 레이어 | 모듈 | 경로 | 역할 |
|---|---|---|---|
| App | GithubSearch App | `Projects/App/` | 진입점, 루트 스토어, Feature 조합 |
| Features | 검색 입력 | `Projects/Features/Search/` | 검색어 입력, 디바운스, 최근 검색어 표시 |
| Features | 검색 결과 목록 | `Projects/Features/SearchResult/` | 저장소 목록 렌더링, 페이지네이션 |
| Features | 저장소 웹 뷰어 | `Projects/Features/RepositoryWeb/` | WebView로 저장소 상세 표시 |
| Domain | 도메인 모델 | `Projects/Domain/Models/` | GithubRepository, RecentSearch, SearchResult, SearchError |
| Domain | 유스케이스 / 클라이언트 키 | `Projects/Domain/UseCase/` | RepositoryClientKey, RecentSearchClientKey (TCA DependencyKey) |
| Core | 네트워킹 클라이언트 | `Projects/Core/Networking/` | RepositoryClient (GitHub API) |
| Core | 영속성 클라이언트 | `Projects/Core/Persistence/` | RecentSearchClient (로컬 저장) |
| Core | 디자인 시스템 | `Projects/Core/DesignSystem/` | DS토큰 + 공용 컴포넌트(RepositoryRow, EmptyState, ErrorState, LoadingFooter) |

---

## 핵심 결정

| 결정 | 내용 |
|---|---|
| 레이어 방향 | 단방향 의존: App → Features → Domain/Core. 역방향 참조 없음 |
| 외부 의존 격리 | ComposableArchitecture는 App·Features·Domain/UseCase에서만 직접 참조. Core/Networking·Persistence는 미사용 |
| 도메인 모델 위치 | Domain/Models가 최하위 노드(의존 없음). 네트워킹·영속성 모두 모델을 상향 참조 |
| 클라이언트 키 분리 | UseCase 모듈이 TCA DependencyKey만 선언. 실 구현(Live)은 Core에 위치해 테스트 교체 가능 |
| 디자인 시스템 독립 | DesignSystem은 Domain 비참조. 순수 UI 토큰·컴포넌트만 포함 |

---

## 미해결 / TODO

| # | 항목 | 비고 |
|---|---|---|
| 1 | Features 간 직접 의존 없음 확인 필요 | Search → SearchResult 내비게이션은 App 레이어에서 조율해야 함 |
| 2 | Core/Networking Live 구현 위치 | 현재 Sources에 RepositoryClient 단일 파일, Live/Test 분리 여부 미확정 |
| 3 | AppTests 커버리지 | 현재 빈 테스트 파일, 루트 스토어 통합 테스트 작성 필요 |
