import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.domainUseCase.name,
    bundleId: Module.domainUseCase.bundleId,
    dependencies: [
        Module.domainModels.targetDependency,
        Module.coreNetworking.targetDependency,
        Module.corePersistence.targetDependency,
        .external(name: "ComposableArchitecture")
    ]
)
