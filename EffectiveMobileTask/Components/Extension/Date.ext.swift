//
//  Date.ext.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

// MARK: - provides string from date in type "dd/MM/yy"

extension Date {
    func formatDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: self)
    }
}
