//
//  Task.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {

}

extension Task {

    @NSManaged public var title: String?
    @NSManaged public var creationDate: String?
    @NSManaged public var id: Int64
    @NSManaged public var completionStatus: Bool
    @NSManaged public var content: String?

}

extension Task : Identifiable {

}
