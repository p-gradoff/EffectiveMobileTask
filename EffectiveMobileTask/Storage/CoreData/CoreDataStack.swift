//
//  CoreDataStack.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 26.01.2025.
//

import Foundation
import CoreData

// MARK: - manages unit-testing contexts
final class CoreDataStack {
    
    // MARK: - singletone
    static let shared = CoreDataStack()
    
    // MARK: - properties
    let persistentContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
    // MARK: - init
    private init() {
        persistentContainer = NSPersistentContainer(name: "EffectiveMobileTask")
        let description = persistentContainer.persistentStoreDescriptions.first
        description?.type = NSInMemoryStoreType
        
        persistentContainer.loadPersistentStores { description, error in
            guard error == nil else {
                fatalError("Unable to load store \(error!)")
            }
        }
        
        mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainContext.automaticallyMergesChangesFromParent = true
        mainContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        backgroundContext.parent = self.mainContext
    }
}
