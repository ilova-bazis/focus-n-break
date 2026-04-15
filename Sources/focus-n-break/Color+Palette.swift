import SwiftUI

extension Color {
    static let background = Color(hex: "#0E1012")
    static let surface = Color(hex: "#161A1F")
    static let surfaceElevated = Color(hex: "#1C2128")
    static let textPrimary = Color(hex: "#E7EAF0")
    static let textSecondary = Color(hex: "#9AA3B2")
    static let focusAccent = Color(hex: "#4F6BFF")
    static let breakAccent = Color(hex: "#3CCF91")
    static let warnAccent = Color(hex: "#E8B85C")
    static let border = Color(hex: "#232833")

    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexNumber: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&hexNumber)

        let red = Double((hexNumber >> 16) & 0xFF) / 255
        let green = Double((hexNumber >> 8) & 0xFF) / 255
        let blue = Double(hexNumber & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
