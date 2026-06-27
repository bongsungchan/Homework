---
name: swiftui-designsystem
description: SwiftUI 디자인 시스템·접근성·다크모드 표준 — 시맨틱 컬러/폰트, VoiceOver, Dynamic Type, 터치 영역. SwiftUI View를 작성/리뷰할 때 참조.
---

# SwiftUI 디자인 시스템 & 접근성

## 생성된 토큰 (DesignCode UI Figma 추출 — SSOT)
실제 디자인 토큰이 `.design/DesignSystem/`에 코드로 생성되어 있으며, Tuist `Core/DesignSystem` 모듈에 배치한다. **새 색/폰트/간격을 만들지 말고 아래 토큰을 사용**한다.
- `DSColor` — 팔레트(`DSColor.Blue.s500` 등 애플 시스템 컬러군) + 시맨틱(`DSColor.foregroundPrimary/Secondary/Tertiary`, `containerBorder`, `containerBackground`) 라이트/다크 자동 대응
- `DSTypography` / `Font.dsBody` 등 — Dynamic Type 시맨틱 매핑
- `DSSpacing` — `DSSpacing.xs/sm/md/lg/xl` 스케일
- `DSShadow` + `View.dsShadow(_:)` — Elevation 1/2/3 멀티레이어
- 원본 토큰값: `.design/tokens.json`. 미해결 토큰(그라데이션 등)은 `unresolved[]` 참고.
- 강조색(액션/링크/포커스 링)은 `DSColor.Blue.s500`(#007AFF) 기준.


## 색상/타이포
- 하드코딩 색상 금지 → Asset Catalog 시맨틱 컬러 또는 `Color(.systemBackground)` 등 시스템 컬러
- DesignSystem 모듈에 토큰 정의(`DSColor`, `DSFont`) 후 Feature에서 참조
- 폰트는 시맨틱(`.font(.body)`, `.headline`) 사용 → Dynamic Type 자동 대응

## 접근성 체크리스트
- [ ] Dynamic Type: 고정 사이즈 지양, 다중 줄 허용
- [ ] VoiceOver: 의미 있는 `accessibilityLabel`, 장식 이미지 `accessibilityHidden(true)`
- [ ] 저장소 셀: 라벨 = "{name}, {owner.login}"
- [ ] 터치 영역 최소 44x44pt (삭제 x 버튼)
- [ ] 명암비 WCAG AA, 색만으로 정보 전달 금지
- [ ] 로딩/에러 전환 시 상태 안내

## Preview 표준
```swift
#Preview("Light") { ContentView() }
#Preview("Dark") { ContentView().preferredColorScheme(.dark) }
#Preview("XL") { ContentView().environment(\.dynamicTypeSize, .accessibility3) }
```

## 공통 컴포넌트 (DesignSystem)
- `RepositoryRow`(썸네일+제목+설명), `EmptyStateView`, `ErrorStateView`(재시도), `LoadingFooter`(페이지네이션)
