//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Rostyslav Shmorhun on 28.05.2022.
//

import UIKit

@MainActor
class HabitCollectionViewController: UICollectionViewController {

    typealias DataSourceType =
       UICollectionViewDiffableDataSource<ViewModel.Section,
       ViewModel.Item>
    
    //MARK: - Properties
    var dataSource: DataSourceType!
    var model = Model()
    var habitsRequestTask: Task<Void, Never>? = nil
    
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case favorites
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                case (.category(let l), .category(let r)):
                    return l.name < r.name
                case (.favorites, _):
                    return true
                case (_, .favorites):
                    return false
                }
            }
        }
        typealias Item = Habit
    }
    
    enum SectionHeader: String {
        case kind = "SectionHeader"
        case reuse = "HeaderView"
        
        var indetifier: String {
            return rawValue
        }
    }
    
    //MARK: - Structures
    struct Model {
        var habitsByName = [String: Habit]()
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
        collectionView.register(NamedSectionHeaderView.self, forSupplementaryViewOfKind: SectionHeader.kind.indetifier, withReuseIdentifier: SectionHeader.reuse.indetifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let item = self.dataSource.itemIdentifier(for: indexPath)!
            
            let favoriteToggle = UIAction(title: self.model.favoriteHabits.contains(item) ? "Unfavorite" : "Favorite") {
                (action) in Settings.shared.toggleFavorite(item)
                self.updateCollectionView()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [favoriteToggle])
        }
        return config
    }
    
    //MARK: - Custom Method
    func update() {
        habitsRequestTask?.cancel()
        habitsRequestTask = Task {
            if let habits = try? await HabitRequest().send() {
                self.model.habitsByName = habits
            } else {
                self.model.habitsByName = [:]
            }
            self.updateCollectionView()
            habitsRequestTask = nil
        }
    }
    
    deinit { habitsRequestTask?.cancel() }

    func updateCollectionView() {
        var itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            
            let item = habit
            let section: ViewModel.Section
            
            if model.favoriteHabits.contains(habit) {
                section = .favorites
            } else { section = .category(habit.category) }
            
            partial[section, default: []].append(item)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted()}
        let sectionIDs = itemsBySection.keys.sorted()
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) {
           (collectionView, indexPath, item) in
            let cell =
               collectionView.dequeueReusableCell(withReuseIdentifier:
               "Habit", for: indexPath) as! UICollectionViewListCell
            
            var content = cell.defaultContentConfiguration()
            content.text = item.name
            cell.contentConfiguration = content
            
            return cell
        }
        
        dataSource.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: SectionHeader.kind.indetifier,
                                                                         withReuseIdentifier: SectionHeader.reuse.indetifier,
                                                                         for: indexPath) as! NamedSectionHeaderView
            
            let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .favorites:
                header.nameLabel.text = "Favorites"
            case .category(let category):
                header.nameLabel.text = category.name
            }
            return header
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize =
           NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                  heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: 1)
        
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .absolute(36))
        
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                        elementKind: SectionHeader.kind.indetifier,
                                                                        alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets( top: 0, leading: 10, bottom: 0, trailing: 10)
        section.boundarySupplementaryItems = [sectionHeader]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
