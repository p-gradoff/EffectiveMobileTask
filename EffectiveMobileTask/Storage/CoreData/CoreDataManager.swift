//
//  CoreDataManager.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 26.01.2025.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistantContainer: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext
    let mainContext: NSManagedObjectContext
    
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
