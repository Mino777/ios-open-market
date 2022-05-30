//
//  ProductsPatch.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/30.
//

import Foundation

struct ProductsPatch: Encodable {
    let name: String
    let descriptions: String
    let price: Double
    let currency: Currency
    let discountedPrice: Double?
    let stock: Int?
    let secret: String
    
    enum CodingKeys: String, CodingKey {
        case discountedPrice = "discounted_price"
        case name, descriptions, price, currency, stock, secret
    }
}
