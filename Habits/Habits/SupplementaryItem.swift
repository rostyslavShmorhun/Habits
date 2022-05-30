//
//  SupplementaryItem.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 30.05.2022.
//

import Foundation
import UIKit

//MARK: - Extensions
enum SupplementaryItemType {
    case collectionSupplementaryView
    case layoutDecorationView
}

//MARK: - Protocol
protocol SupplementaryItem {
    associatedtype ViewClass: UICollectionReusableView
    
    var itemType: SupplementaryItemType { get }
    
    var reuseIdentifier: String { get }
    var viewKind: String { get }
    var viewClass: ViewClass.Type { get }
}

//MARK: - Extensions
extension SupplementaryItem {
    func register(on collectionView: UICollectionView) {
        switch itemType {
        case .collectionSupplementaryView:
            collectionView.register(viewClass.self,
               forSupplementaryViewOfKind: viewKind,
               withReuseIdentifier: reuseIdentifier)
        case .layoutDecorationView:
            collectionView.collectionViewLayout.register(viewClass.self,
   forDecorationViewOfKind: viewKind)
        }
    }
}
