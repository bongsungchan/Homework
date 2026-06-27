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
        // swift-syntax C shim의 module.modulemap이 읽기 전용으로 프레임워크에 복사되어
        // tuist generate 후 재빌드 시 "cp: ... Permission denied"로 실패하는 문제를 막기 위해
        // 프레임워크 대신 정적 라이브러리로 빌드한다(매크로는 빌드타임 전용이라 안전).
        "_SwiftSyntaxCShims": .staticFramework,
        "_SwiftLibraryPluginProviderCShims": .staticFramework
    ],
    baseSettings: .settings(
        base: [
            "SWIFT_VERSION": "5",
            "SWIFT_STRICT_CONCURRENCY": "minimal"
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
