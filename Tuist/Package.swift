// swift-tools-version: 5.9
// Tuist が依存解決に使う SPM Package manifest
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "ComposableArchitecture": .framework
    ],
    baseSettings: .settings(
        base: ["IPHONEOS_DEPLOYMENT_TARGET": "17.0"]
    )
)
#endif

let package = Package(
    name: "GithubSearchDependencies",
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.0"
        )
    ]
)
