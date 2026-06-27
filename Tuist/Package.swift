// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework,
        // 정적 라이브러리가 ComposableArchitecture·Persistence 양쪽에 중복 링크되어
        // 런타임 "Class ... implemented in both" 경고가 발생하는 것을 막기 위해
        // 공유 전이 의존성도 단일 동적 프레임워크로 통일한다.
        "IssueReporting": .framework,
        "XCTestDynamicOverlay": .framework,
        // swift-syntax C shim의 읽기 전용 module.modulemap을 프레임워크로 복사하는
        // "Copy Module Map" 스크립트 단계가, tuist generate 후 stale DerivedData 위에서
        // 재실행될 때 "cp: ... Permission denied"(PhaseScriptExecution failed)로 실패한다.
        // 프레임워크가 아닌 정적 라이브러리로 빌드하면 해당 복사 스크립트 자체가 생성되지 않는다.
        // (매크로는 빌드타임 전용이라 정적 링크로 안전.)
        "_SwiftSyntaxCShims": .staticLibrary,
        "_SwiftLibraryPluginProviderCShims": .staticLibrary
    ],
    baseSettings: .settings(
        base: [
            "SWIFT_VERSION": "5",
            "SWIFT_STRICT_CONCURRENCY": "minimal",
            // Xcode 16 Explicitly Built Modules + SPM 매크로 플러그인 조합에서
            // generate 후 증분 빌드의 간헐적 macro/modulemap 오류를 막기 위해 비활성화.
            "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
            "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
        ]
    ),
    targetSettings: [
        "ComposableArchitecture": ["SWIFT_VERSION": "5"],
        "SwiftUINavigation": ["SWIFT_VERSION": "5"],
        "UIKitNavigation": ["SWIFT_VERSION": "5"],
        "SwiftNavigation": ["SWIFT_VERSION": "5"],
        "Perception": ["SWIFT_VERSION": "5"],
        "PerceptionCore": ["SWIFT_VERSION": "5"],
        "Dependencies": ["SWIFT_VERSION": "5"],
        "CasePaths": ["SWIFT_VERSION": "5"]
    ]
)
#endif

let package = Package(
    name: "GithubSearchDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            exact: "1.15.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-navigation",
            exact: "2.5.1"
        )
    ]
)
