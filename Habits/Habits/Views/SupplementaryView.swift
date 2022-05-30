//
//  SupplementaryView.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 30.05.2022.
//

import Foundation
import UIKit

enum SupplementaryView: String, CaseIterable, SupplementaryItem {
    case leaderboardSectionHeader
    case leaderboardBackground
    case followedUsersSectionHeader
    
    var reuseIdentifier: String {
        return rawValue
    }
    
    var viewKind: String {
        return rawValue
    }
    
    var viewClass: UICollectionReusableView.Type {
        switch self {
        case .leaderboardBackground:
            return SectionBackgroundView.self
        default:
            return NamedSectionHeaderView.self
        }
    }
    
    var itemType: SupplementaryItemType {
        switch self {
        case .leaderboardBackground:
            return .layoutDecorationView
        default:
            return .collectionSupplementaryView
        }
    }
}
