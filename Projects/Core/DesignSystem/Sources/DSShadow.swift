import SwiftUI

public struct DSShadowLayer {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color; self.radius = radius; self.x = x; self.y = y
    }
}

public enum DSShadow: CaseIterable {
    case small
    case medium
    case large

    public var layers: [DSShadowLayer] {
        switch self {
        case .small: return [
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05), radius: 5, x: 0, y: 5),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.03), radius: 2, x: 0, y: 2),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.03), radius: 0, x: 0, y: 1),
        ]
        case .medium: return [
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.10), radius: 10, x: 0, y: 10),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05), radius: 4, x: 0, y: 4),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.05), radius: 0, x: 0, y: 1),
        ]
        case .large: return [
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.15), radius: 40, x: 0, y: 20),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.10), radius: 30, x: 0, y: 15),
            DSShadowLayer(color: Color(.sRGB, red: 0, green: 0, blue: 0, opacity: 0.10), radius: 10, x: 0, y: 5),
        ]
        }
    }
}

public extension View {
    func dsShadow(_ shadow: DSShadow) -> some View {
        var view = AnyView(self)
        for layer in shadow.layers {
            view = AnyView(view.shadow(color: layer.color, radius: layer.radius, x: layer.x, y: layer.y))
        }
        return view
    }
}
