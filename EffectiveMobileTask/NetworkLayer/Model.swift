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
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
