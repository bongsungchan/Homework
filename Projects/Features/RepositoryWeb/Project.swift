import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.featureRepositoryWeb.name,
    bundleId: Module.featureRepositoryWeb.bundleId,
    dependencies: [
        Module.domainModels.targetDependency,
        Module.coreDesignSystem.targetDependency,
        .external(name: "ComposableArchitecture")
    ]
)
