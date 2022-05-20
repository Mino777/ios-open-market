//
//  MainViewModel.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/20.
//

import UIKit

protocol AlertDelegate: AnyObject {
    func showAlertRequestError(with error: Error)
    func showAlertRequestImageError(with error: Error)
}

final class MainViewModel {
    private enum Constants {
        static let itemsCountPerPage = 20
    }
    
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>
    
    private let productsAPIServie = APIProvider<Products>()
    private let imageCacheManager = ImageCacheManager()
    
    var datasource: DataSource?
    var products: Products?
    var items: [Item] = []
    var currentPage = 1
    
    weak var delegate: AlertDelegate?
    
    func requestProducts(by page: Int) {
        let endpoint = EndPointStorage.productsList(pageNumber: page, perPages: Constants.itemsCountPerPage)
        
        productsAPIServie.request(with: endpoint) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let products):
                self.products = products
                self.items.append(contentsOf: products.items)
                self.applySnapshot()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showAlertRequestError(with: error)
                }
            }
        }
    }
    
    func loadImage(url: URL, completion: @escaping (UIImage) -> Void) {
        self.imageCacheManager.loadImage(url: url) { result in
            switch result {
            case .success(let image):
                completion(image)
            case .failure(let error):
                DispatchQueue.main.async {
                    self.delegate?.showAlertRequestImageError(with: error)
                }
            }
        }
    }
    
    private func applySnapshot() {
        DispatchQueue.main.async {
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.items, toSection: .main)
            self.datasource?.apply(snapshot)
        }
    }
}
