//
//  Font.ext.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation
import UIKit

// MARK: - provides simple way to get custom font
enum FontType: String {
    case regular = "SFUIText-Regular"
    case medium = "SFUIText-Medium"
    case bold = "SFUIText-Bold"
}

extension UIFont {
    static func getFont(fontType: FontType, size: CGFloat = 16) -> UIFont {
        .init(name: fontType.rawValue, size: size) ?? .systemFont(ofSize: size)
    }
}
