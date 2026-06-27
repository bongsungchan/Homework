---
description: TCA Feature 트라이어드(Feature + View + Test)를 한 번에 스캐폴딩한다
argument-hint: <FeatureName> (예: Search)
model: sonnet
---

`$ARGUMENTS` 이름의 TCA Feature를 생성한다. `tca-conventions`·`swiftui-designsystem`·`error-handling` 스킬을 따른다.

순서:
1. `tca-feature-builder` 에이전트로 `Features/$ARGUMENTS/Sources/Feature/$ARGUMENTSFeature.swift` 작성
2. `swiftui-view-builder` 에이전트로 `Features/$ARGUMENTS/Sources/View/$ARGUMENTSView.swift` 작성
3. `test-author` 에이전트로 `Features/$ARGUMENTS/Tests/$ARGUMENTSFeatureTests.swift` 작성

각 단계 산출 파일 경로를 보고하고, 모듈 매니페스트에 타깃이 없으면 추가를 안내한다.
