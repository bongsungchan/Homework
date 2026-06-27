import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.corePersistence.name,
    bundleId: Module.corePersistence.bundleId,
    dependencies: [
        Module.domainModels.targetDependency,
        .external(name: "DependenciesMacros")
    ]
)
