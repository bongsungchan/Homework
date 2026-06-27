# CLAUDE.md

이 파일은 Claude Code가 본 저장소에서 작업할 때 따라야 할 가이드입니다.

## 프로젝트 개요

GitHub 저장소 검색 앱. 키워드로 GitHub 저장소를 검색하고, 최근 검색어를 관리하며, 검색 결과를 WebView로 열어보는 iOS 앱입니다. (컬리 과제)

- 핵심 흐름: **검색 화면 → 검색 결과 화면 → WebView**
- 상세 요구사항은 `과제.md` 참고 (구현 시 SSOT)

## 기술 스택

- **언어**: Swift
- **UI**: SwiftUI
- **아키텍처**: TCA (The Composable Architecture)
- **모듈/빌드**: Tuist 기반 멀티모듈
- **최소 지원 버전**: iOS 16.0 (TCA 최신 + SwiftUI Observation 고려, 필요 시 조정)
- **비동기**: Swift Concurrency (async/await)
- **영속성**: 최근 검색어 저장 — UserDefaults 또는 파일 기반 (모듈 인터페이스 뒤로 추상화)

## 모듈 구조 (Tuist)

레이어드 멀티모듈로 구성하고, Feature는 화면 단위로 분리합니다.

```
Projects/
  App/                  # 앱 진입점, DI 조립, RootFeature
  Features/
    Search/             # 검색 화면 (최근 검색어 / 자동완성)
    SearchResult/       # 검색 결과 화면 (리스트 / 페이지네이션)
    RepositoryWeb/      # WebView (저장소 열기)
  Core/
    DesignSystem/       # 공통 UI 컴포넌트, 색상/타이포 토큰
    Networking/         # API 클라이언트 (GitHub Search API)
    Persistence/        # 최근 검색어 저장소
  Domain/
    Models/             # Repository, RecentSearch 등 도메인 모델
    UseCase/            # 검색/최근검색어 유스케이스 (TCA Dependency)
```

> 의존성 방향: `App → Features → Domain/Core` (단방향). Feature 간 직접 의존 금지, 공통은 Core/Domain으로.

## TCA 컨벤션

- 각 화면은 `@Reducer` 매크로 기반 `Feature`(State / Action / body)로 구성.
- 부수효과는 `Dependency`로 주입 (네트워크, 영속성, 시계 등). `@Dependency`로 접근하고 테스트에서 오버라이드.
- 화면 전이는 부모 Reducer에서 `Scope` / `ifLet` / `Stack`(NavigationStack)으로 조립.
- 비동기 작업은 `.run`, 취소는 `cancellable(id:)` — 검색어 입력 디바운스/이전 요청 취소에 활용.
- State는 값 타입·`Equatable` 유지, View는 `store`를 관찰하는 얇은 표현 계층으로 둠.

## API

```
[GET] https://api.github.com/search/repositories?q={keyword}&page={page}
```

- 표시 매핑: Thumbnail = `owner.avatar_url`, Title = `name`, Description = `owner.login`, 총 개수 = `total_count`
- 페이지네이션: 스크롤이 하단에 가까워지면 다음 페이지 prefetch, 로딩 인디케이터 표시
- Rate limit(미인증 시 분당 제한) 및 빈 결과/네트워크 에러 상태를 명시적으로 처리

## 주요 도메인 규칙

- **최근 검색어**: 최대 10개, 날짜 내림차순, 중복 시 최신 날짜로 갱신, 개별/전체 삭제, 앱 재시작 후에도 유지
- **자동완성**: 최근 검색어에서 추출, 검색 날짜 함께 노출
- 검색어가 비어 있으면 최근 검색어를, 입력 중이면 자동완성을, 검색 실행 시 결과를 표시

## 디렉터리 & 네이밍 컨벤션 (Swift API Design Guidelines 준수)

### 타입 네이밍
- **타입/프로토콜**: `UpperCamelCase` (`SearchFeature`, `RepositoryClient`)
- **프로퍼티/함수/케이스**: `lowerCamelCase` (`totalCount`, `fetchRepositories`)
- **프로토콜**: 역할은 명사(`RepositorySearching`), 능력은 `-able/-ible`(`Equatable`)
- **약어**: 전부 같은 케이스로 (`urlString`, `avatarURL`, `htmlURL`) — 대문자 약어는 통째 대/소문자
- **불리언**: `is/has/should` 접두 (`isLoading`, `hasNextPage`)
- **TCA 타입**: Reducer는 `XxxFeature`, View는 `XxxView`, Dependency는 `XxxClient`

### 파일 네이밍 (1파일 1주요타입 원칙)
- 파일명 = 주요 타입명 (`SearchFeature.swift`, `SearchView.swift`)
- 확장은 `Type+Protocol.swift` 형식 (`Repository+Identifiable.swift`)
- 프리뷰/모킹은 `XxxClient+Live.swift`, `XxxClient+Preview.swift`, `XxxClient+Test.swift`

### 모듈 내부 디렉터리 표준
```
Features/Search/
  Sources/
    Feature/       # SearchFeature.swift (Reducer)
    View/          # SearchView.swift + 하위 컴포넌트
    Component/     # 화면 전용 재사용 View
  Tests/
    SearchFeatureTests.swift
```

### 기타 규칙
- `import`는 알파벳 정렬, 표준 → 서드파티 → 내부 모듈 순 그룹화
- 접근 제어 명시: 모듈 경계 노출은 `public`, 기본은 `internal`, 구현 디테일은 `private`
- `// MARK: -` 로 섹션 구분 (State / Action / body / Dependencies)
- 들여쓰기 4 spaces, 한 줄 120자 권장 (SwiftFormat/SwiftLint로 강제)

## 에러 처리 정책

- 도메인 에러는 `enum`으로 모델링: `SearchError { case network, rateLimited, decoding, empty, unknown }`
- 네트워크 경계에서 `URLError`/HTTP status → 도메인 에러로 변환 (UI는 도메인 에러만 의존)
- State에 화면 상태를 명시적으로 표현: `enum ViewState { case idle, loading, loaded, empty, failed(SearchError) }`
- **사용자 노출 메시지 톤**: 짧고 비난하지 않으며 행동 가능하게. 기술 용어/스택트레이스 노출 금지
  - 네트워크: "인터넷 연결을 확인해 주세요."
  - Rate limit: "요청이 많아요. 잠시 후 다시 시도해 주세요."
  - 빈 결과: "검색 결과가 없어요."
- **재시도 UX**: 실패 화면에 "다시 시도" 버튼 제공 → 동일 쿼리/페이지 재요청. 페이지네이션 실패는 리스트 하단에 인라인 재시도 셀로.
- 로깅은 `OSLog`(`Logger`) 사용, 민감정보 미기록.

## 접근성 & 다크모드 (가점 요소)

- **Dynamic Type**: 고정 폰트 대신 `.font(.body)` 등 시맨틱 폰트 사용, 줄 수 제한 신중히
- **다크모드**: 하드코딩 색상 금지 → Asset Catalog의 시맨틱 컬러 / `Color(.systemBackground)` 사용. DesignSystem 토큰으로 관리
- **VoiceOver**: 의미 있는 `accessibilityLabel` (예: 저장소 셀 = "이름, 소유자"), 장식 이미지는 숨김
- **터치 영역**: 삭제(x) 버튼 등 최소 44x44pt 확보
- **명암비**: WCAG AA 충족, 색만으로 정보 전달 금지
- **상태 알림**: 로딩/에러 전환 시 적절한 accessibility 안내
- 두 모드(라이트/다크) + 큰 글씨에서 SwiftUI Preview로 검증

## 빌드 & 실행

```bash
tuist install      # 의존성 설치
tuist generate     # Xcode 프로젝트 생성
tuist build        # 빌드
tuist test         # 테스트
```

> `.xcodeproj`/`.xcworkspace`는 Tuist가 생성하므로 git에 커밋하지 않음 (`.gitignore` 확인).

## 테스트

- TCA `TestStore`로 Reducer 상태 전이/효과 검증 (검색, 최근 검색어 CRUD, 페이지네이션, 에러).
- Dependency를 테스트 더블로 주입해 네트워크 없이 결정론적으로 검증.

## 모델 정책

작업 성격에 따라 모델을 구분해 사용한다.

| 성격 | 모델 | 대상 |
| --- | --- | --- |
| **신규 개발 / 수정** | **Sonnet** | `tuist-scaffolder`, `tca-feature-builder`, `swiftui-view-builder`, `test-author` / `/new-feature`, `/verify`, `/device-verify` / Workflow Scaffold·Core·Features·Verify·DeviceVerify 페이즈 |
| **분석 / 계획 / 리뷰** | **Opus** | `swift-reviewer` / `/review` / Workflow Review 페이즈 / 아키텍처 설계·요구사항 분석 |

- Agent는 frontmatter `model:`, Command는 frontmatter `model:`, Workflow는 `agent(..., { model })`로 지정.
- 메인 세션에서 설계·계획을 진행할 때는 Opus, 구현 지시를 위임할 때는 Sonnet 에이전트로 분배한다.

## 작업 규칙

- 구현 순서는 과제 지침대로 **검색 화면 → 검색 결과 화면**.
- 커밋은 작은 단위로, 메시지는 변경 의도가 드러나게.
- GitHub **이슈로 작업을 관리**하고, 의미 있는 단위로 PR 구성.
- 새 의존성 추가 시 Tuist `Package.swift`/매니페스트에 반영하고 이유를 PR에 기록.
- 한국어로 커뮤니케이션. 코드 식별자는 영문 유지.
```

