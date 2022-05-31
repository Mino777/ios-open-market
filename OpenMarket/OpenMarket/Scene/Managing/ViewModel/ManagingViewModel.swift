//
//  ManagingViewModel.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/25.
//

import UIKit

class ManagingViewModel {
    enum Constants {
        static let dotJPG = ".jpg"
        static let plus = "plus"
        static let jpg = "jpg"
        static let png = "png"
    }
    
    enum Section: CaseIterable {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageInfo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageInfo>
    
    let productsAPIServie = APIProvider()
    
    var datasource: DataSource?
    var snapshot: Snapshot?
    
    weak var delegate: ManagingAlertDelegate?
    
    func generateUUID() -> String {
        return UUID().uuidString + Constants.dotJPG
    }
    
    func makeSnapsnot() -> Snapshot? {
        var snapshot = datasource?.snapshot()
        snapshot?.deleteAllItems()
        snapshot?.appendSections(Section.allCases)
        return snapshot
    }
    
    func applySnapshot(image: ImageInfo) {
        DispatchQueue.main.async { [self] in
            snapshot?.appendItems([image])
            guard let snapshot = snapshot else { return }
            
            datasource?.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func snapshotNumberOfItems() -> Int {
        snapshot?.numberOfItems ?? .zero
    }
    
    func snapshotItem() -> [ImageInfo] {
        snapshot?.itemIdentifiers ?? []
    }
}
