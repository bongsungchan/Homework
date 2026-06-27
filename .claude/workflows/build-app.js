export const meta = {
  name: 'build-app',
  description: 'GitHub 저장소 검색 앱을 TCA+Tuist+SwiftUI로 스캐폴딩→코어→화면→리뷰→검증→실기기검증 순으로 개발. 각 Phase 종료 시 커밋·푸시.',
  phases: [
    { title: 'Scaffold', detail: 'Tuist 멀티모듈 골격 생성' },
    { title: 'DesignSystem', detail: 'Figma 추출 토큰 모듈 배치 + 공통 컴포넌트' },
    { title: 'Core', detail: 'Networking/Persistence/Models/UseCase 병렬 구현' },
    { title: 'Features', detail: '화면별 Feature→View→Test 파이프라인' },
    { title: 'Review', detail: 'swift-reviewer 다차원 리뷰 + 적대적 검증' },
    { title: 'Verify', detail: 'tuist test 게이트' },
    { title: 'DeviceVerify', detail: '실기기 빌드·설치 + 수동 QA 체크리스트 (사람 게이트)' },
  ],
}

// Phase 종료마다 커밋·푸시. 커밋이 주석 차단 규칙 훅에 막히면
// 새로 추가된 Swift의 WHAT 주석/독스트링/MARK를 제거하고 재시도하도록 지시한다.
async function commitPush(tag, phaseTitle) {
  return agent(
    `워크플로우 '${tag}' 단계 산출물을 커밋·푸시하라.\n` +
    `1) git add -A (단, .env/비밀은 절대 스테이징 금지 — 이미 .gitignore 처리됨)\n` +
    `2) git commit -m "build(${tag}): <변경 요약 1줄>" + Co-Authored-By 트레일러\n` +
    `   - 커밋이 "주석 차단" 훅에 막히면, 지목된 Swift 파일에서 // 또는 /// WHAT 주석·파일헤더·// MARK 를 제거하고 swiftc -parse 통과 확인 후 재시도하라(코드 로직은 유지).\n` +
    `3) git push origin main\n` +
    `변경 사항이 없으면 "nothing to commit"으로 보고하고 종료. 결과(커밋 해시·푸시 여부)를 한 줄로 보고하라.`,
    { agentType: 'tuist-scaffolder', label: `commit:${tag}`, phase: phaseTitle, model: 'sonnet' }
  )
}

// 단계 산출물을 .claude/feature/<phase>/ 에 Mermaid 다이어그램+요약으로 기록.
async function diagramFor(tag, phaseTitle, summary, isFinal) {
  return agent(
    `'${tag}' 단계 산출물을 workflow-diagram 스킬대로 문서화하라.\n` +
    `대상 폴더: .claude/feature/${tag}/ (diagram.mmd + output.md, mmdc 있으면 diagram.png)\n` +
    (isFinal ? `추가로 .claude/feature/pipeline.mmd 전체 개요(flowchart LR)도 갱신하라.\n` : '') +
    `실제 생성된 파일을 Glob/Read로 확인해 반영하고 추측은 금지. 산출물 요약: ${summary}`,
    { agentType: 'diagram-author', label: `diagram:${tag}`, phase: phaseTitle, model: 'sonnet' }
  )
}

// ── Phase 1: Scaffold ─────────────────────────────────────────────
phase('Scaffold')
const scaffold = await agent(
  'CLAUDE.md 모듈 구조대로 Tuist 멀티모듈(App/Features{Search,SearchResult,RepositoryWeb}/Domain{Models,UseCase}/Core{Networking,Persistence,DesignSystem}) 골격을 생성하라. 각 모듈에 컴파일 가능한 placeholder를 두어 빌드 그린을 유지하라.',
  { agentType: 'tuist-scaffolder', label: 'scaffold', phase: 'Scaffold', model: 'sonnet' }
)
log('스캐폴딩 완료. 모듈 구조 확정.')
await diagramFor('scaffold', 'Scaffold', '모듈 의존 그래프(App→Features→Domain/Core)')
await commitPush('scaffold', 'Scaffold')

// ── Phase 1.5: DesignSystem (Figma 추출 토큰을 모듈에 배치) ───────
phase('DesignSystem')
const designSystem = await agent(
  'Figma(DesignCode UI)에서 추출해 `.design/DesignSystem/`에 생성해 둔 디자인 토큰을 Core/DesignSystem 모듈에 정식 배치하라.\n' +
  '1) `.design/DesignSystem/*.swift`(DSColor, DSColor+Hex, DSTypography, DSSpacing, DSShadow)를 `Core/DesignSystem/Sources/`로 이동/복사하고 모듈 타깃에 포함되게 하라(.design는 git에 남기되 SSOT는 모듈 코드).\n' +
  '2) `.design/tokens.json`을 참조해 원본값과 일치하는지 확인하고, `unresolved[]`(그라데이션 등)는 TODO로 표기.\n' +
  '3) `swiftui-designsystem` 스킬의 공통 컴포넌트(RepositoryRow=썸네일+제목+설명, EmptyStateView, ErrorStateView=재시도 버튼, LoadingFooter=페이지네이션)를 DS 토큰만 사용해 구현하라(하드코딩 색/폰트/간격 금지).\n' +
  '4) 폰트(Inter/Roboto Mono) 에셋이 없으면 시스템 폰트 폴백을 명시하고 Dynamic Type 시맨틱 매핑을 유지하라.\n' +
  '5) `swiftc -parse`로 전부 통과 확인. 배치 파일 목록과 컴포넌트 목록을 보고하라.',
  { agentType: 'design-system-builder', label: 'design-system', phase: 'DesignSystem', model: 'sonnet' }
)
await diagramFor('design-system', 'DesignSystem', '토큰(Color/Type/Spacing/Shadow)→공통 컴포넌트(RepositoryRow/Empty/Error/LoadingFooter)')
await commitPush('design-system', 'DesignSystem')

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
await diagramFor('core', 'Core', 'Client(Repository/RecentSearch)·Model·UseCase 관계, SearchError 변환')
await commitPush('core', 'Core')

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
await diagramFor('features', 'Features', '런타임 흐름 sequenceDiagram(검색 입력→디바운스→API→결과→WebView) + ViewState 상태머신')
await commitPush('features', 'Features')

// ── Phase 4: Review (화면별 리뷰 → 적대적 검증) ──────────────────
phase('Review')
const reviews = await parallel(
  SCREENS.map(s => () => agent(
    `Features/${s.key} 의 Feature/View/Test를 CLAUDE.md 컨벤션·버그·접근성 관점으로 리뷰하라. file:line 근거와 심각도(blocker/warning/nit)로.`,
    { agentType: 'swift-reviewer', label: `review:${s.key}`, phase: 'Review', model: 'opus' }
  ))
)
await diagramFor('review', 'Review', '화면별 발견사항 심각도 분포(blocker/warning/nit)')
await commitPush('review', 'Review')

// ── Phase 5: Verify ──────────────────────────────────────────────
phase('Verify')
const verify = await agent(
  'tuist install && tuist generate --no-open && tuist test 를 실행하고 통과/실패를 요약하라. 실패 시 파일:라인:사유를 추출하라.',
  { agentType: 'tuist-scaffolder', label: 'verify', phase: 'Verify', model: 'sonnet' }
)
await diagramFor('verify', 'Verify', '빌드·테스트 상태 전이(stateDiagram-v2)')
await commitPush('verify', 'Verify')

// ── Phase 6: Device Verify (실기기 — 사람 게이트) ────────────────
phase('DeviceVerify')
const deviceVerify = await agent(
  '연결된 실기기를 대상으로 검증을 준비하라. 1) `xcrun xctrace list devices` 또는 `xcrun devicectl list devices`로 연결 기기 확인 2) `tuist build` 후 device용 빌드/설치 명령(xcodebuild -destination "platform=iOS,name=<device>")을 시도 3) 실행 후 사람이 직접 확인할 수동 QA 체크리스트를 출력하라. 체크리스트는 과제 요구사항(검색·최근검색어 10개/내림차순/삭제/영속성/자동완성, 결과 리스트·총개수·WebView·페이지네이션·로딩)과 접근성(VoiceOver·Dynamic Type·다크모드)을 항목화한다. 실기기가 없으면 그 사실을 명시하고 시뮬레이터 폴백 절차를 안내하라. 추측으로 PASS 판정하지 말 것 — 최종 합격은 사람이 결정한다.',
  { agentType: 'tuist-scaffolder', label: 'device-verify', phase: 'DeviceVerify', model: 'sonnet' }
)
await diagramFor('device-verify', 'DeviceVerify', '실기기 빌드·설치·수동 QA 상태 전이 + 전체 파이프라인 개요', true)
await commitPush('device-verify', 'DeviceVerify')

return {
  scaffold,
  designSystem,
  core: core.filter(Boolean),
  screens: built.filter(Boolean),
  reviews: reviews.filter(Boolean),
  verify,
  deviceVerify,
}
