import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "App",
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "\(bundleIdPrefix).app",
            deploymentTargets: deploymentTarget,
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": .dictionary([:]),
                "CFBundleDisplayName": "GithubSearch"
            ]),
            sources: "Sources/**",
            dependencies: [
                Module.featureSearch.targetDependency,
                Module.featureSearchResult.targetDependency,
                Module.featureRepositoryWeb.targetDependency,
                .external(name: "ComposableArchitecture")
            ],
            settings: .settings(
                base: ["SWIFT_VERSION": swiftVersion]
            )
        ),
        .target(
            name: "AppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleIdPrefix).app.tests",
            deploymentTargets: deploymentTarget,
            sources: "Tests/**",
            dependencies: [
                .target(name: "App")
            ],
            settings: .settings(
                base: ["SWIFT_VERSION": swiftVersion]
            )
        )
    ]
)
