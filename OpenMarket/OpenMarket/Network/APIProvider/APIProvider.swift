//
//  APIProvider.swift
//  OpenMarket
//
//  Created by Red, Mino on 2022/05/10.
//

import UIKit

protocol Provider {
    func retrieveProduct<T: Decodable>(with endpoint: Requestable, completion: @escaping (Result<T, Error>) -> Void)
    func requestImage(with url: URL, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionDataTaskProtocol?
}

final class APIProvider: Provider {
    private let urlSession: URLSessionProtocol
    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func retrieveProduct<T: Decodable>(
        with endpoint: Requestable,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        let urlRequest = endpoint.generateUrlRequest()
        
        switch urlRequest {
        case .success(let urlRequest):
            urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
                self?.checkError(with: data, response, error) { result in
                    switch result {
                    case .success(let data):
                        completion(data.decode())
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func registerProduct(
        with endpoint: Requestable,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let urlRequest = endpoint.generateUrlRequestMultiPartFormData()
        
        switch urlRequest {
        case .success(let urlRequest):
            urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
                self?.checkError(with: data, response, error) { result in
                    switch result {
                    case .success(_):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    func updateProduct(
        with endpoint: Requestable,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let urlRequest = endpoint.generateUrlRequest()
        
        switch urlRequest {
        case .success(let urlRequest):
            urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
                print(String(data: data!, encoding: .utf8))
                self?.checkError(with: data, response, error) { result in
                    switch result {
                    case .success(_):
                        completion(.success(()))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    @discardableResult
    func requestImage(
        with url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTaskProtocol? {
        var task: URLSessionDataTaskProtocol?
        
        task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            self?.checkError(with: data, response, error) { result in
                completion(result)
            }
        }
        task?.resume()
        
        return task
    }
    
    private func checkError(
        with data: Data?,
        _ response: URLResponse?,
        _ error: Error?,
        completion: @escaping (Result<Data, Error>) -> ()
    ) {
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let response = response as? HTTPURLResponse else {
            completion(.failure(NetworkError.responseError))
            return
        }
        
        guard (200..<300).contains(response.statusCode) else {
            completion(.failure(NetworkError.invalidHttpStatusCodeError(statusCode: response.statusCode)))
            return
        }
        
        guard let data = data else {
            completion(.failure(NetworkError.emptyDataError))
            return
        }
        
        completion(.success((data)))
    }
}
