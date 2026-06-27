import SwiftUI

public extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r, g, b, a: Double
        switch s.count {
        case 8:
            a = Double((value & 0xFF00_0000) >> 24) / 255
            r = Double((value & 0x00FF_0000) >> 16) / 255
            g = Double((value & 0x0000_FF00) >> 8) / 255
            b = Double(value & 0x0000_00FF) / 255
        default:
            a = 1
            r = Double((value & 0xFF0000) >> 16) / 255
            g = Double((value & 0x00FF00) >> 8) / 255
            b = Double(value & 0x0000FF) / 255
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a * opacity)
    }
}

#if canImport(UIKit)
import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255,
            green: CGFloat((value & 0x00FF00) >> 8) / 255,
            blue: CGFloat(value & 0x0000FF) / 255,
            alpha: alpha
        )
    }

    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
    }
}

public extension Color {
    static func dsDynamic(light: Color, dark: Color) -> Color {
        Color(UIColor.dynamic(light: UIColor(light), dark: UIColor(dark)))
    }
}
#else
public extension Color {
    static func dsDynamic(light: Color, dark: Color) -> Color { light }
}
#endif

public extension Color {
    static var dsBackground: Color { DSColor.background }
    static var dsPrimaryText: Color { DSColor.primaryText }
    static var dsSecondaryText: Color { DSColor.secondaryText }
    static var dsAccent: Color { DSColor.accent }
}
