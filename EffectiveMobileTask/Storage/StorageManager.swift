//
//  StorageManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation
import CoreData

// MARK: - This enum represents possible changes to the task
enum TaskChange {
    case completionStatus
    case content(title: String, content: String)
}

// MARK: - This enum allows to receive data in filtered form
enum TaskParameter {
    case name
    case creationDate
    case id
}

extension TaskParameter {
    var value: String {
        switch self {
        case .name: return "Task"
        case .creationDate: return "creationDate"
        case .id: return "id"
        }
    }
}

enum CoreDataError: Error {
    case creationError
    case fetchError
    case taskNotFound
    case updateError
    case removeError
}

// MARK: - CoreData manager that controls access to the storage
final class StorageManager {
    // MARK: - singletone
    static let shared = StorageManager()
    private init() { }
    
    private let persistentContainer: NSPersistentContainer = {
        $0.loadPersistentStores { description, error in
            if error != nil { print("CoreData initialization error: \(error!.localizedDescription)") }
        }
        return $0
    }(NSPersistentContainer(name: TaskParameter.name.value))
    
    // MARK: - new task creation
    func createTask(
        with id: Int,
        creationDate: String,
        content: String,
        completionStatus: Bool,
        completion: ((Result<Void, CoreDataError>) -> Void)? = nil
    ) {
        persistentContainer.performBackgroundTask { (context) in
            do {
                guard let taskDescription = NSEntityDescription.entity(
                    forEntityName: TaskParameter.name.value,
                    in: context
                ) else {
                    throw CoreDataError.creationError
                }
                
                let task = Task(entity: taskDescription, insertInto: context)
                task.setupTask(id: id, creationDate: creationDate, content: content, completionStatus: completionStatus
                )
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                context.rollback()
                
                DispatchQueue.main.async {
                    completion?(.failure(.creationError))
                }
            }
        }
    }
    
    // MARK: - fetch the task by id
    func fetchTask(by id: Int, completion: @escaping ((Result<Task, CoreDataError>) -> Void)) {
        persistentContainer.performBackgroundTask { (context) in
            let fetchRequest = NSFetchRequest<Task>(entityName: TaskParameter.name.value)
            let predicate = NSPredicate(format: "\(TaskParameter.id.value) == %d", id)
            fetchRequest.predicate = predicate
            
            do {
                guard let task = (try context.fetch(fetchRequest)).first else {
                    DispatchQueue.main.async {
                        completion(.failure(.taskNotFound))
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fetchError))
                }
            }
        }
    }
    
    // MARK: - fetch task list and sort it by creation date
    func fetchTaskList(completion: @escaping ((Result<[Task], CoreDataError>) -> Void)) {
        persistentContainer.performBackgroundTask { (context) in
            do {
                let fetchRequest = NSFetchRequest<Task>(entityName: TaskParameter.name.value)
                let idSortDescriptor = NSSortDescriptor(key: TaskParameter.id.value, ascending: false)
                let creationDateSortDescriptor = NSSortDescriptor(key: TaskParameter.creationDate.value, ascending: false)
                fetchRequest.sortDescriptors = [creationDateSortDescriptor, idSortDescriptor]
                
                let taskList = try context.fetch(fetchRequest)
                DispatchQueue.main.async {
                    completion(.success(taskList))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.fetchError))
                }
            }
        }
    }
    
    // MARK: - update task data and save
    func updateTask(with change: TaskChange, by id: Int, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        persistentContainer.performBackgroundTask { [weak self] (context) in
            do {
                var taskToChange: Task?
                guard let self = self else { return }
                fetchTask(by: id, completion: { result in
                    switch result {
                    case .success(let task):
                        taskToChange = task
                    case .failure:
                        taskToChange = nil
                    }
                })
                
                guard let task = taskToChange else {
                    DispatchQueue.main.async {
                        completion(.failure(.taskNotFound))
                    }
                    return
                }
                
                switch change {
                case .completionStatus:
                    task.completionStatus.toggle()
                case .content(let title, let content):
                    task.title = title
                    task.content = content
                }
                try context.save()
            } catch {
                context.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.updateError))
                }
            }
        }
    }
    
    // MARK: - remove task by id
    func removeTask(by id: Int, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        persistentContainer.performBackgroundTask { [weak self] (context) in
            do {
                var taskToRemove: Task?
                guard let self = self else { return }
                fetchTask(by: id, completion: { result in
                    switch result {
                    case .success(let task):
                        taskToRemove = task
                    case .failure:
                        taskToRemove = nil
                    }
                })
                
                guard let task = taskToRemove else {
                    DispatchQueue.main.async {
                        completion(.failure(.taskNotFound))
                    }
                    return
                }
                
                context.delete(task)
                try context.save()
            } catch {
                context.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.removeError))
                }
            }
        }
    }
}
