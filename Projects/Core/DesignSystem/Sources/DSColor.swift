import SwiftUI

public enum DSColor {

    public enum Red {
        public static let s50 = Color(hex: "#ffebea")
        public static let s100 = Color(hex: "#ffc2bf")
        public static let s200 = Color(hex: "#ffa5a0")
        public static let s300 = Color(hex: "#ff7c74")
        public static let s400 = Color(hex: "#ff6259")
        public static let s500 = Color(hex: "#ff3b30")
        public static let s600 = Color(hex: "#e8362c")
        public static let s700 = Color(hex: "#b52a22")
        public static let s800 = Color(hex: "#8c201a")
        public static let s900 = Color(hex: "#6b1914")
    }

    public enum Orange {
        public static let s50 = Color(hex: "#fff4e6")
        public static let s100 = Color(hex: "#ffdeb0")
        public static let s200 = Color(hex: "#ffce8a")
        public static let s300 = Color(hex: "#ffb854")
        public static let s400 = Color(hex: "#ffaa33")
        public static let s500 = Color(hex: "#ff9500")
        public static let s600 = Color(hex: "#e88800")
        public static let s700 = Color(hex: "#b56a00")
        public static let s800 = Color(hex: "#8c5200")
        public static let s900 = Color(hex: "#6b3f00")
    }

    public enum Yellow {
        public static let s50 = Color(hex: "#fffae6")
        public static let s100 = Color(hex: "#ffefb0")
        public static let s200 = Color(hex: "#ffe88a")
        public static let s300 = Color(hex: "#ffdd54")
        public static let s400 = Color(hex: "#ffd633")
        public static let s500 = Color(hex: "#ffcc00")
        public static let s600 = Color(hex: "#e8ba00")
        public static let s700 = Color(hex: "#b59100")
        public static let s800 = Color(hex: "#8c7000")
        public static let s900 = Color(hex: "#6b5600")
    }

    public enum Green {
        public static let s50 = Color(hex: "#ebf9ee")
        public static let s100 = Color(hex: "#c0eecc")
        public static let s200 = Color(hex: "#a2e5b3")
        public static let s300 = Color(hex: "#77d990")
        public static let s400 = Color(hex: "#5dd27a")
        public static let s500 = Color(hex: "#34c759")
        public static let s600 = Color(hex: "#2fb551")
        public static let s700 = Color(hex: "#258d3f")
        public static let s800 = Color(hex: "#1d6d31")
        public static let s900 = Color(hex: "#165425")
    }

    public enum Mint {
        public static let s50 = Color(hex: "#e6f9f9")
        public static let s100 = Color(hex: "#b0eeeb")
        public static let s200 = Color(hex: "#8ae5e1")
        public static let s300 = Color(hex: "#54d9d3")
        public static let s400 = Color(hex: "#33d2cb")
        public static let s500 = Color(hex: "#00c7be")
        public static let s600 = Color(hex: "#00b5ad")
        public static let s700 = Color(hex: "#008d87")
        public static let s800 = Color(hex: "#006d69")
        public static let s900 = Color(hex: "#005450")
    }

    public enum Teal {
        public static let s50 = Color(hex: "#eaf7f9")
        public static let s100 = Color(hex: "#bfe7ee")
        public static let s200 = Color(hex: "#a0dbe5")
        public static let s300 = Color(hex: "#74cad9")
        public static let s400 = Color(hex: "#59c0d2")
        public static let s500 = Color(hex: "#30b0c7")
        public static let s600 = Color(hex: "#2ca0b5")
        public static let s700 = Color(hex: "#227d8d")
        public static let s800 = Color(hex: "#1a616d")
        public static let s900 = Color(hex: "#144a54")
    }

    public enum Cyan {
        public static let s50 = Color(hex: "#ebf7fd")
        public static let s100 = Color(hex: "#bfe6f7")
        public static let s200 = Color(hex: "#a1d9f4")
        public static let s300 = Color(hex: "#76c8ee")
        public static let s400 = Color(hex: "#5bbdeb")
        public static let s500 = Color(hex: "#32ade6")
        public static let s600 = Color(hex: "#2e9dd1")
        public static let s700 = Color(hex: "#247ba3")
        public static let s800 = Color(hex: "#1c5f7f")
        public static let s900 = Color(hex: "#154961")
    }

    public enum Blue {
        public static let s50 = Color(hex: "#e6f2ff")
        public static let s100 = Color(hex: "#b0d6ff")
        public static let s200 = Color(hex: "#8ac2ff")
        public static let s300 = Color(hex: "#54a6ff")
        public static let s400 = Color(hex: "#3395ff")
        public static let s500 = Color(hex: "#007aff")
        public static let s600 = Color(hex: "#006fe8")
        public static let s700 = Color(hex: "#0057b5")
        public static let s800 = Color(hex: "#00438c")
        public static let s900 = Color(hex: "#00336b")
    }

    public enum Indigo {
        public static let s50 = Color(hex: "#eeeefb")
        public static let s100 = Color(hex: "#cbcbf2")
        public static let s200 = Color(hex: "#b2b1ec")
        public static let s300 = Color(hex: "#8f8ee4")
        public static let s400 = Color(hex: "#7978de")
        public static let s500 = Color(hex: "#5856d6")
        public static let s600 = Color(hex: "#504ec3")
        public static let s700 = Color(hex: "#3e3d98")
        public static let s800 = Color(hex: "#302f76")
        public static let s900 = Color(hex: "#25245a")
    }

    public enum Purple {
        public static let s50 = Color(hex: "#f7eefc")
        public static let s100 = Color(hex: "#e6c9f5")
        public static let s200 = Color(hex: "#daaff0")
        public static let s300 = Color(hex: "#c98be9")
        public static let s400 = Color(hex: "#bf75e5")
        public static let s500 = Color(hex: "#af52de")
        public static let s600 = Color(hex: "#9f4bca")
        public static let s700 = Color(hex: "#7c3a9e")
        public static let s800 = Color(hex: "#602d7a")
        public static let s900 = Color(hex: "#4a225d")
    }

    public enum Neutral {
        public static let sN0 = Color(hex: "#ffffff")
        public static let sN10 = Color(hex: "#fafbfb")
        public static let sN20 = Color(hex: "#f5f6f7")
        public static let sN30 = Color(hex: "#ebedf0")
        public static let sN40 = Color(hex: "#dfe2e6")
        public static let sN50 = Color(hex: "#c2c7d0")
        public static let sN60 = Color(hex: "#b3b9c4")
        public static let sN70 = Color(hex: "#a6aebb")
        public static let sN80 = Color(hex: "#98a1b0")
        public static let sN90 = Color(hex: "#8993a4")
        public static let sN100 = Color(hex: "#7a8699")
        public static let sN200 = Color(hex: "#6b788e")
        public static let sN300 = Color(hex: "#5d6b82")
        public static let sN400 = Color(hex: "#505f79")
        public static let sN500 = Color(hex: "#42526d")
        public static let sN600 = Color(hex: "#354764")
        public static let sN700 = Color(hex: "#243757")
        public static let sN800 = Color(hex: "#15294b")
        public static let sN900 = Color(hex: "#091e42")
    }

    public static let foregroundPrimary = Color.dsDynamic(
        light: Color(hex: "#000000", opacity: 1.0),
        dark: Color(hex: "#FFFFFF", opacity: 1.0))
    public static let foregroundSecondary = Color.dsDynamic(
        light: Color(hex: "#000000", opacity: 0.7),
        dark: Color(hex: "#FFFFFF", opacity: 0.7))
    public static let foregroundTertiary = Color.dsDynamic(
        light: Color(hex: "#000000", opacity: 0.5),
        dark: Color(hex: "#FFFFFF", opacity: 0.5))
    public static let containerBorder = Color.dsDynamic(
        light: Color(hex: "#FFFFFF", opacity: 0.1),
        dark: Color(hex: "#FFFFFF", opacity: 0.07))
    public static let containerBackground = Color.dsDynamic(
        light: Color(hex: "#ffffff"),
        dark: Color(hex: "#000000", opacity: 0.5))
}
