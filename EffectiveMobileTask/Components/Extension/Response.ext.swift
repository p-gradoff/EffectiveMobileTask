//
//  Response.ext.swift
//  EffectiveMobileTask
//
//  Created by Павел Градов on 24.01.2025.
//

import Foundation

extension HTTPURLResponse {
    func isSuccess() -> Bool { statusCode >= 200 && statusCode < 300 }
}
