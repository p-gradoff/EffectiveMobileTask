//
//  TaskListConfigurator.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation
import UIKit

// MARK: - configures the whole module
final class TasksListConfigurator {
    static func configureTasksListModule() -> UIViewController {
        let networkManager = NetworkManager(urlSession: URLSession.shared)
        let storeManager = StoreManager()
        
        let view = TasksListView()
        let router = TasksListRouter()
        let interactor = TasksListInteractor(networkManager: networkManager, storeManager: storeManager)
        let presenter = TasksListPresenter(interactor: interactor, view: view, router: router)
        
        view.output = presenter
        interactor.output = presenter
        router.rootViewController = view
        
        return view
    }
}
