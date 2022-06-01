//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 28.05.2022.
//

import UIKit

class UserCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    var model = Model()
    var dataSource: DataSourceType!
    var usersRequestTask: Task<Void, Never>? = nil
    
    enum ViewModel{
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(user)
            }
            
            static func ==(lhs: Item, rhs: Item) -> Bool {
                return lhs.user == rhs.user
            }
        }
    }
    
    struct Model{
        
        var usersByID = [String: User]()
        var followedUsers: [User] {
            return Array(usersByID.filter {Settings.shared.followedUserIDs.contains($0.key)}.values)
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        
        update()
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (element) -> UIMenu? in
            guard let item = self.dataSource.itemIdentifier(for: indexPath) else {return nil}
            
            let favoriteToggle = UIAction(title: item.isFollowed ? "Unfavorite" : "Favorite") {
                (action) in Settings.shared.toggleFavorite(item.user)
                self.updateCollectionView()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        return config
    }
    
    //MARK: - Custom methods
    func update() {
        usersRequestTask?.cancel()
        usersRequestTask = Task {
            if let users = try? await UserRequest().send() {
                self.model.usersByID = users
            } else {
                self.model.usersByID = [:]
            }
            self.updateCollectionView()
            
            usersRequestTask = nil
        }
    }
    
    deinit { usersRequestTask?.cancel() }
    
    func updateCollectionView() {
        let users = model.usersByID.values.sorted().reduce(into: [ViewModel.Item]())
        { partial, user in
            partial.append(ViewModel.Item(user: user,
                                          isFollowed:
                                            model.followedUsers.contains(user)))
        }
        let itemsBySection = [0: users]
        
        dataSource.applySnapshotUsing(sectionIDs: [0],
                                      itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) {
            (collectionView, indexPath, item) in
            let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier:
                                                "User", for: indexPath) as! UICollectionViewListCell
            
            var backgroundConfiguration = UIBackgroundConfiguration.clear()
            backgroundConfiguration.backgroundColor = item.user.color?.uiColor ?? UIColor.systemGray4
            var content = cell.defaultContentConfiguration()
            content.text = item.user.name
            content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 11,
                                                                       leading: 0,
                                                                       bottom: 11,
                                                                       trailing: 8)
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            cell.backgroundConfiguration = backgroundConfiguration
            
            return cell
        }
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize =
        NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                               heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets( top: 20,
                                                         leading: 20,
                                                         bottom: 20,
                                                         trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    @IBSegueAction func showUserDetail(_ coder: NSCoder, sender: UICollectionViewCell?) -> UserDetailViewController? {
        guard let cell = sender,
              let indexPath = collectionView.indexPath(for: cell),
              let item = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        return UserDetailViewController(coder: coder, user: item.user)
    }
}

