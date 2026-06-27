---
name: workflow-diagram
description: build-app 워크플로우 각 단계의 산출물을 board-grade Mermaid 다이어그램으로 문서화하는 규칙. 단계 산출물을 시각화하거나 파이프라인 개요를 만들 때 참조.
---

# Workflow Diagram (Mermaid)

build-app 각 단계의 산출물을 읽기 좋은 결정론적 Mermaid로 문서화한다.

## 출력 위치
- 단계별: `.Codex/feature/<phase>/diagram.mmd` + 산출물 요약 `.Codex/feature/<phase>/output.md` (+ 렌더 가능 시 `diagram.png`)
- 전체 개요: `.Codex/feature/pipeline.mmd`

## 다이어그램 타입
- **파이프라인 개요**: `flowchart LR` — 단계 ≤ 7개 노드
- **단계 산출물(모듈/파일/컴포넌트 관계)**: `flowchart TD`
- **런타임 흐름(검색→결과→WebView, API 호출)**: `sequenceDiagram`
- **상태 머신(ViewState: idle/loading/loaded/empty/failed)**: `stateDiagram-v2`

## 작성 규칙 (board-grade)
- 노드 5~12개. 상세는 노드 라벨이 아니라 **다이어그램 아래 표**로.
- 노드 라벨은 2줄·줄당 ~28자 이내. decision `{...}`는 ≤10자.
- 라벨은 **도메인 언어만** — 코드 식별자(`fetchRepositories()`)·임의 약어 금지.
- 레이어별 lane(subgraph: App / Features / Domain / Core)로 그룹화, 시맨틱 색.
- happy path만 그리지 말 것 — 에러/재시도/로컬캐시(빈 검색어 시 최근검색어) 분기 포함.
- 렌더 후 라벨 클리핑·화살표 겹침 확인, 있으면 라벨 단축 또는 TD↔LR 전환 후 재렌더.

## 렌더 (mmdc 있을 때) — 고해상도 필수
PNG는 **최소 가로 2000px 이상**으로 렌더한다. `--scale`만 쓰면 다이어그램이 작을 때 저해상도(784px 등)가 되므로 **`--width`로 하한을 고정**한다.
```bash
mmdc -i .Codex/feature/<phase>/diagram.mmd \
     -o .Codex/feature/<phase>/diagram.png \
     -b white --scale 3 --width 2400
```
- 렌더 후 `sips -g pixelWidth <png>`로 가로 ≥ 2000px 확인. 미달이면 `--width`를 올려 재렌더.
- `mmdc` 미설치 시 `.mmd` 소스만 커밋하고, README에 GitHub이 ```mermaid 코드블록을 렌더함을 명시.
- `mmdc` 미설치 시 `.mmd` 소스만 커밋하고, README에 GitHub이 ```mermaid 코드블록을 렌더함을 명시.

## 단계별 권장 다이어그램
| 단계 | 타입 | 담을 내용 |
| --- | --- | --- |
| Scaffold | flowchart TD | 모듈 의존 그래프(App→Features→Domain/Core) |
| DesignSystem | flowchart TD | 토큰(Color/Type/Spacing/Shadow)→공통 컴포넌트 |
| Core | flowchart TD | Client(Repository/RecentSearch)·Model·UseCase 관계 |
| Features | sequenceDiagram | 검색 입력→디바운스→API→결과→WebView |
| Review | flowchart TD | 차원별 발견사항 심각도 분포 |
| Verify / DeviceVerify | stateDiagram-v2 | 빌드·테스트·기기검증 상태 전이 |
