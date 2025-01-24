//
//  Task.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject, Identifiable {
    @NSManaged public var title: String
    @NSManaged public var creationDate: String
    @NSManaged public var id: Int
    @NSManaged public var completionStatus: Bool
    @NSManaged public var content: String
    
    func setupTask(id: Int, title: String = "Task header", creationDate: String, content: String, completionStatus: Bool) {
        self.id = id
        self.title = title
        self.creationDate = creationDate
        self.content = content
        self.completionStatus = completionStatus
    }
}
