//
//  TaskEdition.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 29.01.2025.
//

import Foundation

// MARK: - presents task options like editing, sharing and removing

enum TaskEditionRequestCollection {
    case edit
    case share
    case remove
}

struct TaskEdition {
    let text: String
    let imageName: String
    let type: TaskEditionRequestCollection
    
    static func getTaskEditionCase() -> [TaskEdition] {
        [
            TaskEdition(text: "Редактировать", imageName: "square.and.pencil", type: .edit),
            TaskEdition(text: "Поделиться", imageName: "square.and.arrow.up", type: .share),
            TaskEdition(text: "Удалить", imageName: "trash", type: .remove)
        ]
    }
}
