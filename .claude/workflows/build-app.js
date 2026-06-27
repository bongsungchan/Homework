export const meta = {
  name: 'build-app',
  description: 'GitHub 저장소 검색 앱을 TCA+Tuist+SwiftUI로 스캐폴딩→코어→화면→리뷰→검증 순으로 개발',
  phases: [
    { title: 'Scaffold', detail: 'Tuist 멀티모듈 골격 생성' },
    { title: 'Core', detail: 'Networking/Persistence/Models/UseCase 병렬 구현' },
    { title: 'Features', detail: '화면별 Feature→View→Test 파이프라인' },
    { title: 'Review', detail: 'swift-reviewer 다차원 리뷰 + 적대적 검증' },
    { title: 'Verify', detail: 'tuist test 게이트' },
  ],
}

// ── Phase 1: Scaffold ─────────────────────────────────────────────
phase('Scaffold')
const scaffold = await agent(
  'CLAUDE.md 모듈 구조대로 Tuist 멀티모듈(App/Features{Search,SearchResult,RepositoryWeb}/Domain{Models,UseCase}/Core{Networking,Persistence,DesignSystem}) 골격을 생성하라. 각 모듈에 컴파일 가능한 placeholder를 두어 빌드 그린을 유지하라.',
  { agentType: 'tuist-scaffolder', label: 'scaffold', phase: 'Scaffold', model: 'sonnet' }
)
log('스캐폴딩 완료. 모듈 구조 확정.')

// ── Phase 2: Core / Domain (병렬) ────────────────────────────────
phase('Core')
const CORE = [
  { key: 'Models', prompt: 'Domain/Models에 Repository(name, owner{login, avatarURL}, htmlURL, id), RecentSearch(query, date) 도메인 모델과 GitHub Search 응답 DTO→모델 매핑을 작성하라.' },
  { key: 'Networking', prompt: 'Core/Networking에 GitHub Search API(GET /search/repositories?q=&page=) 호출 RepositoryClient를 @DependencyClient로 작성하고, URLError/HTTP status를 SearchError로 변환하라. total_count도 반환.' },
  { key: 'Persistence', prompt: 'Core/Persistence에 최근 검색어 영속화 RecentSearchClient(@DependencyClient)를 작성하라. UserDefaults 기반, 최대 10개·날짜 내림차순·중복 시 최신 갱신·개별/전체 삭제.' },
]
const core = await parallel(
  CORE.map(c => () => agent(c.prompt, { agentType: 'tca-feature-builder', label: `core:${c.key}`, phase: 'Core', model: 'sonnet' }))
)

// ── Phase 3: Features (화면별 파이프라인, barrier 없음) ──────────
phase('Features')
const SCREENS = [
  { key: 'Search', spec: '검색 화면: 빈 검색어 시 최근 검색어(최대10·내림차순·삭제/전체삭제), 입력 시 자동완성(최근검색어 추출+날짜), 검색/최근어 선택 시 결과 화면 이동. 디바운스+이전요청 취소.' },
  { key: 'SearchResult', spec: '검색 결과 화면: total_count 표시, 리스트(썸네일 avatarURL/제목 name/설명 owner.login), 셀 선택 시 WebView 이동, 스크롤 중 다음 페이지 prefetch+로딩 푸터, 페이지 실패 인라인 재시도.' },
  { key: 'RepositoryWeb', spec: 'WebView 화면: htmlURL을 WKWebView(UIViewRepresentable)로 표시, 로딩 인디케이터.' },
]
const built = await pipeline(
  SCREENS,
  s => agent(`${s.key}Feature를 구현하라. 명세: ${s.spec}`, { agentType: 'tca-feature-builder', label: `feature:${s.key}`, phase: 'Features', model: 'sonnet' }).then(r => ({ s, feature: r })),
  ({ s }) => agent(`${s.key}View를 구현하라(접근성/다크모드 충족). 명세: ${s.spec}`, { agentType: 'swiftui-view-builder', label: `view:${s.key}`, phase: 'Features', model: 'sonnet' }).then(r => ({ s, view: r })),
  ({ s }) => agent(`${s.key}Feature의 TestStore 테스트를 작성하라. 명세: ${s.spec}`, { agentType: 'test-author', label: `test:${s.key}`, phase: 'Features', model: 'sonnet' }).then(r => ({ key: s.key, test: r }))
)

// ── Phase 4: Review (화면별 리뷰 → 적대적 검증) ──────────────────
phase('Review')
const reviews = await parallel(
  SCREENS.map(s => () => agent(
    `Features/${s.key} 의 Feature/View/Test를 CLAUDE.md 컨벤션·버그·접근성 관점으로 리뷰하라. file:line 근거와 심각도(blocker/warning/nit)로.`,
    { agentType: 'swift-reviewer', label: `review:${s.key}`, phase: 'Review', model: 'opus' }
  ))
)

// ── Phase 5: Verify ──────────────────────────────────────────────
phase('Verify')
const verify = await agent(
  'tuist install && tuist generate --no-open && tuist test 를 실행하고 통과/실패를 요약하라. 실패 시 파일:라인:사유를 추출하라.',
  { agentType: 'tuist-scaffolder', label: 'verify', phase: 'Verify', model: 'sonnet' }
)

return {
  scaffold,
  core: core.filter(Boolean),
  screens: built.filter(Boolean),
  reviews: reviews.filter(Boolean),
  verify,
}
