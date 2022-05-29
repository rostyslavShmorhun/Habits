//
//  UserCount.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 29.05.2022.
//

import Foundation

struct UserCount {
    let user: User
    let count: Int
}

extension UserCount: Codable {}

extension UserCount: Hashable {}


