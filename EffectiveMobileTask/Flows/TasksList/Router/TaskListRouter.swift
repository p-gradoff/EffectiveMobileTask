//
//  TaskListRouter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

protocol TaskListRouterInput: AnyObject {
    func openSelectedTaskCell(by id: Int)
    func openTaskEditor(by id: Int?)
}

final class TaskListRouter: TaskListRouterInput {
    func openSelectedTaskCell(by id: Int) {
        <#code#>
    }
    
    func openTaskEditor(by id: Int?) {
        <#code#>
    }
    
    
}
