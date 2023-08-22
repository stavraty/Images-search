//
//  ImageCacheService.swift
//  Images search
//
//  Created by AS on 17.07.2023.
//

import UIKit
import SDWebImage

class ImageCacheService {
    
    static let shared = ImageCacheService()
    
    func loadImage(url: URL, completion: @escaping (UIImage?) -> Void) {
        SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, data, error, cacheType, finished, url) in
            completion(image)
        }
    }
}
