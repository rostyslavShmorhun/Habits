//
//  HabitStatistics.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 29.05.2022.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

extension HabitStatistics: Codable {}


