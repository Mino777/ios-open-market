//
//  ProductsDetail.swift
//  OpenMarket
//
//  Created by Red, Mino on 2022/05/11.
//

import Foundation

struct ProductDetail: Decodable {
    let id: Int
    let vendorID: Int
    let name: String
    let thumbnail: URL
    let currency: Currency
    let price: Double
    let productsDescription: String?
    let bargainPrice: Double
    let discountedPrice: Double
    let stock: Int
    let createdAt: String?
    let issuedAt: String?
    let images: [ProductImage]
    let vendor: Vendor?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case vendorID = "vendor_id"
        case name
        case thumbnail
        case currency
        case price
        case productsDescription = "description"
        case bargainPrice = "bargain_price"
        case discountedPrice = "discounted_price"
        case stock
        case createdAt = "created_at"
        case issuedAt = "issued_at"
        case images
        case vendor = "vendors"
    }
}

struct ProductImage: Decodable, Hashable {
    let id: Int
    let url: URL
    let thumbnailURL: URL
    let isSuccess: Bool
    let issuedAt: String

    private enum CodingKeys: String, CodingKey {
        case id
        case url
        case thumbnailURL = "thumbnail_url"
        case isSuccess = "succeed"
        case issuedAt = "issued_at"
    }
}

struct Vendor: Decodable {
    let name: String
    let id: Int
    let createdAt: String
    let issuedAt: String

    private enum CodingKeys: String, CodingKey {
        case name
        case id
        case createdAt = "created_at"
        case issuedAt = "issued_at"
    }
}
