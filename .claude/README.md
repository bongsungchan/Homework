# Claude 기반 개발 기록 (`.claude/`)

이 디렉터리는 **GitHub 저장소 검색 앱(컬리 과제)** 을 Claude Code로 개발하면서 사용한
에이전트·스킬·커맨드·워크플로우와, 단계별 개발/검증 산출물을 담고 있다.
"무엇을, 어떻게, 어떤 순서로, 어떻게 검증하며" 만들었는지를 코드 외적으로 추적할 수 있도록
개발 하네스 자체를 저장소에 함께 커밋했다.

> 프로젝트 규칙(SSOT)은 루트 [`CLAUDE.md`](../CLAUDE.md), 요구사항은 `과제.md` 참고.

---

## 1. 개발 철학 — "사람이 설계·게이트, 에이전트가 구현"

- **단방향 파이프라인**으로 개발: `Scaffold → DesignSystem → Core → Features → Review → Verify → DeviceVerify`.
- 각 단계는 **독립 산출물**을 남기고, 다음 단계의 입력이 된다(`.claude/feature/<phase>/`).
- **모델 분배**(CLAUDE.md 정책):
  - **Opus** — 분석/계획/리뷰(아키텍처 설계, `swift-reviewer`, `/review`).
  - **Sonnet** — 신규 개발/수정(`tuist-scaffolder`, `tca-feature-builder`, `swiftui-view-builder`, `test-author` 등).
- **사람 게이트**는 마지막 실기기 검증(DeviceVerify) 한 곳 — 자동화가 끝까지 사람을 대체하지 않도록 설계.

전체 개요는 [`feature/pipeline.mmd`](feature/pipeline.mmd) / `pipeline.png` 참고.

---

## 2. 하네스 구성

### `agents/` — 역할별 서브에이전트 (8)
| 에이전트 | 모델 | 역할 |
| --- | --- | --- |
| `tuist-scaffolder` | Sonnet | Tuist 멀티모듈 매니페스트·디렉터리 골격 생성 |
| `design-system-builder` | Sonnet | Figma 추출 토큰을 DesignSystem 모듈에 배치, 공통 컴포넌트 구현 |
| `tca-feature-builder` | Sonnet | TCA Reducer(State/Action/body)·Dependency 작성 |
| `swiftui-view-builder` | Sonnet | Store 바인딩 SwiftUI View·접근성·다크모드 |
| `test-author` | Sonnet | TCA `TestStore` 기반 결정론적 테스트 |
| `swift-reviewer` | Opus | CLAUDE.md 컨벤션·버그 관점 코드 리뷰(read-only) |
| `diagram-author` | Sonnet | 단계 산출물을 board-grade Mermaid + 요약으로 문서화 |
| `assignment-grader` | — | 과제.md·예시 이미지와 구현을 대조해 차원별 채점(read-only) |

### `skills/` — 표준 절차/지식 (7)
`tuist-module`(모듈 템플릿·의존성 방향), `tca-conventions`(Reducer 표준),
`swiftui-designsystem`(시맨틱 컬러/폰트·VoiceOver·Dynamic Type),
`error-handling`(도메인 에러·ViewState·메시지 톤·재시도 UX),
`figma-tokens`(디자인 토큰 추출/매핑), `workflow-diagram`(고해상도 다이어그램 렌더 규칙),
`grading-rubric`(채점 기준).

### `commands/` — 슬래시 커맨드 (5)
`/new-feature`(Feature+View+Test 스캐폴딩), `/review`(diff 리뷰),
`/verify`(`tuist test` 게이트), `/device-verify`(실기기 QA 체크리스트), `/grade`(완성도 채점).

### `workflows/build-app.js` — 오케스트레이션
7개 Phase를 deterministic하게 순서 실행하고, **매 Phase 종료마다**
① `diagram-author`로 산출물 문서화 → ② `tuist-scaffolder`로 커밋·푸시한다.
커밋이 "WHAT 주석 차단" 훅에 걸리면 해당 Swift의 불필요 주석/헤더/MARK를 제거하고
`swiftc -parse` 통과를 확인한 뒤 재시도하도록 지시한다.

---

## 3. 개발 진행 — Phase별 기록

각 단계의 산출물은 `.claude/feature/<phase>/{diagram.mmd, diagram.png, output.md}` 에 있다.

| Phase | 다이어그램 타입 | 핵심 내용 |
| --- | --- | --- |
| **Scaffold** | flowchart TD | App→Features→Domain/Core 단방향 모듈 골격(컴파일 가능한 placeholder로 그린 유지) |
| **DesignSystem** | flowchart TD | 시맨틱 토큰(Color/Type/Spacing/Shadow) → 공통 컴포넌트 |
| **Core** | flowchart TD | Networking/Persistence 클라이언트·Domain 모델·UseCase 관계 |
| **Features** | sequenceDiagram | 검색 입력→디바운스→API→결과→WebView 흐름 |
| **Review** | — | `swift-reviewer` 다차원 리뷰 + 적대적 검증 |
| **Verify** | — | `tuist test` 게이트(전 모듈 그린) |
| **DeviceVerify** | — | 실기기 빌드·설치 + 수동 QA 체크리스트(사람 게이트) |

커밋 메시지가 `build(<phase>): ...` 규칙을 따르므로 `git log` 로 단계 진행을 그대로 추적할 수 있다.

---

## 4. 검증 (Verification)

- **빌드/테스트**: `tuist generate` 후 명명 시뮬레이터(iPhone 17 Pro)에서 `xcodebuild`로
  빌드·테스트. 전 스킴 그린을 게이트로 삼았다.
- **TCA TestStore**: Dependency를 테스트 더블로 주입해 네트워크 없이 상태 전이/효과를 결정론적으로 검증
  (검색·최근 검색어 CRUD·페이지네이션·에러 분기).
- **채점(`/grade`)**: `assignment-grader`가 빌드·테스트를 실제 실행한 근거로 차원별 점수
  (요구35/코드30/완성15/UX10/보너스10)와 리포트(`feature/grade/`)를 산출.
- **실기기/디자인 충실도**: 예시 이미지와 항목 단위 대조, 라이트/다크/큰 글씨 Preview 검증.

---

## 5. 이슈 해결 사례 (개발 중 실제 디버깅)

코드 기능뿐 아니라 **빌드/툴체인 레벨** 문제를 원인까지 규명해 근본 수정한 기록 —
면접에서 설명할 수 있는 대표 사례(상세는 해당 커밋 참조).

1. **런타임 중복 클래스 경고** (`Class ... implemented in both`)
   - 정적 라이브러리(IssueReporting/XCTestDynamicOverlay)가 두 동적 프레임워크에 중복 링크.
   - → `Tuist/Package.swift` productTypes에서 동적 `.framework`로 통일해 단일 복사본화.

2. **`tuist generate` 후 매번 Clean Build Folder 필요** (`cp: ... module.modulemap: Permission denied`)
   - swift-syntax C shim의 읽기 전용 modulemap을 프레임워크로 복사하는 "Copy Module Map" 스크립트가
     stale DerivedData 위에서 실패.
   - → C shim을 `.staticLibrary`로 빌드해 복사 스크립트 자체를 제거. + Xcode 16 Explicitly Built Modules
     비활성화로 매크로(`ComposableArchitectureMacros`) stale 오류 완화.

3. **반복되는 stale 빌드** 대비 운영 도구화
   - 루트 [`Makefile`](../Makefile): `make fresh`(reset + generate, **DerivedData 포함**) /
     `generate` / `reset` / `open` / `build` / `test`.

4. **UI 겹침** — 최근 검색 plain 리스트의 고정 섹션 헤더가 투명해 스크롤 시 행이 비쳐 보임
   → 헤더 불투명 배경 처리.

---

## 6. 메모리 / 학습

개발 중 비자명한 환경 지식(빌드 검증 우회법, 디자인 충실도 대조 원칙, 페이지네이션 prefetch 시점,
메시지·토큰 단일 소스 원칙 등)을 Claude의 영속 메모리에 누적해, 세션이 바뀌어도
같은 함정을 반복하지 않도록 했다. (메모리는 사용자 홈의 Claude 프로젝트 디렉터리에 저장되며
저장소에는 포함하지 않는다.)

---

## 7. 디렉터리 맵

```
.claude/
  README.md            # (이 문서)
  agents/              # 역할별 서브에이전트 정의 8
  skills/              # 표준 절차/지식 7
  commands/            # 슬래시 커맨드 5
  workflows/
    build-app.js       # 7-Phase 오케스트레이션
  feature/             # 단계별 산출물
    pipeline.mmd/.png  # 전체 파이프라인 개요
    <phase>/
      diagram.mmd      # board-grade Mermaid
      diagram.png      # 고해상도 렌더(가로 ≥ 2000px)
      output.md        # 산출 파일·결정·TODO 요약
    grade/             # 채점 리포트(report.md, score.json)
```
