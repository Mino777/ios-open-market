//
//  DetailViewModel.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/30.
//

import UIKit

final class DetailViewModel {
    enum Section: CaseIterable {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ImageInfo>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ImageInfo>
    
    var datasource: DataSource?
    var snapshot: Snapshot?
    
    private let productsAPIService = APIProvider()
    
    func setUpImages(with images: [ProductImage]) {
        images.forEach { image in
            requestImage(url: image.url)
        }
    }
    
    private func requestImage(url: URL) {
        productsAPIService.requestImage(with: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                self.applySnapshot(images: [ImageInfo(fileName: UUID().uuidString, data: image, type: "")])
            case .failure(let error):
                break
            }
        }
    }
    
    func requestSecret(by productID: Int, secret: ProductSecret, completion: @escaping (String) -> Void) {
        let endpoint = EndPointStorage.productsSecret(productID: productID, secret: secret)
        
        productsAPIService.retrieveSecret(with: endpoint) { [weak self] (result: Result<String, Error>) in
            switch result {
            case .success(let secret):
                completion(secret)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteProduct(by productID: Int, secret: String, completion: @escaping () -> Void) {
        let endpoint = EndPointStorage.productsDelete(productID: productID, secret: secret)
        
        productsAPIService.deleteProduct(with: endpoint) { result in
            switch result {
            case .success(_):
                completion()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func makeSnapshot() -> Snapshot? {
        var snapshot = datasource?.snapshot()
        snapshot?.deleteAllItems()
        snapshot?.appendSections(Section.allCases)
        return snapshot
    }
    
    private func applySnapshot(images: [ImageInfo]) {
        DispatchQueue.main.async {
            self.snapshot?.appendItems(images)
            guard let snapshot = self.snapshot else { return }
            self.datasource?.apply(snapshot, animatingDifferences: false)
        }
    }
}
