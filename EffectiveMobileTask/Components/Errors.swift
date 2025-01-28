//
//  Errors.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

enum Errors {
    case coreData
    case network
    case basic
}

extension Errors {
    var value: String {
        switch self {
        case .coreData: return "CoreData Error"
        case .network: return "Network Error"
        case .basic: return "Some Error"
        }
    }
}
