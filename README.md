# GitHub Repository Search

GitHub 저장소를 검색하는 iOS 앱입니다. 키워드로 저장소를 검색하고, 최근 검색어를 관리하며, 선택한 저장소를 WebView로 열어봅니다.

> 컬리 사전 과제 — 요구사항 원문은 [`과제.md`](./과제.md) 참고

## 스크린샷

| 검색 화면 (최근 검색 / 자동완성) | 검색 결과 화면 |
| :---: | :---: |
| <img src="예시 1..png" width="320"> | <img src="예시 2..png" width="320"> |

> 위 이미지는 과제에서 제공한 예시이며, 실제 구현 스크린샷으로 교체 예정입니다.

## 주요 기능

### 검색 화면
- [x] 검색어 입력 → 검색 결과 화면 이동
- [x] 검색어가 비어 있으면 **최근 검색어 최대 10개** 표시 (날짜 내림차순)
- [x] 최근 검색어 **개별 삭제 / 전체 삭제**
- [x] 최근 검색 내역 **앱 재시작 후에도 유지** (영속성)
- [x] 최근 검색어 선택 시 검색 실행
- [x] (추가) 입력 시 **자동완성** + 검색 날짜 노출 (최근 검색어 기반)

### 검색 결과 화면
- [x] 검색 결과 List + **총 결과 수** 표시
- [x] 저장소 정보 (썸네일 `owner.avatar_url` / 제목 `name` / 설명 `owner.login`)
- [x] 셀 선택 시 **WebView**로 저장소 이동
- [x] (추가) 스크롤 중 **다음 페이지 prefetch** + 로딩 상태 표시

## 아키텍처

### 선택 이유
- **TCA (The Composable Architecture)**: 단방향 데이터 흐름으로 상태 변화를 예측 가능하게 관리하고, `TestStore`로 부수효과까지 결정론적으로 테스트할 수 있어 선택했습니다. 검색 디바운스·이전 요청 취소·페이지네이션처럼 상태가 얽히는 흐름을 명시적으로 다루기에 적합합니다.
- **Tuist 멀티모듈**: 화면/도메인/코어를 모듈로 분리해 의존성을 단방향으로 강제하고, 빌드 캐시와 모듈 단위 테스트로 확장성·생산성을 확보했습니다.
- **SwiftUI**: 선언형 UI로 상태와 화면을 1:1로 매핑하고, Preview로 다크모드·Dynamic Type을 빠르게 검증합니다.

### 모듈 구조
```
App           → 진입점, DI 조립, RootFeature
Features      → Search / SearchResult / RepositoryWeb (화면 단위)
Domain        → Models / UseCase (TCA Dependency)
Core          → Networking / Persistence / DesignSystem
```
의존성 방향: `App → Features → Domain/Core` (단방향, Feature 간 직접 의존 금지)

### 레이어 흐름
```
View(SwiftUI) → Store(TCA) → Reducer → Dependency(UseCase) → Client(Networking/Persistence)
```

## 기술 스택

| 구분 | 사용 |
| --- | --- |
| 언어 | Swift |
| UI | SwiftUI |
| 아키텍처 | TCA |
| 모듈/빌드 | Tuist |
| 비동기 | Swift Concurrency (async/await) |
| 영속성 | UserDefaults (인터페이스 추상화) |
| 린트/포맷 | SwiftLint, SwiftFormat |
| CI | GitHub Actions |

## 요구사항

- macOS (Apple Silicon 권장)
- Xcode 16+
- [Tuist](https://tuist.dev) (`mise` 또는 공식 설치 스크립트)

## 실행 방법

```bash
# 1. Tuist 설치 (mise 사용 시)
mise install

# 2. 의존성 설치 & 프로젝트 생성
tuist install
tuist generate

# 3. Xcode에서 실행 (생성 후 자동 오픈) 또는
tuist build
```

## 테스트

```bash
tuist test
```
- TCA `TestStore` 기반으로 검색 / 최근 검색어 CRUD / 페이지네이션 / 에러 처리 상태 전이를 검증합니다.
- Dependency를 테스트 더블로 주입해 네트워크 없이 결정론적으로 테스트합니다.

## API

```
GET https://api.github.com/search/repositories?q={keyword}&page={page}
```
미인증 호출은 분당 요청 제한(rate limit)이 있어, 제한·네트워크·빈 결과 상태를 화면에서 명시적으로 처리합니다.

## 프로젝트 관리

- 작업은 **GitHub Issue**로 관리하고, 의미 있는 단위로 **PR**을 구성했습니다.
- 구현 순서는 과제 지침에 따라 **검색 화면 → 검색 결과 화면** 순으로 진행했습니다.

## AI 활용

개발 과정에서 AI Assist(Claude Code)를 적극 활용했습니다. 구체적으로:
- 아키텍처/모듈 구조 설계 및 컨벤션 정의
- TCA Reducer·테스트 보일러플레이트 작성
- 엣지 케이스(빈 결과, rate limit, 페이지네이션 경계) 도출

> 협업 가이드는 [`CLAUDE.md`](./CLAUDE.md) 참고
