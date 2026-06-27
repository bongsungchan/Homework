---
name: figma-tokens
description: DesignCode UI Figma 디자인 시스템에서 디자인 토큰을 추출·매핑·재생성하는 절차와 규칙. 토큰을 갱신하거나 출처를 확인할 때 참조.
---

# Figma 토큰 추출 & 매핑

## 출처
- 파일: **DesignCode UI** (Community) — fileKey `KliKElNzGioIW7gQDl2kOS`
- 토큰 페이지: Colors `256:12275`, Typography `104:6331`, Spacing `345:664359`, Shadows `317:35652`
- 인증: `.env`의 `FIGMA_ACCESS_TOKEN` (커밋 금지, `.env.example`만 추적)

## 접근 방식 (중요)
- hosted Figma MCP(`mcp__figma__*`)는 이 환경에서 **차단**됨 → **REST API 사용**.
- Variables API(`/variables/local`)는 Figma 플랜 제한(403) → **노드 트리에서 직접 추출**.
- 공유 스타일 없음 → 스와치 리프 노드의 `fills[].color` + 텍스트 라벨로 매핑.

## 추출 명령 (재생성 시)
```bash
set -a && . ./.env && set +a
curl -s -H "X-Figma-Token: $FIGMA_ACCESS_TOKEN" \
  "https://api.figma.com/v1/files/KliKElNzGioIW7gQDl2kOS/nodes?ids=<NODE_ID>" \
  -o .design/raw-<name>.json
# 이후 python3로 파싱 → .design/tokens.json → SwiftUI 코드 생성
```
- 대용량 JSON(2MB+)은 Read로 통째 읽지 말고 **python3로 파싱**.

## 산출물 (SSOT 위계)
- `.design/tokens.json` — 추출 원본값 SSOT (palette, semanticLight/Dark, typography, spacing, shadows, **unresolved[]**)
- `.design/DesignSystem/*.swift` — 생성 코드 (스테이징)
- `Core/DesignSystem/Sources/*.swift` — 모듈 사용처 SSOT (Features가 import)
- `.design/raw-*.json` — 대용량 덤프, `.gitignore` 제외(재생성 가능)

## 매핑 규칙
- 팔레트: `DSColor.<Hue>.s500` (애플 시스템 컬러군, 강조색 = `Blue.s500` #007AFF)
- 시맨틱: `DSColor.foregroundPrimary/Secondary/Tertiary`, `containerBorder/Background` — 라이트/다크 코드 어댑터
- 타이포: `Font.dsBody` 등 — Dynamic Type 시맨틱 매핑
- 스페이싱: `DSSpacing.xs/sm/md/lg/xl`
- 섀도: `View.dsShadow(.elevation1/2/3)`

## 미해결 (추측 금지)
- Text Gradient·일부 Container 색은 SOLID fill 부재(그라데이션) → 코드 미생성, `unresolved[]`에 사유 기록 + `// TODO`.
- 섀도는 명시 스타일 부재 → Elevation 프레임 인스턴스에서 매핑(사유 기록).
