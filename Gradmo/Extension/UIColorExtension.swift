//
//  UIColorExtension.swift
//  Gradmo
//

import UIKit

extension UIColor {

    // MARK: - Hex Initializer
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: CGFloat
        switch hexSanitized.count {
        case 6:
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255
            g = CGFloat((rgb & 0x00FF00) >> 8)  / 255
            b = CGFloat(rgb & 0x0000FF)          / 255
            a = 1.0
        case 8:
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
            b = CGFloat((rgb & 0x0000FF00) >> 8)  / 255
            a = CGFloat(rgb & 0x000000FF)          / 255
        default:
            r = 1; g = 1; b = 1; a = 1
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Gradient Border Color
    /// Returns the default gradient border color used for OTP fields and bordered components.
    static func gradientBorderColor() -> UIColor {
        return UIColor(hex: "#4A90E2")
    }
}
