//
//  APIService.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 28.05.2022.
//

import Foundation
import UIKit


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

struct UserStatisticsRequest: APIRequest {
    typealias Response = [UserStatistics]
    
    var userIDs: [String]?
    var path: String {"/userStats"}
    var queryItems: [URLQueryItem]? {
        if let userIDs = userIDs {
            return [URLQueryItem(name: "ids", value: userIDs.joined(separator: ","))]
        }else{
            return nil
        }
    }
}

struct HabitLeadStatisticsRequest: APIRequest {
    typealias Response = UserStatistics
    
    var userID: String
    var path: String {"/userLeadingStats/\(userID)"}
}

struct ImageRequest: APIRequest {
    typealias Response = UIImage
    
    var imageID: String
    var path: String {"/images/" + imageID }
    
}

struct LogHabitRequest: APIRequest {
    typealias Response = Void
    var loggedHabit: LoggedHabit
    
    var path: String {"/LogHabitRequest"}
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try! encoder.encode(loggedHabit)
    }
}

struct CombinedStatisticsRequest: APIRequest {
    typealias Response = CombinedStatistics
    var path: String {"/combinedStats"}
}
