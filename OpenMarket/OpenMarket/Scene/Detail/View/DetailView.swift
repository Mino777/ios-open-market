//
//  DetailView.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/30.
//

import UIKit

final class DetailView: UIView {
    var totalIndex: Int = 0
    
    private let topScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var topStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            collectionView,
            indexStackView,
            middleStackView,
            bottomStackView,
            descriptionLabel
        ])
        
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.axis = .vertical
        stackview.spacing = 10
        return stackview
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var indexStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            indexLabel
        ])
        return stackview
    }()
    
    private let indexLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private lazy var middleStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            nameLabel,
            stockLabel
        ])
        return stackview
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .title3)
        return label
    }()
    
    private let stockLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemGray3
        label.textAlignment = .right
        label.font = .preferredFont(forTextStyle: .title3)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [
            priceLabel,
            sellingPriceLabel
        ])
        stackview.axis = .vertical
        stackview.alignment = .trailing
        return stackview
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .callout)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let sellingPriceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .preferredFont(forTextStyle: .callout)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
        registerCollectionViewCell()
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubviews()
        makeConstraints()
        registerCollectionViewCell()
        backgroundColor = .white
    }
    
    private func addSubviews() {
        addSubview(topScrollView)
        topScrollView.addSubview(topStackView)
    }
    
    private func makeConstraints() {
        NSLayoutConstraint.activate([
            topScrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            topScrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            topScrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topScrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topScrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: topScrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            topStackView.topAnchor.constraint(equalTo: topScrollView.topAnchor),
            topStackView.bottomAnchor.constraint(equalTo: topScrollView.bottomAnchor),
            topStackView.leadingAnchor.constraint(equalTo: topScrollView.leadingAnchor),
            topStackView.trailingAnchor.constraint(equalTo: topScrollView.trailingAnchor),
            topStackView.widthAnchor.constraint(equalTo: topScrollView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func setUpView(data: ProductDetail) {
        updateLabel(data: data)
    }
    
    private func updateLabel(data: ProductDetail) {
        nameLabel.text = data.name
        
        if data.discountedPrice == 0 {
            priceLabel.isHidden = true
            sellingPriceLabel.text = "\(data.currency)  \(data.price.toDecimal())"
        } else {
            priceLabel.isHidden = false
            priceLabel.addStrikeThrough(price: String(data.price))
            priceLabel.text = "\(data.currency)  \(data.price.toDecimal())"
            sellingPriceLabel.text =  "\(data.currency)  \(data.bargainPrice.toDecimal())"
        }
        
        stockLabel.textColor = data.stock == 0 ? .systemOrange : .systemGray
        stockLabel.text = data.stock == 0 ? "품절 " : "남은수량 : \(data.stock) "
        descriptionLabel.text = data.productsDescription
    }
    
    private func registerCollectionViewCell() {
        collectionView.register(
            ProductsHorizontalCell.self,
            forCellWithReuseIdentifier: ProductsHorizontalCell.identifier
        )
    }
    
    private lazy var horizontalLayout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalHeight(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.visibleItemsInvalidationHandler = { (items, offset, env) -> Void in
            let currentIndex = items.last?.indexPath.row ?? 0
            self.indexLabel.text = "\(currentIndex + 1)/\(self.totalIndex)"
        }
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }()
}
