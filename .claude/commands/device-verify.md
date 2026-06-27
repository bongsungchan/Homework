---
description: 실기기에 빌드·설치하고 수동 QA 체크리스트로 요구사항을 검증 (사람 게이트)
model: sonnet
---

연결된 실기기를 대상으로 검증한다. 자동 판정 금지 — 최종 합격은 사람이 결정한다.

## 절차
1. 연결 기기 확인: `xcrun devicectl list devices` (또는 `xcrun xctrace list devices`)
2. 기기 빌드: `tuist generate --no-open && xcodebuild -scheme App -destination "platform=iOS,name=<device>" build`
3. 설치·실행: `xcrun devicectl device install app --device <udid> <path>.app` 후 실행
4. 기기가 없으면 명시하고 시뮬레이터(`platform=iOS Simulator,name=iPhone 15`) 폴백 안내.

## 수동 QA 체크리스트 (사람이 직접 확인)
### 검색 화면
- [ ] 검색어 입력 → 결과 화면 전이
- [ ] 빈 검색어 시 최근 검색어 최대 10개·날짜 내림차순
- [ ] 최근 검색어 개별 삭제 / 전체 삭제
- [ ] 앱 강제종료 후 재실행 시 최근 검색 유지 (영속성)
- [ ] 최근 검색어 선택 시 검색 실행
- [ ] 입력 중 자동완성 + 검색 날짜 노출

### 검색 결과 화면
- [ ] 총 검색 결과 수 표시
- [ ] 셀: 썸네일(avatar)/제목(name)/설명(owner.login)
- [ ] 셀 선택 시 WebView로 저장소 이동
- [ ] 스크롤 중 다음 페이지 prefetch + 로딩 인디케이터
- [ ] 페이지 실패 시 인라인 재시도

### 품질
- [ ] 네트워크 끊김/rate limit 시 에러 메시지 + 재시도 동작
- [ ] VoiceOver 라벨, Dynamic Type 확대, 다크모드 정상
- [ ] 회전/세이프에어리어/노치 레이아웃 깨짐 없음

## 결과 보고
각 항목 PASS/FAIL과 재현 노트를 표로 정리하고, FAIL은 수정 트랙(`/review` 또는 feature 재구현)으로 연결한다.
