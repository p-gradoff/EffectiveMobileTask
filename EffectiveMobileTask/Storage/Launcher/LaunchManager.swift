//
//  LaunchManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

// MARK: - LaunchManager determines if the default task list should be loaded

struct LaunchManager {
    static let initialLaunchKey = "Initial Launch"
    
    // MARK: - The remote task list is loaded only on the initial launch
    static func isInitialLaunch() -> Bool {
        guard let _ = UserDefaults.standard.object(forKey: initialLaunchKey) else {
            UserDefaults.standard.set(false, forKey: initialLaunchKey)
            return true
        }
        return false
    }
}
