//
//  Errors.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

enum Errors {
    case coreData
}

extension Errors {
    var value: String {
        switch self {
        case .coreData: return "CoreData Error"
        }
    }
}
