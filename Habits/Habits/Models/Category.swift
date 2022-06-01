//
//  Category.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 28.05.2022.
//

import Foundation

struct Category {
    //MARK: - Properties
    let name: String
    let color: Color
}

extension Category: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Category: Codable { }
