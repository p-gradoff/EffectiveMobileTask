//
//  TaskListInteractor.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

protocol TaskListInteractorInput: AnyObject {
    var output: TaskListViewOutput? { get }
    func getTasksList()
    func updateTaskCompletionStatus(by id: Int)
    func removeTask(by id: Int)
}

protocol TaskListInteractorOutput: AnyObject {
    func sendError()
    func sendTasks(from taskList: [Task])
}

final class TaskListInteractor {
    
}
