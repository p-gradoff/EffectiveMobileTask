//
//  TaskPageInteractor.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation

// MARK: - allows to process requests to receive and send data from the presenter and view
protocol TaskPageInteractorInput: AnyObject {
    var output: TaskPageInteractorOutput? { get }
    func getTask(by id: Int)
    func getNewTask()
    func saveChanges(from title: String, _ description: String, with id: Int)
}

protocol TaskPageInteractorOutput: AnyObject {
    func sendTask(_ task: Task)
    func sendError(with message: String, _ title: String)
}

class TaskPageInteractor {
    // MARK: - output is presenter
    weak var output: TaskPageInteractorOutput?
    
    // MARK: - private properties
    private let storeManager: StoreManagerOutput
    
    // MARK: - init
    init(storeManager: StoreManagerOutput) {
        self.storeManager = storeManager
    }
}

// MARK: - methods that allows the interactor to get information
extension TaskPageInteractor: TaskPageInteractorInput {
    
    // MARK: - sends a request to the store manager to get task by current ID
    func getTask(by id: Int) {
        storeManager.fetchTask(by: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let task):
                output?.sendTask(task)
            case .failure(let error):
                output?.sendError(with: error.localizedDescription, Errors.coreData.value)
            }
        }
    }
    
    // MARK: - sends a request to the store manager to create a task and receives it
    func getNewTask() {
        // MARK: - first - get tasksList to get last task id
        storeManager.fetchTaskList { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let tasksList):
                let newTaskID = (tasksList.first?.id ?? -1) + 1
                
                // MARK: - try to create new task
                let taskDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
                storeManager.createTask(
                    taskDescription: taskDescription,
                    with: newTaskID,
                    creationDate: Date.now.formatDate(),
                    content: "",
                    completionStatus: false) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success:
                            // MARK: - sends a request to the presenter to send task data to view
                            getTask(by: newTaskID)
                        case .failure(let error):
                            output?.sendError(with: error.localizedDescription, Errors.coreData.value)
                        }
                    }
            case .failure(let error):
                output?.sendError(with: error.localizedDescription, Errors.coreData.value)
            }
        }
    }
    
    // MARK: - sends a request to the store manager to update task's data by ID
    func saveChanges(from title: String, _ description: String, with id: Int) {
        storeManager.updateTask(with: .content(title: title, content: description), by: id) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                break
            case .failure(let error):
                output?.sendError(with: error.localizedDescription, Errors.coreData.value)
            }
        }
    }
}
