//
//  ManagingView.swift
//  OpenMarket
//
//  Created by 박세리 on 2022/05/24.
//

import UIKit

final class ManagingView: UIView {
    private enum Constants {
        static let productNamePlaceholder = "상품명"
        static let productPricePlaceholder = "상품가격"
        static let productDiscountedPlaceholder = "할인금액"
        static let productStcokPlaceholder = "재고수량"
        static let KRW = "KRW"
        static let USD = "USD"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
        setUpAttribute()
        registerCollectionViewCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = UINavigationBar(frame: CGRect(x: .zero, y: .zero, width: self.bounds.width, height: 50))
        navigationBar.items = [navigationBarItem]
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = UIImage()
        return navigationBar
    }()
    
    let navigationBarItem: UINavigationItem = {
        let navigationBarItem = UINavigationItem(title: "")
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        
        navigationBarItem.leftBarButtonItem = cancelItem
        navigationBarItem.rightBarButtonItem = doneItem
        return navigationBarItem
    }()

    let topScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                collectionView,
                productNameTextField,
                productPriceStackView,
                productDiscountedTextField,
                productStockTextField,
                productDescriptionTextView
            ]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    lazy var productNameTextField: UITextField = {
        setUpTextField(placeholder: Constants.productNamePlaceholder, keyboardType: .default)
    }()
    
    private lazy var productPriceStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [productPriceTextField, productCurrencySegmentedControl])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        return stackView
    }()
    
    lazy var productPriceTextField: UITextField = {
        setUpTextField(placeholder: Constants.productPricePlaceholder, keyboardType: .numberPad)
    }()
    
    let productCurrencySegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: [Constants.KRW, Constants.USD])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    lazy var productDiscountedTextField: UITextField = {
        setUpTextField(placeholder: Constants.productDiscountedPlaceholder, keyboardType: .numberPad)
    }()
    
    lazy var productStockTextField: UITextField = {
        setUpTextField(placeholder: Constants.productStcokPlaceholder, keyboardType: .numberPad)
    }()
    
    let productDescriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.isScrollEnabled = false
        return textView
    }()
    
    private let horizontalLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }()
    
    private func addSubviews() {
        topScrollView.addSubview(topStackView)
        addSubview(navigationBar)
        addSubview(topScrollView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topScrollView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            topScrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            topScrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            topScrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            topScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: topScrollView.widthAnchor),
            
            topStackView.topAnchor.constraint(equalTo: topScrollView.contentLayoutGuide.topAnchor),
            topStackView.bottomAnchor.constraint(equalTo: topScrollView.contentLayoutGuide.bottomAnchor),
            topStackView.leadingAnchor.constraint(equalTo: topScrollView.contentLayoutGuide.leadingAnchor, constant: 15),
            topStackView.trailingAnchor.constraint(equalTo: topScrollView.contentLayoutGuide.trailingAnchor, constant: -15),
            topStackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.175)
        ])
    }
    
    private func setUpAttribute() {
        backgroundColor = .white
    }
    
    private func setUpTextField(placeholder: String, keyboardType: UIKeyboardType) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.font = UIFont.preferredFont(forTextStyle: .subheadline)
        textField.adjustsFontForContentSizeCategory = true
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.keyboardType = keyboardType
        return textField
    }
    
    func setUpBarItem(title: String) {
        navigationBarItem.title = title
    }
    
    func setUpView(data: ProductDetail) {
        productNameTextField.text = data.name
        productPriceTextField.text = "\(Int(data.price))"
        productDiscountedTextField.text = "\(Int(data.discountedPrice))"
        productStockTextField.text = "\(data.stock)"
        productDescriptionTextView.text = data.productsDescription
        
        if data.currency == .KRW {
            productCurrencySegmentedControl.selectedSegmentIndex = .zero
        } else {
            productCurrencySegmentedControl.selectedSegmentIndex = 1
        }
    }
    
    private func registerCollectionViewCell() {
        collectionView.register(
            ProductsHorizontalCell.self,
            forCellWithReuseIdentifier: ProductsHorizontalCell.identifier
        )
    }
}
                                            
