//
//  UserStatistics.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 30.05.2022.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable {}

