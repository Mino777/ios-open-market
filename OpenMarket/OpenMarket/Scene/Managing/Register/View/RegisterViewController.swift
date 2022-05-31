//
//  RegisterViewController.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/24.
//

import UIKit

final class RegisterViewController: ManagingViewController {
    private let viewModel = RegisterViewModel()
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBarItems()
        setUpViewModel()
        setUpImagePicker()
        viewModel.setUpDefaultImage()
    }
}

// MARK: SetUp Method

extension RegisterViewController {
    private func setUpBarItems() {
        managingView.setUpBarItem(title: Constants.registerBarItemTitle)
        managingView.navigationBarItem.leftBarButtonItem?.target = self
        managingView.navigationBarItem.leftBarButtonItem?.action = #selector(didTapCancelButton)
        
        managingView.navigationBarItem.rightBarButtonItem?.target = self
        managingView.navigationBarItem.rightBarButtonItem?.action = #selector(didTapDoneButton)
    }
    
    private func setUpViewModel() {
        viewModel.datasource = makeDataSource()
        viewModel.snapshot = viewModel.makeSnapsnot()
        viewModel.delegate = self
    }
    
    private func setUpImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}

// MARK: Objc Method

extension RegisterViewController {
    @objc private func didTapDoneButton() {
        if checkInputValidation() {
            viewModel.removeLastImage()
            viewModel.requestPost(makeProductsPost()) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

// MARK: Validation Method

extension RegisterViewController {
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
        
        guard viewModel.snapshotNumberOfItems() >= 2 else {
            showAlertInputError(with: .productImageIsEmpty)
            return false
        }
        
        return true
    }
}

// MARK: Datasource & Post Object

extension RegisterViewController {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<RegisterViewModel.Section, ImageInfo> {
        let dataSource = UICollectionViewDiffableDataSource<RegisterViewModel.Section, ImageInfo>(
            collectionView: managingView.collectionView,
            cellProvider: { (collectionView, indexPath, image) -> UICollectionViewCell in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ProductsHorizontalCell.identifier,
                    for: indexPath) as? ProductsHorizontalCell else {
                    return UICollectionViewCell()
                }
                
                cell.updateImage(imageInfo: image)
                cell.delegate = self
                
                if indexPath.row == (self.viewModel.snapshotNumberOfItems() - 1) {
                    cell.addPlusButton()
                }
                
                return cell
            })
        return dataSource
    }
    
    private func makeProductsPost() -> ProductsPost {
        let productName = managingView.productNameTextField.text ?? ""
        let descriptions = managingView.productDescriptionTextView.text ?? ""
        let productPrice = Double(managingView.productPriceTextField.text ?? "0") ?? .zero
        let currency = managingView.productCurrencySegmentedControl.selectedSegmentIndex == .zero ? Currency.KRW : Currency.USD
        let discountedPrice = Double(managingView.productDiscountedTextField.text ?? "0")
        let stock = Int(managingView.productStockTextField.text ?? "0")
        let secret = "rwfkpko1fp"
        let images = viewModel.snapshotItem()
        
        return ProductsPost(name: productName,
                            descriptions: descriptions,
                            price: productPrice,
                            currency: currency,
                            discountedPrice: discountedPrice,
                            stock: stock,
                            secret: secret,
                            image: images)
    }
}

extension RegisterViewController: CellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func addButtonTaped() {
        if viewModel.snapshotNumberOfItems() < 6 {
            self.present(imagePicker, animated: true)
        } else {
            showAlertInputError(with: .exceededNumberOfImages)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let captureImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        viewModel.insert(image: captureImage)
        self.dismiss(animated: true, completion: nil)
    }
}
