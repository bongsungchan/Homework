## GithubSearch — Tuist 프로젝트 관리 Makefile
##
## 자주 쓰는 명령:
##   make generate   : 의존성 설치 + 프로젝트 생성 (가장 자주 사용)
##   make reset      : Tuist 캐시·생성물·Xcode DerivedData 까지 모두 정리
##   make fresh      : reset 후 generate (완전 초기화 + 재생성, 빌드 꼬일 때)
##   make open       : 생성된 워크스페이스 열기
##
## stale 매크로 플러그인("ComposableArchitectureMacros produced malformed response")이나
## 읽기 전용 modulemap 으로 빌드가 깨지면 `make fresh` 한 번이면 해소된다.

WORKSPACE     := GithubSearch.xcworkspace
SCHEME        := GithubSearch-Workspace
DESTINATION   := platform=iOS Simulator,name=iPhone 17 Pro
DERIVED_DATA  := $(HOME)/Library/Developer/Xcode/DerivedData

.PHONY: install generate clean nuke-dd reset fresh open build test

## 의존성 설치
install:
	tuist install

## 의존성 설치 + 프로젝트 생성
generate: install
	tuist generate --no-open

## Tuist 생성물 제거
clean:
	rm -rf *.xcworkspace
	rm -rf Projects/**/*.xcodeproj
	rm -rf Projects/**/**/*.xcodeproj
	rm -rf Projects/**/Derived
	rm -rf Projects/**/**/Derived

## 이 프로젝트의 Xcode DerivedData 제거 (읽기 전용 파일 대비 chmod 선행)
nuke-dd:
	@find "$(DERIVED_DATA)" -maxdepth 1 -name 'GithubSearch-*' -exec chmod -R u+w {} + 2>/dev/null || true
	@rm -rf "$(DERIVED_DATA)"/GithubSearch-* 2>/dev/null || true
	@echo "✓ Xcode DerivedData(GithubSearch-*) 삭제됨"

## Tuist 캐시 + Package.resolved + 생성물 + DerivedData 전부 정리
reset: nuke-dd
	tuist clean
	@if [ -e ./Tuist/Package.resolved ]; then rm Tuist/Package.resolved; fi
	$(MAKE) clean
	@echo "✓ reset 완료 — 이어서 'make generate' 또는 'make fresh' 실행"

## 완전 초기화 후 재생성 (빌드가 꼬였을 때 권장)
fresh: reset generate
	@echo "✓ fresh 완료 — Xcode 에서 다시 빌드하세요"

## 워크스페이스 열기
open:
	open $(WORKSPACE)

## 커맨드라인 빌드 (검증용)
build:
	xcodebuild build -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)'

## 전체 테스트
test:
	xcodebuild test -workspace $(WORKSPACE) -scheme $(SCHEME) -destination '$(DESTINATION)'
