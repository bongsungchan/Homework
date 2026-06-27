---
name: "source-command-review"
description: "현재 변경(diff)을 swift-reviewer로 AGENTS.md 컨벤션·버그 관점 리뷰"
---

# source-command-review

Use this skill when the user asks to run the migrated source command `review`.

## Command Template

현재 작업 트리의 변경을 리뷰한다.

1. `git diff`(스테이지 포함)로 변경 범위 수집. git 저장소가 아니면 최근 수정 파일 대상.
2. `swift-reviewer` 에이전트에 변경 내용을 넘겨 리뷰 수행.
3. 결과를 심각도별(blocker / warning / nit)로 정리해 `file:line — 문제 — 권고` 형식으로 보고.

코드는 수정하지 않는다(리뷰만). 사용자가 요청하면 수정으로 이어간다.
