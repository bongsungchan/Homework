import ProjectDescription

// MARK: - Constants

public let bundleIdPrefix = "com.kurly.githubsearch"
public let deploymentTarget: DeploymentTargets = .iOS("17.0")
public let swiftVersion: SettingValue = "5.9"

/// 모든 타깃에 공통 적용하는 빌드 안정화 설정.
/// Xcode 16의 Explicitly Built Modules는 SPM 매크로 플러그인(TCA 등)과 조합 시
/// `tuist generate` 후 증분 빌드에서 "macro could not be found" / 읽기전용 modulemap 복사 실패 같은
/// 간헐적 오류를 유발한다. 명시적 모듈 빌드를 꺼서 매번 Clean Build Folder 하지 않아도 안정적으로 빌드되게 한다.
/// (트레이드오프: 클린 빌드가 다소 느려질 수 있으나 재현 불가한 stale 오류를 제거한다.)
public let stabilizationSettings: SettingsDictionary = [
    "SWIFT_ENABLE_EXPLICIT_MODULES": "NO",
    "CLANG_ENABLE_EXPLICIT_MODULES": "NO"
]

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
                ].merging(stabilizationSettings) { _, new in new }
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
                    .merging(stabilizationSettings) { _, new in new }
            )
        )

        return Project(
            name: name,
            targets: [frameworkTarget, testTarget]
        )
    }
}
