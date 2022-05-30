//
//  Requestable.swift
//  OpenMarket
//
//  Created by Red, Mino on 2022/05/10.
//

import Foundation

protocol Requestable {
    var baseURL: String { get }
    var path: String { get }
    var method: HttpMethod { get }
    var queryParameters: Encodable? { get }
    var bodyParameters: Encodable? { get }
    var headers: [String: String]? { get }
    var sampleData: Data? { get }
}

extension Requestable {
    func generateUrlRequest() -> Result<URLRequest, NetworkError> {
        let url = generateURL()
        var urlRequest: URLRequest

        switch url {
        case.success(let url):
            urlRequest = URLRequest(url: url)
        case.failure(let error):
            return .failure(error)
        }

        if let bodyParameters = bodyParameters?.toDictionary() {
            switch bodyParameters {
            case.success(let body):
                if body.isEmpty == false {
                    do {
                        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
                    } catch {
                        return .failure(.decodeError)
                    }
                }
            case.failure(let error):
                return .failure(error)
            }
        }

        urlRequest.httpMethod = method.rawValue
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        return .success(urlRequest)
    }
    
    func generateUrlRequestMultiPartFormData() -> Result<URLRequest, NetworkError> {
        let url = generateURL()
        var urlRequest: URLRequest
 
        switch url {
        case.success(let url):
            urlRequest = URLRequest(url: url)
        case.failure(let error):
            return .failure(error)
        }
        
        if let productsPost = bodyParameters as? ProductsPost,
           let body = generateBody(productsPost) {
            urlRequest.httpBody = body
        }

        urlRequest.httpMethod = method.rawValue
        headers?.forEach { urlRequest.setValue($1, forHTTPHeaderField: $0) }

        return .success(urlRequest)
    }
    
    private func generateBody(_ productsPost: ProductsPost) -> Data? {
        var body: Data = Data()
        let boundary = productsPost.boundary
                        
        guard let jsonData = try? JSONEncoder().encode(productsPost) else {
            return nil
        }
        
        body.append(convertDataToMultiPartForm(jsonData: jsonData, boundary: boundary))
        productsPost.image.forEach { image in
            body.append(convertFileToMultiPartForm(imageInfo: image, boundary: boundary))
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }

    private func convertDataToMultiPartForm(jsonData: Data, boundary: String) -> Data {
        var data: Data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"params\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: application/json\r\n".data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append(jsonData)
        data.append("\r\n".data(using: .utf8)!)
        return data
    }
    
    private func convertFileToMultiPartForm(imageInfo: ImageInfo, boundary: String) -> Data {
        var data: Data = Data()
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(imageInfo.fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(imageInfo.type.description)\r\n".data(using: .utf8)!)
        data.append("\r\n".data(using: .utf8)!)
        data.append(imageInfo.data)
        data.append("\r\n".data(using: .utf8)!)
        return data
    }

    private func generateURL() -> Result<URL, NetworkError> {
        let fullPath = "\(baseURL)\(path)"
        guard var urlComponents = URLComponents(string: fullPath) else {
            return .failure(.urlComponetError)
        }

        var urlQueryItems = [URLQueryItem]()
        if let queryParameters = queryParameters?.toDictionary() {
            switch queryParameters {
            case.success(let data):
                data.forEach {
                    urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
                }
            case.failure(let error):
                return .failure(error)
            }
        }
          
        urlComponents.queryItems = urlQueryItems.isEmpty == false ? urlQueryItems : nil

        guard let url = urlComponents.url else {
            return .failure(.urlComponetError)
        }
        return .success(url)
    }
}
