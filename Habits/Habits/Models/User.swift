//
//  User.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 29.05.2022.
//

import Foundation


struct User {
    //MARK: - Propeties
    let id: String
    let name: String
    let color: Color?
    let bio: String?
}

//MARK: - Extensions
extension User: Codable { }

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
extension User: Comparable {
    static func <(_ lhs: User, _ rhs: User) -> Bool {
        return lhs.name < rhs.name
    }
}
