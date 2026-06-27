---
name: "source-command-grade"
description: "과제.md·예시 이미지와 구현을 대조해 코드품질·완성도·요구사항 충족도를 점수화"
---

# source-command-grade

Use this skill when the user asks to run the migrated source command `grade`.

## Command Template

`grading-rubric` 스킬 기준으로 이 저장소의 GitHub 저장소 검색 과제 구현을 채점한다.

1. `assignment-grader` 에이전트를 실행한다(read-only). 입력: `과제.md`(요구사항 SSOT), `예시 1..png`/`예시 2..png`(디자인 참고), `Projects/`(구현).
2. 에이전트는 빌드·테스트를 실제 실행한 결과를 근거로 차원별 점수(요구35/코드30/완성15/UX10/보너스10)를 매기고, `.Codex/feature/grade/report.md` + `score.json`을 생성한다.
3. 결과를 받아 **총점·차원별 점수·핵심 강점/개선점**을 요약 보고하고, 리포트 경로를 안내한다.

자동 PASS/추정 금지 — 모든 판정은 file:line 또는 png 근거 기반. 코드는 수정하지 않는다(평가만).
