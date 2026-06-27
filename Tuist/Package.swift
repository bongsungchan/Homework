// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework
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
