//
//  TaskListPresenter.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

// MARK: - handles requests and coordinates view and interactor
final class TaskListPresenter {
    
    // MARK: - private properties
    private let interactor: TaskListInteractorInput
    private let view: TaskListViewInput
    private let router: TaskListRouterInput
    
    // MARK: - init
    init(interactor: TaskListInteractorInput, view: TaskListViewInput, router: TaskListRouterInput) {
        self.interactor = interactor
        self.view = view
        self.router = router
    }
}

// MARK: - handles view's requests
extension TaskListPresenter: TaskListViewOutput {
    
    // MARK: - Interactor requests
    // MARK: - send requset to interactor to get tasks list
    func getTasks() {
        interactor.getTasksList()
    }
    
    // MARK: - send request to interactor update task completion status
    func changeTaskCompletionStatus(by id: Int) {
        interactor.updateTaskCompletionStatus(by: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                sendError(withMessage: error.localizedDescription, title: Errors.coreData.value)
            }
        }
    }
    
    // MARK: - send request to interactor to remove task by ID
    func removeTask(by id: Int) {
        interactor.removeTask(by: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                sendError(withMessage: error.localizedDescription, title: Errors.coreData.value)
            }
        }
    }
    
    // MARK: - Router requests
    // MARK: - send request to router to open selected task cell
    func openSelectedTaskCell(by id: Int) {
        router.openSelectedTaskCell(by: id)
    }
    
    // MARK: - send request to router to open task creator
    func createNewTask() {
        router.openTaskEditor(by: nil)
    }
    
    // MARK: - send request to router to open task editor
    func openTaskEditor(by id: Int) {
        router.openTaskEditor(by: id)
    }
}

extension TaskListPresenter: TaskListInteractorOutput {
    func sendError(withMessage: String, title: String) {
        //
    }
    
    func send(_ tasksList: [Task]) {
        view.setTableData(with: tasksList)
    }
}
