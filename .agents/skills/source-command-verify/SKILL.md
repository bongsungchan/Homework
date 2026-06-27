---
name: "source-command-verify"
description: "tuist test 실행 후 결과를 요약 (실패 시 원인 추출)"
---

# source-command-verify

Use this skill when the user asks to run the migrated source command `verify`.

## Command Template

빌드·테스트를 실행하고 결과를 보고한다.

1. `tuist install && tuist generate --no-open` (필요 시)
2. `tuist test` 실행
3. 결과 요약: 통과/실패 수, 실패 시 `파일:라인:사유` 추출.

실패가 있으면 수정 방향을 제안하되, 자동 수정은 사용자 승인 후 진행한다.
