import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: Module.coreNetworking.name,
    bundleId: Module.coreNetworking.bundleId,
    dependencies: [
        Module.domainModels.targetDependency
    ]
)
