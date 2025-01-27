//
//  CoreDataManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 26.01.2025.
//

import Foundation
import CoreData

// MARK: - manages StoreManager contexts
final class CoreDataManager {
    
    // MARK: - singletone
    static let shared = CoreDataManager()
    
    // MARK: - properties
    let persistantContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    
    // MARK: - init
    private init() {
        persistantContainer = NSPersistentContainer(name: "EffectiveMobileTask")
        let description = persistantContainer.persistentStoreDescriptions.first
        description?.type = NSSQLiteStoreType
        
        persistantContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("Unable to load store \(error!)")
            }
            print(description.url?.absoluteString ?? "")
        }
        mainContext = persistantContainer.viewContext
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = mainContext
    }
}
