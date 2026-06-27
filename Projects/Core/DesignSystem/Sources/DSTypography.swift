import SwiftUI

public enum DSFont {
    public static let heading1 = Font.custom(DSFontFamily.sans, size: 60).weight(.semibold)
    public static let heading2 = Font.custom(DSFontFamily.sans, size: 50).weight(.semibold)
    public static let heading3 = Font.custom(DSFontFamily.sans, size: 40).weight(.semibold)
    public static let heading4 = Font.custom(DSFontFamily.sans, size: 30).weight(.semibold)
    public static let heading5 = Font.custom(DSFontFamily.sans, size: 24).weight(.semibold)

    public static let headline = Font.custom(DSFontFamily.sans, size: 20).weight(.regular)
    public static let headlineMedium = Font.custom(DSFontFamily.sans, size: 20).weight(.medium)

    public static let bodyLarge = Font.custom(DSFontFamily.sans, size: 18).weight(.regular)
    public static let bodyLargeMedium = Font.custom(DSFontFamily.sans, size: 18).weight(.medium)

    public static let body = Font.custom(DSFontFamily.sans, size: 16).weight(.regular)
    public static let bodyMedium = Font.custom(DSFontFamily.sans, size: 16).weight(.medium)

    public static let footnote = Font.custom(DSFontFamily.sans, size: 14).weight(.regular)
    public static let footnoteMedium = Font.custom(DSFontFamily.sans, size: 14).weight(.medium)

    public static let caption = Font.custom(DSFontFamily.sans, size: 13).weight(.regular)
    public static let captionMedium = Font.custom(DSFontFamily.sans, size: 13).weight(.medium)

    public static let small = Font.custom(DSFontFamily.sans, size: 12).weight(.regular)
    public static let smallMedium = Font.custom(DSFontFamily.sans, size: 12).weight(.medium)

    public static let mobileHeading1 = Font.custom(DSFontFamily.sans, size: 40).weight(.semibold)
    public static let mobileHeading2 = Font.custom(DSFontFamily.sans, size: 30).weight(.semibold)
    public static let mobileHeading3 = Font.custom(DSFontFamily.sans, size: 28).weight(.semibold)
    public static let mobileHeading4 = Font.custom(DSFontFamily.sans, size: 24).weight(.semibold)

    public static let bodyLargeMono = Font.custom(DSFontFamily.mono, size: 18).weight(.regular)
    public static let bodyMono = Font.custom(DSFontFamily.mono, size: 16).weight(.regular)
    public static let footnoteMono = Font.custom(DSFontFamily.mono, size: 14).weight(.regular)
    public static let captionMono = Font.custom(DSFontFamily.mono, size: 13).weight(.regular)
    public static let smallMono = Font.custom(DSFontFamily.mono, size: 12).weight(.regular)
}

enum DSFontFamily {
    static let sans = "Inter"
    static let mono = "Roboto Mono"
}

public extension Font {
    static var dsLargeTitle: Font { .system(.largeTitle).weight(.semibold) }
    static var dsTitle: Font { .system(.title).weight(.semibold) }
    static var dsTitle2: Font { .system(.title2).weight(.semibold) }
    static var dsHeadline: Font { .system(.headline) }
    static var dsCallout: Font { .system(.callout) }
    static var dsBody: Font { .system(.body) }
    static var dsFootnote: Font { .system(.footnote) }
    static var dsCaption: Font { .system(.caption) }
    static var dsSmall: Font { .system(.caption2) }
}
