//
//  SelectedTaskConfigurator.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation
import UIKit

// MARK: - configures the whole module
final class SelectedTaskConfigurator {
    static func configureSelectedTaskModule(by id: Int) -> UIViewController {
        let storeManager = StoreManager()
        
        let view = SelectedTaskView()
        let interactor = SelectedTaskInteractor(storeManager: storeManager)
        let presenter = SelectedTaskPresenter(view: view, interactor: interactor)
        
        view.output = presenter
        interactor.output = presenter
        
        // starts loading the task
        presenter.setTask(by: id)
        return view
    }
}
