//
//  StoreManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 26.01.2025.
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


final class StoreManager {
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    init(backgroundContext: NSManagedObjectContext, mainContext: NSManagedObjectContext) {
        self.backgroundContext = backgroundContext
        self.mainContext = mainContext
    }
    
    func formFetchRequest(by taskID: Int) -> NSFetchRequest<Task> {
        let fetchRequest = NSFetchRequest<Task>(entityName: TaskParameter.name.value)
        fetchRequest.predicate = NSPredicate(format: "\(TaskParameter.id.value) == %d", taskID)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    func formEntityDescription(_ entityName: String, context: NSManagedObjectContext) -> NSEntityDescription? {
        guard let entityDescription = NSEntityDescription.entity(
            forEntityName: entityName,
            in: context
        ) else {
            return nil
        }
        return entityDescription
    }
    
    // MARK: - new task creation
    func createTask(
        taskDescription: NSEntityDescription?,
        with id: Int,
        creationDate: String,
        content: String,
        completionStatus: Bool,
        completion: ((Result<Void, CoreDataError>) -> Void)? = nil
    ) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            do {
                guard let taskDescription, id >= 0 else {
                    throw CoreDataError.creationError
                }
                
                let task = Task(entity: taskDescription, insertInto: backgroundContext)
                task.setupTask(id: id, creationDate: creationDate, content: content, completionStatus: completionStatus
                )
                
                try backgroundContext.save()
                
                DispatchQueue.main.async {
                    completion?(.success(()))
                }
            } catch {
                backgroundContext.rollback()
                
                DispatchQueue.main.async {
                    completion?(.failure(.creationError))
                }
            }
        }
    }
    
    // MARK: - fetch the task by id
    func fetchTask(by id: Int, completion: @escaping ((Result<Task, CoreDataError>) -> Void)) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = formFetchRequest(by: id)
            
            do {
                guard let task = (try backgroundContext.fetch(fetchRequest)).first else {
                    throw CoreDataError.taskNotFound
                }
                
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.taskNotFound))
                }
            }
        }
    }
    
    // MARK: - fetch task list and sort it by creation date
    func fetchTaskList(completion: @escaping ((Result<[Task], CoreDataError>) -> Void)) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchRequest = NSFetchRequest<Task>(entityName: TaskParameter.name.value)
                let idSortDescriptor = NSSortDescriptor(key: TaskParameter.id.value, ascending: false)
                let creationDateSortDescriptor = NSSortDescriptor(key: TaskParameter.creationDate.value, ascending: false)
                fetchRequest.sortDescriptors = [creationDateSortDescriptor, idSortDescriptor]
                
                let taskList = try backgroundContext.fetch(fetchRequest)
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
    func updateTask(with change: TaskChange, by id: Int, completion: @escaping ((Result<Task, CoreDataError>) -> Void)) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = formFetchRequest(by: id)
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                
                guard let task = tasks.first else {
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
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(.success(task))
                }
            } catch {
                backgroundContext.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.updateError))
                }
            }
        }
    }
    
    // MARK: - remove task by id
    func removeTask(by id: Int, completion: @escaping ((Result<Void, CoreDataError>) -> Void)) {
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            let fetchRequest = formFetchRequest(by: id)
            
            do {
                let tasks = try backgroundContext.fetch(fetchRequest)
                guard let task = tasks.first else {
                    DispatchQueue.main.async {
                        completion(.failure(.taskNotFound))
                    }
                    return
                }
                
                backgroundContext.delete(task)
                
                try backgroundContext.save()
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                backgroundContext.rollback()
                DispatchQueue.main.async {
                    completion(.failure(.removeError))
                }
            }
        }
    }
}
