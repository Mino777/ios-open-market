//
//  RegisterViewModel.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/24.
//
import UIKit

final class RegisterViewModel: ManagingViewModel {
    func requestPost(_ productsPost: ProductsPost, completion: @escaping () -> ()) {
        let endpoint = EndPointStorage.productsPost(productsPost)
        
        productsAPIServie.registerProduct(with: endpoint) { [weak self] result in
            switch result {
            case .success():
                completion()
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.delegate?.showAlertRequestError(with: error)
                }
            }
        }
    }
    
    func setUpDefaultImage() {
        guard let plus = UIImage(named: Constants.plus)?.pngData() else { return }
        let plusImage = ImageInfo(fileName: Constants.plus, data: plus, type: Constants.png)
        applySnapshot(image: plusImage)
    }
    
    func insert(image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        let imageInfo = ImageInfo(fileName: generateUUID(), data: data, type: Constants.jpg)
        
        DispatchQueue.main.async {
            guard let lastItem = self.snapshot?.itemIdentifiers.last else { return }
            self.snapshot?.insertItems([imageInfo], beforeItem: lastItem)
            guard let snapshot = self.snapshot else {
                return
            }
            self.datasource?.apply(snapshot)
        }
    }
    
    func removeLastImage() {
        guard let lastImage = snapshot?.itemIdentifiers.last else {
            return
        }
        snapshot?.deleteItems([lastImage])
    }
}
