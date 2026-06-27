import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.featureSearchResult.name,
    bundleId: Module.featureSearchResult.bundleId,
    dependencies: [
        Module.domainModels.targetDependency,
        Module.domainUseCase.targetDependency,
        Module.coreDesignSystem.targetDependency,
        .external(name: "ComposableArchitecture")
    ]
)
