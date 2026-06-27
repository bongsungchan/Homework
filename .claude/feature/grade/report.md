# 채점 리포트 — GitHub 저장소 검색 과제

생성: 자동 채점 (read-only)
총점: **90 / 100**

## 차원별 점수

| # | 차원 | 가중치 | 점수 | 가중 |
|---|---|---|---|---|
| 1 | 요구사항 충족도 | 35% | 94 | 32.9 |
| 2 | 코드 품질·아키텍처 | 30% | 90 | 27.0 |
| 3 | 완성도·동작 | 15% | 80 | 12.0 |
| 4 | UX·디자인 충실도 | 10% | 88 | 8.8 |
| 5 | 추가 구현(보너스) | 10% | 92 | 9.2 |
| | **합계** | | | **89.9 → 90** |

## 빌드·테스트 실행 결과 (실측)

- 명명 시뮬레이터 빌드(`-destination platform=iOS Simulator,name=iPhone 17 Pro`): **BUILD SUCCEEDED**
- 전 스킴 테스트: **75 tests, 0 failures**
  - App 1, Search 25, SearchResult 18, RepositoryWeb 13, Networking 7, Persistence 9, Models 2
- 단, `generic/platform=iOS Simulator`(x86_64) 빌드는 **BUILD FAILED** — 원인은 소스가 아니라 swift-navigation 의존성의 `PhaseScriptExecution`(스크립트 페이즈) 실패. arm64 명명 시뮬레이터에서는 정상 빌드·전 테스트 통과. 동작 가능하나 루브릭의 generic-destination 명령은 그린이 아님 → 완성도 일부 감점.

## 요구사항 체크리스트

### 검색 화면
| ID | 요구사항 | 상태 | 근거 |
|---|---|---|---|
| S1 | 검색어 입력 후 결과 표시 | 구현 | SearchView.swift:22 onSubmit→searchSubmitted; AppMain.swift:47-50 path append |
| S2 | 빈 검색어 시 최근검색어 최대 10 | 구현 | SearchFeature.swift:66-68; RecentSearchClient.swift:40-42 maxCount=10 prefix |
| S3 | 날짜 내림차순 정렬 | 구현 | RecentSearchClient.swift:24 sorted { $0.date > $1.date }; save insert at 0 |
| S4 | 삭제 / 전체삭제 | 구현 | SearchFeature.swift:103-123; SearchView.swift:106(전체삭제),152(개별 x) |
| S5 | 재시작 후 유지(영속성) | 구현 | RecentSearchClient.swift:18-29 UserDefaults persist/load |
| S6 | 최근검색어 선택 시 검색 | 구현 | SearchFeature.swift:99-101 recentSearchTapped→searchSubmitted |

### 검색 결과 화면
| ID | 요구사항 | 상태 | 근거 |
|---|---|---|---|
| R1 | List 형태 | 구현 | SearchResultView.swift:66 List |
| R2 | 총 결과 수 | 구현 | SearchResultView.swift:68 "\(totalCount)개 저장소" |
| R3 | 저장소 정보(avatar/name/login) | 구현 | RepositoryRowView.swift:11(avatarURL),30(name),36(owner.login); RepositoryClient.swift:43-46 매핑 |
| R4 | 선택 시 WebView | 구현 | AppMain.swift:53-55 repositoryTapped→repositoryWeb; RepositoryWebView.swift:16 WKWebView |

### 추가 구현(보너스)
| ID | 요구사항 | 상태 | 근거 |
|---|---|---|---|
| A1 | 자동완성(최근검색어 추출) | 구현 | SearchFeature.swift:77-83 filter; 300ms debounce 71-75 |
| A2 | 자동완성 검색 날짜 노출 | 구현 | SearchView.swift:214 date month().day() |
| A3 | Next Page prefetch | 구현 | SearchResultView.swift:87-93 n-3 임계값 onAppear fetchNextPage |
| A4 | 페이지 로딩 상태 | 구현 | SearchResultView.swift:100-105 LoadingFooter; isPaginationLoading |

## 차원별 근거·개선

### 1. 요구사항 충족도 — 94
모든 필수 10항목 + 보너스 구현. 영속성·정렬·중복갱신(RecentSearchClient.swift:38-39 removeAll 후 insert)까지 도메인 규칙 준수. 빈 결과를 실패가 아닌 empty로 분기(SearchResultFeature.swift:84) 처리 양호.
개선: 최근검색어 화면을 `searchable` 활성 상태에 의존 — searchable 미진입 시 idle 색만 노출되는 경로(SearchView.swift:31-33) 존재.

### 2. 코드 품질·아키텍처 — 90
TCA 단방향, @Reducer/@ObservableState, Dependency 주입(RepositoryClient/RecentSearchClient), cancellable+debounce, 도메인 SearchError 변환(RepositoryClient.swift:77-89), 레이어드 멀티모듈 단방향. 75개 유의미 TestStore 테스트.
개선: SearchFeature의 suggestion 필터 로직이 querySuggestionDebounced와 recentSearchesLoaded에 중복(SearchFeature.swift:80,128). RepositoryClient.testValue가 빈 클라이언트라 raw 호출 시 빈 동작.

### 3. 완성도·동작 — 80
명명 시뮬레이터 빌드 그린 + 75 테스트 0 실패. 단 generic-destination 빌드는 의존성 스크립트 페이즈로 실패(소스 무관). 엣지(빈/네트워크/rate limit/페이지 경계) 처리 명시적. AI 활용 흔적(.claude/, 커밋 trailer) 확인.

### 4. UX·디자인 충실도 — 88
예시1 대조: "Search" 타이틀(SearchView.swift:16), 검색창, "최근 검색" 헤더+전체삭제(99,109), 개별 x 버튼(155), 자동완성+날짜(214) 모두 일치. 예시2 대조: "N개 저장소"(68), 아바타+name+login 행(RepositoryRowView) 일치. 다크모드 시맨틱 컬러(DSColor.swift:173-176 systemBackground/label), 접근성 라벨·44pt·Dynamic Type 프리뷰 다수.
개선: 예시1의 "전체삭제"는 핑크 톤인데 구현은 dsAccent(systemBlue). 예시 결과화면 상단 검색바가 본 구현은 navigationTitle(inline)로 대체.

### 5. 추가 구현 — 92
자동완성·날짜·prefetch(n-3)·로딩푸터·인라인 페이지네이션 재시도(SearchResultView.swift:112-139)까지 충실.
개선: 자동완성이 GitHub 실시간 자동완성이 아닌 최근검색어 추출만(요구사항 부합하나 확장 여지).
