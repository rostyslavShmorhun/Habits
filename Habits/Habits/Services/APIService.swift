//
//  APIService.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 28.05.2022.
//

import Foundation


struct HabitRequest: APIRequest {
    typealias Response = [String: Habit]
    
    var habitName: String?
    var path: String {"/habits"}
}

struct UserRequest: APIRequest {
    typealias Response = [String: User]
    
    var path: String {"/users"}
}

struct HabitStatisticsRequest: APIRequest {
    typealias Response = [HabitStatistics]
    
    var habitName: [String]?
    var path: String { "/habitStats"}
    
    var queryItems: [URLQueryItem]? {
        if let habitName = habitName {
            return [URLQueryItem(name: "names", value: habitName.joined(separator: ","))]
        }else {
            return nil
        }
    }
}
