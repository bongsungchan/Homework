import ProjectDescription

// MARK: - Constants

public let bundleIdPrefix = "com.kurly.githubsearch"
public let deploymentTarget: DeploymentTargets = .iOS("17.0")
public let swiftVersion: SettingValue = "5.9"

// MARK: - Module

public enum Module {
    // App
    case app

    // Features
    case featureSearch
    case featureSearchResult
    case featureRepositoryWeb

    // Domain
    case domainModels
    case domainUseCase

    // Core
    case coreNetworking
    case corePersistence
    case coreDesignSystem

    public var name: String {
        switch self {
        case .app:                  return "App"
        case .featureSearch:        return "Search"
        case .featureSearchResult:  return "SearchResult"
        case .featureRepositoryWeb: return "RepositoryWeb"
        case .domainModels:         return "Models"
        case .domainUseCase:        return "UseCase"
        case .coreNetworking:       return "Networking"
        case .corePersistence:      return "Persistence"
        case .coreDesignSystem:     return "DesignSystem"
        }
    }

    public var bundleId: String {
        "\(bundleIdPrefix).\(name.lowercased())"
    }

    public var targetDependency: TargetDependency {
        .project(target: name, path: projectPath)
    }

    var projectPath: Path {
        switch self {
        case .app:
            return "//Projects/App"
        case .featureSearch, .featureSearchResult, .featureRepositoryWeb:
            return "//Projects/Features/\(name)"
        case .domainModels, .domainUseCase:
            return "//Projects/Domain/\(name)"
        case .coreNetworking, .corePersistence, .coreDesignSystem:
            return "//Projects/Core/\(name)"
        }
    }
}

// MARK: - Project Factory

public extension Project {
    /// Feature/Core/Domain 모듈용 프레임워크 + 테스트 타겟 생성 헬퍼
    static func module(
        name: String,
        bundleId: String,
        sources: SourceFilesList = "Sources/**",
        resources: ResourceFileElements? = nil,
        dependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = []
    ) -> Project {
        let frameworkTarget = Target.target(
            name: name,
            destinations: .iOS,
            product: .framework,
            bundleId: bundleId,
            deploymentTargets: deploymentTarget,
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: .settings(
                base: [
                    "SWIFT_VERSION": swiftVersion,
                    "ENABLE_TESTABILITY": "YES"
                ]
            )
        )

        let testTarget = Target.target(
            name: "\(name)Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleId).tests",
            deploymentTargets: deploymentTarget,
            sources: "Tests/**",
            dependencies: [
                .target(name: name)
            ] + testDependencies,
            settings: .settings(
                base: ["SWIFT_VERSION": swiftVersion]
            )
        )

        return Project(
            name: name,
            targets: [frameworkTarget, testTarget]
        )
    }
}
