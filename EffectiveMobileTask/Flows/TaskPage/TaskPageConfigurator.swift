//
//  TaskPageConfigurator.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation
import UIKit

// MARK: - configures the whole module

final class TaskPageConfigurator {
    static func configureTaskPageModule(by id: Int?) -> UIViewController {
        let storeManager = StoreManager()
        
        let view = TaskPageView()
        let interactor = TaskPageInteractor(storeManager: storeManager)
        let presenter = TaskPagePresenter(view: view, interactor: interactor)
        
        view.output = presenter
        interactor.output = presenter
        
        // starts loading the task before the view appears
        presenter.setTask(by: id)
        return view
    }
}
