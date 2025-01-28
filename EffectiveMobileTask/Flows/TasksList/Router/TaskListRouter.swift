//
//  TaskListRouter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation
import UIKit

// MARK: - router input
protocol TaskListRouterInput: AnyObject {
    func openSelectedTaskCell(by id: Int)
    func openTaskEditor(by id: Int?)
}

// MARK: - manages modules
final class TaskListRouter: TaskListRouterInput {
    
    // MARK: - parent view controller
    weak var rootViewController: UIViewController?
    
    // MARK: - present selected task by ID
    func openSelectedTaskCell(by id: Int) {
        //
    }
    
    // MARK: - open task creator it new task or editor if task exists
    func openTaskEditor(by id: Int?) {
        //
    }
    
    
}
