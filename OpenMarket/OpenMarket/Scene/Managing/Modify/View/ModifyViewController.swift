//
//  ModifyViewController.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/25.
//

import UIKit

final class ModifyViewController: ManagingViewController {
    private let viewModel = ModifyViewModel()
    private let productDetail: ProductDetail
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpBarItems()
        setUpViewModel()
    }
    
    init(productDetail: ProductDetail) {
        self.productDetail = productDetail
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: SetUp Method

extension ModifyViewController {
    private func setUpView() {
        viewModel.setUpImages(with: productDetail.images)
        managingView.setUpView(data: productDetail)
    }
    
    private func setUpBarItems() {
        managingView.setUpBarItem(title: Constants.modifyBarItemTitle)
        managingView.navigationBarItem.leftBarButtonItem?.target = self
        managingView.navigationBarItem.leftBarButtonItem?.action = #selector(didTapCancelButton)
        
        managingView.navigationBarItem.rightBarButtonItem?.target = self
        managingView.navigationBarItem.rightBarButtonItem?.action = #selector(didTapDoneButton)
    }
    
    private func setUpViewModel() {
        viewModel.datasource = makeDataSource()
        viewModel.delegate = self
    }
}

// MARK: Objc Method

extension ModifyViewController {
    @objc private func didTapDoneButton() {
        if checkInputValidation() {
            viewModel.requestPatch(productID: productDetail.id, makeProductsModify()) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

// MARK: Validation Method

extension ModifyViewController {
    private func checkInputValidation() -> Bool {
        guard managingView.productNameTextField.text?.count ?? .zero >= 3 else {
            showAlertInputError(with: .productNameIsTooShort)
            return false
        }
        
        guard let productPrice = Int(managingView.productPriceTextField.text ?? "0") else {
            showAlertInputError(with: .productPriceIsEmpty)
            return false
        }
        
        let discountedPrice = Int(managingView.productDiscountedTextField.text ?? "0") ?? .zero
        
        guard productPrice >= discountedPrice else {
            showAlertInputError(with: .discountedPriceHigherThanPrice)
            return false
        }
        
        return true
    }
}

// MARK: Datasource

extension ModifyViewController {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<ModifyViewModel.Section, ImageInfo> {
        let dataSource = UICollectionViewDiffableDataSource<ModifyViewModel.Section, ImageInfo>(
            collectionView: managingView.collectionView,
            cellProvider: { (collectionView, indexPath, image) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProductsHorizontalCell.identifier,
                    for: indexPath) as? ProductsHorizontalCell else {
                    return UICollectionViewCell()
                }
                
                cell.updateImage(imageInfo: image)
                
                return cell
            })
        return dataSource
    }
    
    private func makeProductsModify() -> ProductsPatch {
        let productName = managingView.productNameTextField.text ?? ""
        let descriptions = managingView.productDescriptionTextView.text ?? ""
        let productPrice = Double(managingView.productPriceTextField.text ?? "0") ?? .zero
        let currency = managingView.productCurrencySegmentedControl.selectedSegmentIndex == .zero ? Currency.KRW : Currency.USD
        let discountedPrice = Double(managingView.productDiscountedTextField.text ?? "0")
        let stock = Int(managingView.productStockTextField.text ?? "0")
        let secret = "rwfkpko1fp"
        
        return ProductsPatch(name: productName,
                             descriptions: descriptions,
                             price: productPrice,
                             currency: currency,
                             discountedPrice: discountedPrice,
                             stock: stock,
                             secret: secret)
    }
}
