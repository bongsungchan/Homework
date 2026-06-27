import SwiftUI

// MARK: - DesignSystem Colors

public extension Color {
    /// 배경 기본색 (라이트/다크 자동 대응)
    static let dsBackground = Color(.systemBackground)
    /// 보조 배경색
    static let dsSecondaryBackground = Color(.secondarySystemBackground)
    /// 기본 텍스트
    static let dsPrimaryText = Color(.label)
    /// 보조 텍스트
    static let dsSecondaryText = Color(.secondaryLabel)
    /// 강조색 (브랜드 컬러 자리)
    static let dsAccent = Color.accentColor
}
