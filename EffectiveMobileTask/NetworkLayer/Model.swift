//
//  Model.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

// MARK: - network data models
struct RawTasksList: Decodable {
    let todos: [RawTask]
    let total, skip, limit: Int
}

struct RawTask: Decodable {
    var id: Int
    let todo: String
    let completed: Bool
    var userId: Int
    
    static func getRawTask() -> RawTask {
        RawTask(id: 1, todo: "Test text", completed: true, userId: 1)
    }
}
