import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.featureSearch.name,
    bundleId: Module.featureSearch.bundleId,
    dependencies: [
        Module.domainModels.targetDependency,
        Module.domainUseCase.targetDependency,
        Module.coreDesignSystem.targetDependency,
        .external(name: "ComposableArchitecture")
    ]
)
