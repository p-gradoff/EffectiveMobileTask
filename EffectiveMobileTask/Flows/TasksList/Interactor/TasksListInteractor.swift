//
//  TaskListInteractor.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 27.01.2025.
//

import Foundation

// MARK: - interactor input
protocol TasksListInteractorInput: AnyObject {
    var output: TasksListInteractorOutput? { get }
    func getTasksList()
    func updateTaskCompletionStatus(by id: Int, completion: @escaping (Result<Void, CoreDataError>) -> Void)
    func removeTask(by id: Int, completion: @escaping (Result<Void, CoreDataError>) -> Void)
}

// MARK: - interactor output
protocol TasksListInteractorOutput: AnyObject {
    func sendError(with message: String, _ title: String)
    func send(_ tasksList: [Task])
}

// MARK: - manages requests between presenter, network manager and store manager
final class TasksListInteractor {
    
    // MARK: - output is presenter
    weak var output: TasksListInteractorOutput?
    
    // MARK: - private properties
    private let networkManager: NetworkManagerOutput
    private let storeManager: StoreManagerOutput
    private var isInitialLaunch: Bool {
        // MARK: - check if first program launch
        LaunchManager.isInitialLaunch()
    }
    private var isLoading = false
    
    // MARK: - init
    init(networkManager: NetworkManagerOutput, storeManager: StoreManagerOutput) {
        self.networkManager = networkManager
        self.storeManager = storeManager
    }
    
    // MARK: - private funcs-handlers
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
            output?.sendError(with: error.localizedDescription, Errors.coreData.value)
        case let error as NetworkError:
            output?.sendError(with: error.localizedDescription, Errors.network.value)
        default:
            output?.sendError(with: error.localizedDescription, Errors.basic.value)
        }
    }
}

// MARK: - funcs to work with store and network managers
extension TasksListInteractor {
    
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
    
    // MARK: - send request to network manager to download raw tasks list
    func downloadRawTasksList(completion: @escaping (Result<RawTasksList, NetworkError>) -> Void) {
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
        // MARK: - download raw tasks list
        downloadRawTasksList { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let rawTasksList):
                // MARK: - save loaded tasks list
                saveLoadedTaskList(rawTasksList.todos) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        // MARK: load tasks list from storage
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
}

// MARK: - input funcs
extension TasksListInteractor: TasksListInteractorInput {
    
    // MARK: - check initial launch and load tasks from storage or from internet
    func getTasksList() {
        guard !isLoading else { return }
        isLoading = true
        
        if isInitialLaunch {
            downloadAndProcessTasks()
            isLoading = false
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
