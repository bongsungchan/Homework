---
name: error-handling
description: 도메인 에러 모델링, ViewState, 사용자 노출 메시지 톤, 재시도 UX 표준. 네트워크/영속성 경계와 에러 화면을 작성/리뷰할 때 참조.
---

# 에러 처리 정책

## 도메인 에러
```swift
enum SearchError: Error, Equatable {
    case network        // 연결 실패/타임아웃
    case rateLimited    // GitHub 미인증 분당 제한
    case decoding       // 응답 파싱 실패
    case empty          // 결과 0건 (에러 아닌 상태로 다뤄도 됨)
    case unknown
}
```
- 네트워크 경계에서 `URLError`/HTTP status → `SearchError`로 변환. UI는 도메인 에러만 의존.

## 화면 상태
```swift
enum ViewState: Equatable { case idle, loading, loaded, empty, failed(SearchError) }
```

## 사용자 메시지 톤 (짧고·비난 없이·행동 가능)
| 에러 | 메시지 |
| --- | --- |
| network | "인터넷 연결을 확인해 주세요." |
| rateLimited | "요청이 많아요. 잠시 후 다시 시도해 주세요." |
| decoding/unknown | "문제가 발생했어요. 다시 시도해 주세요." |
| empty | "검색 결과가 없어요." |

- 스택트레이스/기술 용어 노출 금지. 로깅은 `OSLog`(`Logger`), 민감정보 미기록.

## 재시도 UX
- 전체 실패: `ErrorStateView` + "다시 시도" 버튼 → 동일 쿼리/페이지 재요청
- 페이지네이션 실패: 리스트 하단 인라인 재시도 셀 (전체 화면 막지 않음)
