//
//  AlertProtocol.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 28.01.2025.
//

import Foundation
import UIKit

// MARK: - protocol that provides access to alert controller
protocol AlertProtocol {
    func getAlertController(with message: String, title: String) -> UIAlertController
}

extension AlertProtocol {
    func getAlertController(with message: String, title: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let alertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(alertAction)
        return alertController
    }
}
