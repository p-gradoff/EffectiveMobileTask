//
//  TaskPagePresenter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation

import Foundation

// MARK: - handles requests and coordinates the work of the view and the interactor
final class TaskPagePresenter {
    
    // MARK: - private properties
    private let view: TaskPageViewInput
    private let interactor: TaskPageInteractorInput
    
    // MARK: - init
    init(view: TaskPageViewInput, interactor: TaskPageInteractorInput) {
        self.view = view
        self.interactor = interactor
    }
    
    // MARK: - initial method that allows to load or create task before view initialization
    func setTask(by id: Int?) {
        if let id {
            interactor.getTask(by: id)
        } else {
            interactor.getNewTask()
        }
    }
}

// MARK: - handles requests from the view
extension TaskPagePresenter: TaskPageViewOutput {
    // MARK: - sends a request to the interactor to update task's data by ID
    func saveChanges(from title: String, _ description: String, with id: Int) {
        interactor.saveChanges(from: title, description, with: id)
    }
}

// MARK: - handles requests from the interactor
extension TaskPagePresenter: TaskPageInteractorOutput {
    
    // MARK: - request to show alert case of error
    func sendError(with message: String, _ title: String) {
        view.presentAlertController(with: message, title)
    }
    
    // MARK: - passes task from the interactor to the view
    func sendTask(_ task: Task) {
        view.setTask(task)
    }
}
