//
//  TaskListRouter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation
import UIKit

// MARK: - router input
protocol TasksListRouterInput: AnyObject {
    func openSelectedTaskCell(by id: Int)
    func openTaskEditor(by id: Int?)
}

// MARK: - manages modules
final class TasksListRouter: TasksListRouterInput {
    
    // MARK: - parent view controller
    weak var rootViewController: UIViewController?
    
    // MARK: - present selected task by ID
    func openSelectedTaskCell(by id: Int) {
        let selectedTaskView = SelectedTaskConfigurator.configureSelectedTaskModule(by: id) as! SelectedTaskView
                
        selectedTaskView.delegate = rootViewController as? DismissDelegate
        rootViewController?.present(selectedTaskView, animated: true)
    }
    
    // MARK: - open task creator it new task or editor if task exists
    func openTaskEditor(by id: Int?) {
        //
    }
    
    
}
