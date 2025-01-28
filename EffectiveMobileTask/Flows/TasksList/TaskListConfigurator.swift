//
//  TaskListConfigurator.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation
import UIKit

// MARK: - configures the whole module
final class TaskListConfigurator {
    static func configureTaskListModule() -> UIViewController {
        let networkManager = NetworkManager(urlSession: URLSession.shared)
        let storeManager = StoreManager(
            backgroundContext: CoreDataManager.shared.backgroundContext,
            mainContext: CoreDataManager.shared.mainContext
        )
        
        let view = TaskListView()
        let router = TaskListRouter()
        let interactor = TaskListInteractor(networkManager: networkManager, storeManager: storeManager)
        let presenter = TaskListPresenter(interactor: interactor, view: view, router: router)
        
        view.output = presenter
        interactor.output = presenter
        
        return view
    }
}
