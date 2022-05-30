//
//  EndPoints.swift
//  OpenMarket
//
//  Created by Red, Mino on 2022/05/10.
//

struct EndPointStorage {
    private enum Constants {
        static let basePath = "api/products"
        static let identifier = "identifier"
        static let identifierSerialNumber = "7b016867-d1b8-11ec-9676-012a04c8e5dc"
        static let contentType = "Content-Type"
    }
    
    static func productsList(pageNumber: Int, perPages: Int)
        -> EndPoint {
        let productsRequest = ProductsReceive(
            pageNumber: pageNumber,
            perPages: perPages
        )
        let endpoint = EndPoint(
            path: Constants.basePath,
            queryParameters: productsRequest
        )
        
        return endpoint
    }
    
    static func productsPost(_ productsPost: ProductsPost) -> EndPoint {
        let headers: [String: String] = [
            Constants.identifier: Constants.identifierSerialNumber,
            Constants.contentType: "multipart/form-data; boundary=\"\(productsPost.boundary)\""
        ]
        
        let endpoint = EndPoint(
            path: Constants.basePath,
            method: .post,
            bodyParameters: productsPost,
            headers: headers
        )
        
        return endpoint
    }
    
    static func productsDetail(productID: Int) -> EndPoint {
        let endpoint = EndPoint(
            path: Constants.basePath + "/\(productID)"
        )
        
        return endpoint
    }
    
    static func productsModify(productID: Int, productsPatch: ProductsPatch) -> EndPoint {
        let headers: [String: String] = [
            Constants.identifier: Constants.identifierSerialNumber,
            Constants.contentType: "application/json"
        ]
        
        let endpoint = EndPoint(
            path: Constants.basePath + "/\(productID)",
            method: .patch,
            bodyParameters: productsPatch,
            headers: headers
        )
        
        return endpoint
    }
}
