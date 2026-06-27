import XCTest
import SwiftUI
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {
    func test_colorTokensExist() {
        // Color 토큰이 컴파일되면 통과
        _ = Color.dsBackground
        _ = Color.dsPrimaryText
        _ = Color.dsAccent
    }
}
