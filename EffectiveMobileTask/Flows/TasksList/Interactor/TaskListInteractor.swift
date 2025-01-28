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
    func send(_ tasksList: [Task])
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
    private var isLoading = false
    
    // MARK: - init
    init(networkManager: NetworkManagerOutput, storeManager: StoreManager) {
        self.networkManager = networkManager
        self.storeManager = storeManager
    }
    
    // MARK: - send request to create Task entity and save it
    func saveLoadedTaskList(_ list: [RawTask], completion: @escaping (Result<Void, CoreDataError>) -> Void) {
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
                                completion(.failure(error))
                            }
                        }
                    }
                }
            }
        }
        
        // MARK: - notify main that everything's alright
        group.notify(queue: .main) {
            if savingError == nil, !isCompletionCalled {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - send request to fetch all tasks from storage
    func loadTasksListFromStorage(completion: @escaping (Result<[Task], CoreDataError>) -> Void) {
        storeManager.fetchTaskList { result in
            completion(result)
        }
    }
    
    // MARK: - handles result and sends it or handles error
    private func handleLoadResult(_ result: Result<[Task], CoreDataError>) {
        switch result {
        case .success(let tasksList):
            output?.send(tasksList)
        case .failure(let error):
            handleError(error)
        }
    }
    
    // MARK: - manages errors and send them
    private func handleError(_ error: Error) {
        switch error {
        case let error as CoreDataError:
            output?.sendError(withMessage: error.localizedDescription, title: Errors.coreData.value)
        case let error as NetworkError:
            output?.sendError(withMessage: error.localizedDescription, title: Errors.network.value)
        default:
            output?.sendError(withMessage: error.localizedDescription, title: Errors.basic.value)
        }
    }
    
    // MARK: - send request to network manager to download raw tasks list
    func downloadRawTasksList(completion: @escaping (Result<RawTaskList, NetworkError>) -> Void) {
        networkManager.doRequest { result in
            switch result {
            case .success(let rawTasksList):
                completion(.success(rawTasksList))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - download tasks from internet, save them and send
    func downloadAndProcessTasks() {
        downloadRawTasksList { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let rawTasksList):
                saveLoadedTaskList(rawTasksList.todos) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        self.loadTasksListFromStorage { [weak self] result in
                            guard let self = self else { return }
                            
                            self.handleLoadResult(result)
                        }
                    case .failure(let error):
                        self.handleError(error)
                    }
                }
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    // MARK: - check initial launch and load tasks from storage or from internet
    func getTasksList() {
        guard !isLoading else { return }
        isLoading = true
        
        if isInitialLaunch {
            downloadAndProcessTasks()
        } else {
            loadTasksListFromStorage { [weak self] result in
                guard let self = self else { return }
                
                isLoading = false
                handleLoadResult(result)
            }
        }
    }
    
    // MARK: - send request to update task completion status
    func updateTaskCompletionStatus(by id: Int, completion: @escaping (Result<Void, CoreDataError>) -> Void) {
        storeManager.updateTask(with: .completionStatus, by: id) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - send request to remove task by ID
    func removeTask(by id: Int, completion: @escaping (Result<Void, CoreDataError>) -> Void) {
        storeManager.removeTask(by: id) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
