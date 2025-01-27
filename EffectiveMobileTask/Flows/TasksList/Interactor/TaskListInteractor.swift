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
    func sendError(withMessage: String, title: String)
    func sendTasks(from taskList: [Task])
}

final class TaskListInteractor {
    // MARK: - output is presenter
    weak var output: TaskListInteractorOutput?
    
    // MARK: - private properties
    private let networkManager: NetworkManagerOutput
    private let storeManager: StoreManager
    private var isInitialLaunch: Bool {
        // MARK: - check if first program launch
        LaunchManager.isInitialLaunch()
    }
    
    // MARK: - init
    init(networkManager: NetworkManagerOutput, storeManager: StoreManager) {
        self.networkManager = networkManager
        self.storeManager = storeManager
    }
    
    // MARK: - send request to create Task entity and save it
    func saveLoadedTaskList(_ list: [RawTask], completion: @escaping (CoreDataError?) -> Void) {
        // MARK: - using DispatcGroup to synchronize the result of asynchronous work
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "saveTaskQueue")
        var savingError: CoreDataError?
        var isCompletionCalled = false
        
        for task in list {
            group.enter()
            
            // MARK: - task creation process
            let entityDescription = storeManager.formEntityDescription(TaskParameter.name.value, context: storeManager.backgroundContext)
            storeManager.createTask(
                taskDescription: entityDescription,
                with: task.id,
                creationDate: Date.now.formatDate(),
                content: task.todo,
                completionStatus: task.completed
            ) { result in
                defer { group.leave() }
                
                switch result {
                case .success:
                    break
                case .failure(let error):
                    // MARK: - synchronize general vars and call the completion
                    queue.sync {
                        if savingError == nil {
                            savingError = error
                            if !isCompletionCalled {
                                isCompletionCalled.toggle()
                                completion(savingError)
                            }
                        }
                    }
                }
            }
        }
        
        // MARK: - notify main that everything's alright
        group.notify(queue: .main) {
            if savingError == nil, !isCompletionCalled {
                completion(nil)
            }
        }
    }
}
