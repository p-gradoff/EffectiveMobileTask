//
//  Model.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

// MARK: - network data model

struct RawTaskList: Codable {
    let todos: [RawTask]
    let total, skip, limit: Int
}

struct RawTask: Codable {
    var id: Int
    let todo: String
    let completed: Bool
    var userId: Int
    
    static func getRawTask() -> RawTask {
        RawTask(id: 1, todo: "Test text", completed: true, userId: 1)
    }
}
