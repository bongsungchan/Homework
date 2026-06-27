# Features 단계 산출물

## 생성 파일 및 모듈

| 모듈 | 파일 | 역할 |
|------|------|------|
| App | `AppMain.swift` | 앱 진입점 · AppFeature(검색+스택 네비게이션) · AppRootView |
| Features/Search | `SearchFeature.swift` | 검색어 입력 · 300ms 디바운스 자동완성 · 최근 검색어 CRUD · ViewState 관리 |
| Features/Search | `SearchView.swift` | 검색 화면 UI |
| Features/SearchResult | `SearchResultFeature.swift` | GitHub API 호출 · 무한 스크롤 페이지네이션 · 재시도 · ViewState 관리 |
| Features/SearchResult | `SearchResultView.swift` | 결과 목록 화면 UI |
| Features/SearchResult | `RepositoryRowView.swift` | 저장소 목록 셀 컴포넌트 |
| Features/RepositoryWeb | `RepositoryWebFeature.swift` | 웹 페이지 로드 상태(isLoading) 관리 · 닫기 처리 |
| Features/RepositoryWeb | `RepositoryWebView.swift` | WKWebView 래퍼 화면 |

## 핵심 결정

| 항목 | 결정 내용 |
|------|-----------|
| 화면 전환 전략 | AppFeature가 `SearchFeature.searchSubmitted`와 `SearchResultFeature.repositoryTapped`를 인터셉트해 `StackState<Path>`에 push. 각 Feature는 네비게이션 로직 미보유 |
| 디바운스 구현 | `ContinuousClock.sleep(300ms)`를 `.cancellable(cancelInFlight: true)`로 감싸 이전 작업 자동 취소. 쿼리 비어있으면 디바운스 없이 즉시 상태 전환 |
| 페이지네이션 분기 | 1페이지 실패 → `viewState = .failed`, 이후 페이지 실패 → `paginationError`(인라인). `currentPage`는 성공 후 +1하여 누적 관리 |
| 마지막 페이지 감지 | `repositories.count < totalCount` 비교로 `hasNextPage` 결정. `totalCount`는 첫 응답 기준 고정 |
| 쿼리 공백 처리 | 검색 제출 시 `trimmingCharacters(in: .whitespaces)` 적용 후 빈 문자열이면 화면 전환 차단 |
| ViewState 공유 | `SearchFeature`와 `SearchResultFeature` 모두 동일 구조의 `ViewState(idle/loading/loaded/empty/failed)` 독립 정의 |

## 미해결 / TODO

| 항목 | 내용 |
|------|------|
| 자동완성 소스 | 현재 로컬 최근 검색어 필터만 사용. 서버 사이드 자동완성 미구현 |
| 페이지네이션 재시도 | `retryPaginationTapped` 시 `currentPage`를 그대로 사용 — 앱 재진입 후 동기화 검증 필요 |
| 웹 뷰 오류 화면 | `pageLoadFailed` 상태에서 별도 오류 UI 미정의 (isLoading = false만 처리) |
| 접근성 | VoiceOver 레이블 · 동적 글꼴 대응 미확인 |

## 런타임 흐름 다이어그램

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant 검색 화면
    participant 검색 기능
    participant 최근 검색어 저장소
    participant 결과 화면
    participant GitHub API
    participant 웹 뷰 화면

    User->>검색 화면: 앱 진입
    검색 화면->>검색 기능: 화면 나타남
    검색 기능->>최근 검색어 저장소: 최근 검색어 불러오기
    alt 검색어 있음
        최근 검색어 저장소-->>검색 기능: 목록 반환 (최대 10개)
        검색 기능-->>검색 화면: ViewState = loaded (최근 검색어 표시)
    else 검색어 없음
        최근 검색어 저장소-->>검색 기능: 빈 목록
        검색 기능-->>검색 화면: ViewState = empty
    end

    User->>검색 화면: 검색어 입력 (타이핑)
    검색 화면->>검색 기능: 쿼리 변경 이벤트

    alt 쿼리 비어있음
        검색 기능-->>검색 화면: 즉시 최근 검색어 화면으로 전환
    else 쿼리 있음
        Note over 검색 기능: 300ms 디바운스 대기
        검색 기능->>검색 기능: 자동완성 필터 계산
        검색 기능-->>검색 화면: 자동완성 후보 표시
    end

    User->>검색 화면: 검색 실행 (키보드 확인 또는 후보 선택)
    검색 화면->>검색 기능: 검색 제출
    검색 기능->>최근 검색어 저장소: 검색어 저장
    최근 검색어 저장소-->>검색 기능: 갱신된 목록

    검색 기능->>결과 화면: 키워드 전달 (앱 기능이 화면 전환)
    결과 화면->>GitHub API: 저장소 검색 (키워드, 페이지 1)

    alt 정상 응답
        GitHub API-->>결과 화면: 저장소 목록 + 총 개수
        결과 화면-->>User: ViewState = loaded (목록 표시)
    else 빈 결과
        GitHub API-->>결과 화면: 빈 목록
        결과 화면-->>User: ViewState = empty
    else API 오류 / Rate Limit
        GitHub API-->>결과 화면: 오류 응답
        결과 화면-->>User: ViewState = failed (재시도 버튼)
        User->>결과 화면: 재시도 탭
        결과 화면->>GitHub API: 저장소 검색 재요청
    end

    User->>결과 화면: 목록 하단 도달 (무한 스크롤)
    결과 화면->>GitHub API: 저장소 검색 (다음 페이지)
    alt 페이지 로드 성공
        GitHub API-->>결과 화면: 추가 저장소 목록
        결과 화면-->>User: 목록 하단에 추가
    else 페이지 로드 실패
        GitHub API-->>결과 화면: 오류 응답
        결과 화면-->>User: 인라인 페이지네이션 오류 + 재시도
    end

    User->>결과 화면: 저장소 항목 탭
    결과 화면->>웹 뷰 화면: 저장소 URL · 이름 전달
    웹 뷰 화면->>웹 뷰 화면: 페이지 로드 시작 (isLoading = true)
    웹 뷰 화면-->>User: 로딩 인디케이터 표시
    alt 로드 성공
        웹 뷰 화면-->>User: 저장소 웹 페이지 표시 (isLoading = false)
    else 로드 실패
        웹 뷰 화면-->>User: 오류 상태 (isLoading = false)
    end
    User->>웹 뷰 화면: 닫기 탭
    웹 뷰 화면-->>결과 화면: 화면 해제
```

## ViewState 상태 머신

`SearchFeature`와 `SearchResultFeature`가 공통으로 사용하는 ViewState 전이.

```mermaid
stateDiagram-v2
    [*] --> idle : 초기화

    idle --> loading : 화면 나타남 (onAppear)

    loading --> loaded : 데이터 수신 성공
    loading --> empty : 빈 결과 수신
    loading --> failed : 오류 발생

    loaded --> loading : 검색어 변경 후 재검색
    empty --> loading : 검색어 변경 후 재검색

    failed --> loading : 재시도 탭

    loaded --> empty : 최근 검색어 전체 삭제
    loaded --> loaded : 쿼리 갱신 (자동완성 필터)
    empty --> loaded : 최근 검색어 저장 후 목록 복원

    note right of idle
        SearchFeature: onAppear guard로
        중복 진입 방지
    end note

    note right of failed
        SearchResultFeature: 1페이지 실패만
        viewState = failed
        이후 페이지는 paginationError로 분리
    end note
```
