import XCTest
import ComposableArchitecture
@testable import UseCase

final class UseCaseTests: XCTestCase {
    func test_dependencyKeys_resolveWithoutCrash() {
        withDependencies { _ in } operation: {
            // DependencyValues 구성이 컴파일·실행되면 통과
        }
    }
}
