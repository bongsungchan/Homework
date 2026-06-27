# Feature 산출물 (build-app 워크플로우)

각 Phase 종료 시 `diagram-author` 에이전트가 단계 산출물을 여기에 기록한다.

```
.claude/feature/
  <phase>/
    diagram.mmd     # board-grade Mermaid (산출물 관계/흐름/상태)
    output.md       # 산출 파일·결정·TODO 요약 + 다이어그램 임베드
    diagram.png     # mmdc 설치 시 렌더 결과 (선택)
  pipeline.mmd      # 전체 파이프라인 개요 (flowchart LR)
```

단계: Scaffold · DesignSystem · Core · Features · Review · Verify · DeviceVerify
