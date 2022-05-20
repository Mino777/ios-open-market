//
//  ImageCacheManager.swift
//  OpenMarket
//
//  Created by 조민호 on 2022/05/17.
//

import UIKit

final class ImageCacheManager {
    private let apiService = APIProvider<Data>()
    private let cache = NSCache<NSURL, UIImage>()
    
    init() {
        self.cache.countLimit = 100
    }
    
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let nsURL = url as NSURL
        
        if let cachedImage = cache.object(forKey: nsURL) {
            completion(.success(cachedImage))
            return
        }
        
        apiService.requestImage(with: url) { result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.cache.setObject(image, forKey: nsURL)
                    completion(.success(image))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
