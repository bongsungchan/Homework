---
name: tuist-module
description: 이 프로젝트의 Tuist 모듈 매니페스트 템플릿과 의존성 방향 규칙. 새 모듈을 추가하거나 스캐폴딩할 때 참조.
---

# Tuist 모듈 규칙

## 의존성 방향 (단방향)
```
App → Features → Domain, Core
Features 간 직접 의존 금지 (공통은 Domain/Core로 올림)
Core → (외부 SPM만), Domain → Core 금지 권장 (순수 모델/유스케이스)
```

## 모듈 셋
| 레이어 | 모듈 |
| --- | --- |
| App | App |
| Features | Search, SearchResult, RepositoryWeb |
| Domain | Models, UseCase |
| Core | Networking, Persistence, DesignSystem |

## 모듈 타깃 템플릿 (개념)
- 각 모듈 = `framework` 타깃 + `unitTests` 타깃
- product: `.framework`(또는 dev에서 static), bundleId `com.example.ghsearch.<module>`
- 외부 의존성: `ComposableArchitecture` (App/Features/Domain/UseCase)

## 스캐폴딩 시
- 모듈마다 컴파일 가능한 placeholder 타입 1개로 시작(빌드 그린 유지)
- `.xcodeproj`/`.xcworkspace`는 git 제외 (Tuist 생성물)
- 생성 명령: `tuist install && tuist generate`
