//
//  LoggedHabit.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 30.05.2022.
//

import Foundation

struct LoggedHabit{
    let userID: String
    let habitName: String
    let timestemp: Date
}

extension LoggedHabit: Codable {}
